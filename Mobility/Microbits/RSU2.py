from microbit import *
import radio
import time
import random

MY_ID = "RSU2"
POWER_LEVEL = 2
G_TIME = 25000
Y_TIME = 1500
R_TIME = 10000
EVP_HOLD_TIME = 5000

radio.on()
radio.config(group=42, power=POWER_LEVEL)

def set_lights(r, y, g):
    pin0.write_digital(r)
    pin1.write_digital(y)
    pin2.write_digital(g)

set_lights(1, 0, 0)

mode = "NORMAL"
l_state = "R"
last_t = time.ticks_ms()
my_rssi = -100
bidding_end = 0

while True:
    now = time.ticks_ms()
    packet = radio.receive_full()

    if button_b.was_pressed():
        mode = "NORMAL"
        l_state = "R"
        set_lights(1, 0, 0)
        last_t = now

    if button_a.was_pressed():
        mode = "EVP_EVAL"
        my_rssi = 0
        bidding_end = now + 500
        radio.send(MY_ID + "|0")

    if packet:
        try:
            msg = packet[0][3:].decode('utf-8')
        except:
            msg = ""
            
        rssi = packet[1]
        
        if "EVP_REQ" in msg:
            if mode == "NORMAL":
                mode = "EVP_EVAL"
                my_rssi = rssi
                bidding_end = now + 500
                time.sleep_ms(random.randint(10, 80))
                radio.send(MY_ID + "|" + str(rssi))
            elif mode == "EVP_HOLD":
                last_t = now 
        
        elif "|" in msg:
            parts = msg.split('|')
            if mode == "EVP_EVAL" and parts[0] != MY_ID:
                try:
                    other_rssi = int(parts[1])
                    if other_rssi > my_rssi:
                        my_rssi = -999 
                except:
                    pass

    if mode == "EVP_EVAL" and now > bidding_end:
        mode = "EVP_HOLD"
        last_t = now
        if my_rssi > -999:
            l_state = "G"
            set_lights(0, 0, 1)
        else:
            if l_state == "G":
                l_state = "Y"
                set_lights(0, 1, 0)
            else:
                l_state = "R"
                set_lights(1, 0, 0)

    if mode == "EVP_HOLD":
        if my_rssi <= -999 and l_state == "Y" and time.ticks_diff(now, last_t) > Y_TIME:
            l_state = "R"
            set_lights(1, 0, 0)
        if time.ticks_diff(now, last_t) > EVP_HOLD_TIME:
            mode = "NORMAL"
            l_state = "R"
            set_lights(1, 0, 0)
            last_t = now

    if mode == "NORMAL":
        elapsed = time.ticks_diff(now, last_t)
        if l_state == "R" and elapsed > R_TIME:
            l_state = "G"
            set_lights(0, 0, 1)
            last_t = now
        elif l_state == "G" and elapsed > G_TIME:
            l_state = "Y"
            set_lights(0, 1, 0)
            last_t = now
        elif l_state == "Y" and elapsed > Y_TIME:
            l_state = "R"
            set_lights(1, 0, 0)
            last_t = now
