from microbit import *
import radio
import time
import random
import math

MY_ID = "RSU2"
EXPECTED_HEADING = 240
TOLERANCE = 30
POWER_LEVEL = 2

G_TIME = 25000
Y_TIME = 1500
R_TIME = 10000
EVP_HOLD_TIME = 7000
COOLDOWN_TIME = 5000

radio.on()
radio.config(group=42, power=POWER_LEVEL)
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

def main():
    global mode, l_state, last_t, now, my_rssi,\
            bidding_end, cooldown_end, last_print, packet
    print(MY_ID + " BOOTED. GATE SET TO: " + str(EXPECTED_HEADING))
    l_state = set_lights("R")
    
    while True:
        now = time.ticks_ms()
        current_h = get_upright_heading()
        
        # (Optional: Uncomment to see live heading, but it spams the MQTT bridge!)
        # if time.ticks_diff(now, last_print) > 1000:
        #     print(MY_ID + " LIVE PHYSICAL HEADING:", current_h)
        #     last_print = now
            
        packet = radio.receive_full()
        
        button_handler()
        packet_handler()
        emergency_logic()        
        semaphore_logic()

def set_lights(state):
    pin0.write_digital(1 if state == "R" else 0)
    pin1.write_digital(1 if state == "Y" else 0)
    pin2.write_digital(1 if state == "G" else 0)

    # Send state to Pi 4 via USB
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

def emergency_logic():
    global mode, l_state, last_t, now, my_rssi, bidding_end, cooldown_end
    if mode == "EVP_EVAL" and now > bidding_end:
        mode = "EVP_HOLD"
        last_t = now

        # 1. TELL THE NETWORK THE EMERGENCY HAS STARTED
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
            last_t = now
            
            # 2. TELL THE NETWORK THE EMERGENCY IS OVER
            print("MQTT|" + MY_ID + "/emergency|OFF")
            
            if MY_ID == "RSU1":
                l_state = set_lights("G")
            else:
                l_state = set_lights("R")

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

def button_handler():
    global mode, l_state, last_t, now, my_rssi, bidding_end, cooldown_end
    if button_b.was_pressed():
        mode = "NORMAL"
        l_state = set_lights("R")
        last_t = now
        cooldown_end = 0
            
    if button_a.was_pressed():
        mode = "EVP_EVAL"
        my_rssi = 0 
        bidding_end = now + 50
        radio.send(MY_ID + "|0")

def packet_handler():
    global mode, l_state, last_t, now, my_rssi, bidding_end, cooldown_end, packet
    if packet:
        try:
            msg = packet[0][3:].decode('utf-8')
        except:
            msg = ""
            
        rssi = packet[1]
        
        if "EVP_REQ|" in msg:
            if mode == "NORMAL" and now > cooldown_end:
                try:
                    amb_h = int(msg.split('|')[1])
                    mode = "EVP_EVAL"
                    bidding_end = now + 500
                    
                    if is_valid_approach(amb_h):
                        my_rssi = rssi
                        time.sleep_ms(random.randint(10, 80))
                        radio.send(MY_ID + "|" + str(my_rssi))
                    else:
                        my_rssi = -999
                except:
                    pass
                    
        elif "|" in msg:
            parts = msg.split('|')
            if mode == "EVP_EVAL" and parts[0] != MY_ID:
                try:
                    other_rssi = int(parts[1])
                    if other_rssi > my_rssi:
                        my_rssi = -999 
                except:
                    pass

main()