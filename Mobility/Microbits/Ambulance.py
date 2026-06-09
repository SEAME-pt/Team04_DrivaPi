from microbit import *
import radio
import time

radio.on()
radio.config(group=42, power=2)

while True:
    if button_a.is_pressed():
        radio.send("EVP_REQ")
        display.show("E")
        time.sleep(0.4) 
    else:
        display.clear()
        time.sleep(0.1)
