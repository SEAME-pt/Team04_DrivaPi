from microbit import *
import radio
import music
import time
import math

# =====================================================================
# SECURITY LAYER (must be IDENTICAL on ambulance and RSUs)
# Scheme: TOTP window + monotonic RAM counter + SipHash-2-4 MAC
#         + SipHash-derived keystream to encrypt the heading.
# One-way broadcast. No handshake. No flash writes.
# =====================================================================

# !!! REGENERATE THIS KEY and paste the SAME bytes into template.py !!!
#     python3 -c "import os; print(os.urandom(16))"
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
    # MAC binds window + counter + ciphertext (encrypt-then-MAC)
    return siphash24(KEY, ("EVP|%d|%d|%d" % (w, c, ct)).encode())


def hcrypt(w, c, value):
    # 16-bit keystream, domain-separated from the MAC by the ENC prefix.
    # (window, counter) is the nonce -> keystream never repeats.
    # XOR is symmetric: same call encrypts and decrypts.
    ks = siphash24(KEY, ("ENC|%d|%d" % (w, c)).encode()) & 0xFFFF
    return value ^ ks


# =====================================================================
# ORIGINAL AMBULANCE SETUP
# =====================================================================

set_volume(50)
music.set_tempo(bpm=120, ticks=4)

win_xp_start = [
    'D#6:2', 'D#5:1', 'A#5:3', 'G#5:2', 'D#5:2', 'D#6:2', 'A#5:5'
]

win_xp_shutdown = [
    'G#5:2', 'D#5:2', 'G#4:2', 'A#4:4'
]

mx_vstp = [
    "D:3", "D:3", "D:2", "A:4",
    "R:4",
    "A:4", "A:2", "F:4", "E:4"
]

windows_logo = Image("99099:"
                     "99099:"
                     "00000:"
                     "99099:"
                     "99099")

display.show(windows_logo)
music.play(win_xp_start)

radio.on()
# length=128: secured frame is ~50 chars, default 32 would truncate it
radio.config(group=42, power=2, length=128)
uart.init(baudrate=115200)


def play_melody(repeat=1):
    music.stop()
    display.show(Image.TRIANGLE)
    music.play(mx_vstp * repeat, wait=False)
    display.clear()


# State variables
active = False
last_radio = 0
last_siren = 0
last_print = 0
siren_state = 0

# --- TOTP state (synced from Pi 5 over USB serial: "TIME|<epoch>\n") ---
current_epoch = 0
sync_ticks = 0
synced = False

# --- Anti-replay counter: RAM only, never touches flash ---
counter = 0

# --- UART line buffer (uart.read() can return partial lines) ---
rx_buf = ""

# Heading smoothing buffer
BUFFER_SIZE = 10
x_buf = [0] * BUFFER_SIZE
y_buf = [0] * BUFFER_SIZE
buf_idx = 0


def get_smoothed_heading():
    global buf_idx
    x_buf[buf_idx] = compass.get_x()
    y_buf[buf_idx] = compass.get_y()
    buf_idx = (buf_idx + 1) % BUFFER_SIZE

    avg_x = sum(x_buf) / BUFFER_SIZE
    avg_y = sum(y_buf) / BUFFER_SIZE

    if avg_x == 0 and avg_y == 0:
        return 0

    h = math.atan2(avg_y, avg_x) * 180 / math.pi
    if h < 0:
        h += 360
    return int(h)


def get_window(now):
    if not synced:
        return -1
    return (current_epoch + time.ticks_diff(now, sync_ticks) // 1000) // WINDOW_SEC


def handle_line(line):
    global active, current_epoch, sync_ticks, synced
    line = line.strip()
    if not line:
        return
    if line.startswith('TIME|'):
        try:
            current_epoch = int(line.split('|')[1])
            sync_ticks = time.ticks_ms()
            synced = True
        except ValueError:
            pass
    elif line.startswith('V'):
        active = False
        loops = 1
        if len(line) > 1:
            try:
                loops = int(line[1:])
            except ValueError:
                pass
        play_melody(repeat=loops)
    elif 'A' in line:
        active = True
        music.stop()


def uart_handler():
    global rx_buf
    if uart.any():
        data = uart.read()
        if data:
            try:
                rx_buf += str(data, 'utf-8')
            except:
                rx_buf = ""
        # protect against a runaway buffer if no newlines ever arrive
        if len(rx_buf) > 200:
            rx_buf = rx_buf[-100:]
    while '\n' in rx_buf:
        line, rx_buf = rx_buf.split('\n', 1)
        handle_line(line)


# Main Loop
while True:
    current_h = get_smoothed_heading()
    now = time.ticks_ms()

    # UART / Serial debug output
    if time.ticks_diff(now, last_print) > 1000:
        if synced:
            print("AMB: h=%d win=%d ctr=%d" % (current_h, get_window(now), counter))
        else:
            print("AMB: h=%d  WAITING FOR TIME SYNC (Pi must send TIME|<epoch>)" % current_h)
        last_print = now

    # Manual Controls
    if button_a.was_pressed():
        active = not active
        music.stop()
        if not active:
            display.clear()

    if button_b.was_pressed():
        active = False
        play_melody(repeat=2)

    if pin_logo.is_touched():
        music.stop()
        music.play(win_xp_shutdown)

    # UART input: TIME sync + A/V commands
    uart_handler()

    # Siren and Radio logic (EVP) -- secured broadcast
    if active:
        if time.ticks_diff(now, last_radio) > 300:
            if synced:
                counter += 1
                w = get_window(now)
                ct = hcrypt(w, counter, current_h)
                tag = make_tag(w, counter, ct)
                radio.send("EVP|%d|%d|%d|%d" % (w, counter, ct, tag))
            last_radio = now

        if time.ticks_diff(now, last_siren) > 450:
            if siren_state == 0:
                display.show(Image.SQUARE_SMALL)
                music.pitch(880, duration=500, wait=False)
                siren_state = 1
            else:
                display.show(Image.SQUARE)
                music.pitch(660, duration=500, wait=False)
                siren_state = 0
            last_siren = now
    else:
        time.sleep_ms(20)