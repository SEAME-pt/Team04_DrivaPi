from microbit import *
import radio
import music
import time
import math

radio.on()
radio.config(group=42, power=2)
uart.init(baudrate=115200)

compass.clear_calibration()
compass.calibrate()
music.set_tempo(bpm=100, ticks=8)

mx_vstp = [
    "D:5", "D:5", "D:3", "A:5",
    "R:7",
    "A:6", "A:4", "F:6", "E:7",
]

def play_melody(repeat=1):
    music.stop() 
    display.show(Image.TRIANGLE)
    music.play(mx_vstp * repeat, wait=False)
    display.clear()

active = False
last_radio = 0
last_siren = 0
last_print = 0
siren_state = 0

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

while True:
    current_h = get_smoothed_heading()
    now = time.ticks_ms()
    
    if time.ticks_diff(now, last_print) > 1000:
        print("AMB: ", current_h)
        last_print = now

    if button_a.was_pressed():
        active = not active
        music.stop() 
        if not active:
            display.clear()
            
    if button_b.was_pressed():
        active = False 
        play_melody(repeat=2) 

    if uart.any():
        try:
            msg = uart.read().decode('utf-8').strip()
            
            if 'A' in msg:
                active = True
                music.stop() 
            elif msg.startswith('V'):
                active = False
                loops = 1 
                if len(msg) > 1:
                    try:
                        loops = int(msg[1:]) 
                    except ValueError:
                        pass 
                play_melody(repeat=loops)
        except:
            pass

    if active:
        if time.ticks_diff(now, last_radio) > 300:
            payload = "EVP_REQ|" + str(current_h)
            radio.send(payload)
            last_radio = now
        
        if time.ticks_diff(now, last_siren) > 450:
            if siren_state == 0:
                display.show(Image.SQUARE_SMALL)
                music.pitch(660, duration=500, wait=False)
                siren_state = 1
            else:
                display.show(Image.SQUARE)
                music.pitch(880, duration=500, wait=False)
                siren_state = 0
            last_siren = now
    else:
        time.sleep_ms(20)
