from microbit import *

# Initialize to normal state (e.g., Red)
pin0.write_digital(1) # Red ON
pin1.write_digital(0) # Yellow OFF
pin2.write_digital(0) # Green OFF

while True:
    if uart.any():
        command = uart.read().strip().decode()
        
        if command == "EVP_GREEN":
            # Force Green for Emergency Vehicle
            pin0.write_digital(0)
            pin1.write_digital(0)
            pin2.write_digital(1)
            
        elif command == "NORMAL":
            # Revert to standard Red
            pin0.write_digital(1)
            pin1.write_digital(0)
            pin2.write_digital(0)
            
    sleep(100)
