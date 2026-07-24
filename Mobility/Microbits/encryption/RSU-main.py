from microbit import *
import radio
import time
import random
import math

# Variáveis injetadas pelo script flash.sh
MY_ID = "RSU3"
EXPECTED_HEADING = 333

TOLERANCE = 45
POWER_LEVEL = 2

# =====================================================================
# SECURITY LAYER (must be IDENTICAL on ambulance and RSUs)
# Scheme: TOTP window + monotonic counter + SipHash-2-4 MAC
#         + SipHash-derived keystream (heading travels encrypted).
# Accept a frame only if ALL of:
#   1. its window is within +/-1 of our local window   (freshness)
#   2. its SipHash tag verifies                        (authenticity)
#   3. (window, counter) > last accepted pair          (anti-replay)
# =====================================================================

# !!! Same 16 bytes as in Ambulance.py !!!
KEY = b'\x8f\x1a\x42\xd9\x03\x77\xbe\x5c\xe1\x29\x6b\xf4\x0d\x98\xa3\x56'

WINDOW_SEC = 30
M = 0xFFFFFFFFFFFFFFFF


def _rotl(x, b):
    return ((x << b) | (x >> (64 - b))) & M


def siphash24(key, data):
    k0 = int.from_bytes(key[0:8], 'little')
    k1 = int.from_bytes(key[8:16], 'little')
    v0 = k0 ^ 0x736f6d6570736575
    v1 = k1 ^ 0x646f72616e646f6d
    v2 = k0 ^ 0x6c7967656e657261
    v3 = k1 ^ 0x7465646279746573

    def rnd(a, b, c, d):
        a = (a + b) & M; b = _rotl(b, 13); b ^= a; a = _rotl(a, 32)
        c = (c + d) & M; d = _rotl(d, 16); d ^= c
        a = (a + d) & M; d = _rotl(d, 21); d ^= a
        c = (c + b) & M; b = _rotl(b, 17); b ^= c; c = _rotl(c, 32)
        return a, b, c, d

    pad = (8 - ((len(data) + 1) % 8)) % 8
    buf = data + b'\x00' * pad + bytes([len(data) & 0xFF])
    for i in range(0, len(buf), 8):
        m = int.from_bytes(buf[i:i + 8], 'little')
        v3 ^= m
        v0, v1, v2, v3 = rnd(v0, v1, v2, v3)
        v0, v1, v2, v3 = rnd(v0, v1, v2, v3)
        v0 ^= m
    v2 ^= 0xFF
    for _ in range(4):
        v0, v1, v2, v3 = rnd(v0, v1, v2, v3)
    return v0 ^ v1 ^ v2 ^ v3


def make_tag(w, c, ct):
    return siphash24(KEY, ("EVP|%d|%d|%d" % (w, c, ct)).encode())


def hcrypt(w, c, value):
    ks = siphash24(KEY, ("ENC|%d|%d" % (w, c)).encode()) & 0xFFFF
    return value ^ ks


def make_bid_tag(rsu_id, w, c, rssi):
    # Domain-separated ("BID|") so an ambulance tag can never pass as a bid.
    # Binds the bid to the (window, counter) of the ambulance frame that
    # triggered this round -> a captured bid is useless in any later round.
    return siphash24(KEY, ("BID|%s|%d|%d|%d" % (rsu_id, w, c, rssi)).encode())


def send_bid(rssi):
    tag = make_bid_tag(MY_ID, last_win, last_ctr, rssi)
    radio.send("BID|%s|%d|%d|%d|%d" % (MY_ID, last_win, last_ctr, rssi, tag))


# --- MATEMÁTICA DE TRÂNSITO ---
G_TIME = 25000
Y_TIME = 1500
TOTAL_RSUS = 3
CYCLE_TIME = G_TIME + Y_TIME
R_TIME = CYCLE_TIME * (TOTAL_RSUS - 1)
EVP_HOLD_TIME = 7000
COOLDOWN_TIME = 5000

radio.on()
# length=128: secured frame is ~50 chars, default 32 would truncate it
radio.config(group=42, power=POWER_LEVEL, length=128)
uart.init(baudrate=115200)

mode = "NORMAL"
l_state = "R"
last_t = time.ticks_ms()
now = 0
my_rssi = -999
bidding_end = 0
cooldown_end = 0
last_print = 0
packet = None

# --- TOTP (tempo vem EXCLUSIVAMENTE por cabo, imune a radio spoofing) ---
current_epoch = 0
sync_ticks = 0
synced = False

# --- Anti-replay: último par (janela, contador) aceite. Só RAM. ---
last_win = -1
last_ctr = 0

# --- Buffer de linha UART (uart.read() pode devolver linhas parciais) ---
rx_buf = ""

one = Image("00009:"
            "99999:"
            "09009:"
            "00000:"
            "00000")

two = Image("09009:"
            "90909:"
            "90099:"
            "00000:"
            "00000")

three = Image("09990:"
              "90909:"
              "90009:"
              "00000:"
              "00000")


def display_number():
    if MY_ID == "RSU1":
        display.show(one)
    elif MY_ID == "RSU2":
        display.show(two)
    elif MY_ID == "RSU3":
        display.show(three)


def set_lights(state):
    pin0.write_digital(1 if state == "R" else 0)
    pin1.write_digital(1 if state == "Y" else 0)
    pin2.write_digital(1 if state == "G" else 0)

    # Envia o estado para o Raspberry Pi via USB (MQTT Bridge)
    print("MQTT|" + MY_ID + "/state|" + state)
    return state


def get_upright_heading():
    x = compass.get_x()
    z = compass.get_z()

    if x == 0 and z == 0:
        return 0

    h = math.atan2(z, x) * 180 / math.pi
    if h < 0:
        h += 360
    return int(h)


def is_valid_approach(amb_h):
    diff = abs(amb_h - EXPECTED_HEADING)
    if diff > 180:
        diff = 360 - diff
    return diff <= TOLERANCE


def local_window():
    if not synced:
        return -9999  # garante que nenhuma janela real passa no teste +/-1
    return (current_epoch + time.ticks_diff(now, sync_ticks) // 1000) // WINDOW_SEC


# --- PROTEÇÃO OOB (OUT-OF-BAND): O TEMPO VEM EXCLUSIVAMENTE POR CABO ---
def uart_handler():
    global rx_buf, current_epoch, sync_ticks, synced
    if uart.any():
        data = uart.read()
        if data:
            try:
                rx_buf += str(data, 'utf-8')
            except:
                rx_buf = ""
        if len(rx_buf) > 200:
            rx_buf = rx_buf[-100:]
    while '\n' in rx_buf:
        line, rx_buf = rx_buf.split('\n', 1)
        line = line.strip()
        if line.startswith('TIME|'):
            try:
                current_epoch = int(line.split('|')[1])
                sync_ticks = time.ticks_ms()
                synced = True
            except ValueError:
                pass


def button_handler():
    global mode, l_state, last_t, now, my_rssi, bidding_end, cooldown_end
    # Força modo normal
    if button_b.was_pressed():
        mode = "NORMAL"
        l_state = set_lights("R")
        last_t = now
        cooldown_end = 0

    # Força modo de avaliação de emergência
    if button_a.was_pressed():
        mode = "EVP_EVAL"
        my_rssi = 0
        bidding_end = now + 50
        send_bid(0)


def packet_handler():
    global mode, l_state, last_t, now, my_rssi, bidding_end, cooldown_end, \
        packet, last_win, last_ctr
    if packet:
        try:
            msg = str(packet[0][3:], 'utf-8')
        except:
            msg = ""

        rssi = packet[1]

        if msg.startswith("EVP|"):
            if time.ticks_diff(now, cooldown_end) > 0:
                try:
                    parts = msg.split('|')
                    amb_win = int(parts[1])
                    amb_ctr = int(parts[2])
                    amb_ct = int(parts[3])
                    amb_tag = int(parts[4])

                    # 1) FRESCURA: janela TOTP dentro de +/-1 da local
                    lw = local_window()
                    if lw - 1 <= amb_win <= lw + 1:

                        # 2) AUTENTICIDADE: verificar MAC ANTES de decifrar
                        if amb_tag == make_tag(amb_win, amb_ctr, amb_ct):

                            # 3) ANTI-REPLAY: (janela, contador) tem de crescer.
                            #    Reboot da ambulância -> contador volta a 0 mas
                            #    numa janela nova -> par continua a crescer.
                            if (amb_win > last_win) or \
                               (amb_win == last_win and amb_ctr > last_ctr):
                                last_win = amb_win
                                last_ctr = amb_ctr

                                # Só agora decifrar o heading
                                amb_h = hcrypt(amb_win, amb_ctr, amb_ct)

                                # --- GLOBAL INTERSECTION LOCK ---
                                if mode == "NORMAL":
                                    mode = "EVP_EVAL"
                                    bidding_end = now + 500
                                    if is_valid_approach(amb_h):
                                        my_rssi = rssi
                                        time.sleep_ms(random.randint(10, 80))
                                        send_bid(my_rssi)
                                    else:
                                        # Força vermelho: não colidir com a via ativa
                                        my_rssi = -1000
                                # Estende o temporizador se a emergência continuar
                                elif mode == "EVP_HOLD" and l_state != "Y":
                                    last_t = now
                except:
                    pass

        # Sistema de leilão de RSSI (agora autenticado)
        elif msg.startswith("BID|"):
            parts = msg.split('|')
            if mode == "EVP_EVAL" and len(parts) == 6 and parts[1] != MY_ID:
                try:
                    b_id = parts[1]
                    b_win = int(parts[2])
                    b_ctr = int(parts[3])
                    b_rssi = int(parts[4])
                    b_tag = int(parts[5])

                    # Frescura: mesma ronda (janela local +/-1 e contador
                    # perto do último frame de ambulância que EU aceitei;
                    # +/-3 cobre RSUs que dispararam em frames vizinhos)
                    lw = local_window()
                    if lw - 1 <= b_win <= lw + 1 and abs(b_ctr - last_ctr) <= 3:
                        # Autenticidade: só quem tem a KEY gera este tag
                        if b_tag == make_bid_tag(b_id, b_win, b_ctr, b_rssi):
                            if b_rssi > my_rssi:
                                my_rssi = -999
                except:
                    pass


def emergency_logic():
    global mode, l_state, last_t, now, my_rssi, bidding_end, cooldown_end

    if mode == "EVP_EVAL" and now > bidding_end:
        mode = "EVP_HOLD"
        last_t = now

        print("MQTT|" + MY_ID + "/emergency|ON")
        if my_rssi > -999:
            l_state = set_lights("G")
        else:
            if l_state == "G":
                l_state = set_lights("Y")
            else:
                l_state = set_lights("R")

    if mode == "EVP_HOLD":
        if my_rssi <= -999 and l_state == "Y" and time.ticks_diff(now, last_t) > Y_TIME:
            l_state = set_lights("R")

        if time.ticks_diff(now, last_t) > EVP_HOLD_TIME:
            mode = "NORMAL"
            cooldown_end = now + COOLDOWN_TIME

            print("MQTT|" + MY_ID + "/emergency|OFF")

            # --- RECUPERAÇÃO DE ESTADO (EVITA COLISÕES) ---
            if MY_ID == "RSU1":
                l_state = set_lights("G")
                last_t = now
            elif MY_ID == "RSU2":
                l_state = set_lights("R")
                last_t = now - CYCLE_TIME
            elif MY_ID == "RSU3":
                l_state = set_lights("R")
                last_t = now


def semaphore_logic():
    global mode, l_state, now, last_t
    if mode == "NORMAL":
        elapsed = time.ticks_diff(now, last_t)
        if l_state == "R" and elapsed > R_TIME:
            l_state = set_lights("G")
            last_t = now
        elif l_state == "G" and elapsed > G_TIME:
            l_state = set_lights("Y")
            last_t = now
        elif l_state == "Y" and elapsed > Y_TIME:
            l_state = set_lights("R")
            last_t = now


def main():
    global mode, l_state, last_t, now, my_rssi, \
        bidding_end, cooldown_end, last_print, packet

    print(MY_ID + " BOOTED. GATE SET TO: " + str(EXPECTED_HEADING))

    # --- ARRANQUE DESFASADO INICIAL ---
    if MY_ID == "RSU1":
        l_state = set_lights("G")
        last_t = time.ticks_ms()
    elif MY_ID == "RSU2":
        l_state = set_lights("R")
        last_t = time.ticks_ms() - CYCLE_TIME
    elif MY_ID == "RSU3":
        l_state = set_lights("R")
        last_t = time.ticks_ms()

    display_number()

    while True:
        now = time.ticks_ms()

        packet = radio.receive_full()

        uart_handler()
        button_handler()
        packet_handler()
        emergency_logic()
        semaphore_logic()


main()