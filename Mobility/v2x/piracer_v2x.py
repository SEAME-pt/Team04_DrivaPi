import paho.mqtt.client as mqtt
import json
import sys

# Configuration
BROKER_IP = "192.168.1.100"  # Replace with your lab laptop's actual local IP
PORT = 1883
TOPIC_ALERTS = "v2x/intersection/alerts"

def emergency_stop():
    """Triggers the physical stop sequence on the vehicle"""
    print("[PIRACER] !!! EMERGENCY OVERRIDE RECEIVED !!!")
    print("[PIRACER] Sending stop signal to STM32 MCU over I2C/Serial...")
    # Here you would call your actual hardware functions, e.g.:
    # piracer.set_throttle_pct(0.0)
    # piracer.set_steering_pct(0.5)  # Pull over slightly right
    
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print(f"[PIRACER] Connected to V2X Broker at {BROKER_IP}")
        # Subscribe directly to the intersection alert topic
        client.subscribe(TOPIC_ALERTS)
        print(f"[PIRACER] Subscribed to topic: {TOPIC_ALERTS}")
    else:
        print(f"[PIRACER] Connection failed with code {rc}")

def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode())
        print(f"[PIRACER] Alert parsed: {payload.get('alert_type')}")
        
        if payload.get("alert_type") == "EVACUATION_ZONE":
            emergency_stop()
            
    except json.JSONDecodeError:
        print("[PIRACER] Received invalid JSON payload.")

def run_vehicle_v2x():
    client = mqtt.Client(client_id="PiRacer_Node_01")
    client.on_connect = on_connect
    client.on_message = on_message

    try:
        client.connect(BROKER_IP, PORT, 60)
    except Exception as e:
        print(f"[PIRACER] Critical: Could not connect to broker: {e}")
        sys.exit(1)

    # loop_forever() blocks this thread. Run this in a background thread 
    # if your camera lane-following control loop runs in the main thread.
    client.loop_forever()

if __name__ == "__main__":
    run_vehicle_v2x()
