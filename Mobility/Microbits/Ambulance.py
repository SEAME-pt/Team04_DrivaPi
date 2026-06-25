from microbit import *
import radio
import music
import time
import math

# Initialization
#set_volume(255)
music.set_tempo(bpm=120, ticks=4)

# Melodies
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

# Boot sequence
windows_logo = Image("99099:"
                     "99099:"
                     "00000:"
                     "99099:"
                     "99099")

display.show(windows_logo)
music.play(win_xp_start)

# Peripherals setup
radio.on()
radio.config(group=42, power=2)
uart.init(baudrate=115200)

# compass.clear_calibration()
# compass.calibrate()

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

# Main Loop
while True:
    current_h = get_smoothed_heading()
    now = time.ticks_ms()
    
    # UART / Serial debug output
    if time.ticks_diff(now, last_print) > 1000:
        print("AMB: ", current_h)
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
        # Stop any currently playing music so the shutdown sound is clear
        music.stop()
        # Play the shutdown melody
        music.play(win_xp_shutdown)

    # UART Input parsing
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

    # Siren and Radio logic (EVP)
    if active:
        if time.ticks_diff(now, last_radio) > 300:
            payload = "EVP_REQ|" + str(current_h)
            radio.send(payload)
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
