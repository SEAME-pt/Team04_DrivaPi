import paho.mqtt.client as mqtt
import json
import math
import serial
import time

# Update with your Micro:bit's actual serial port (e.g., 'COM3' or '/dev/ttyACM0')
try:
    mb_serial = serial.Serial('/dev/ttyACM0', 115200, timeout=1)
except:
    print("[WARNING] Micro:bit not connected.")
    mb_serial = None

# Configuration
BROKER = "localhost"
PORT = 1883
TOPIC_SRM = "v2x/priority_vehicle/srm"
TOPIC_DENM = "v2x/intersection/alerts"

# RSU Static Coordinates
RSU_LAT = 41.1770
RSU_LON = -8.5970
EVP_THRESHOLD_METERS = 50.0

# State Machine
state = "NORMAL"

def haversine_distance(lat1, lon1, lat2, lon2):
    """Calculates distance between two GPS points in meters."""
    R = 6371000  # Earth radius in meters
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)

    a = math.sin(dphi/2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda/2)**2
    return 2 * R * math.atan2(math.sqrt(a), math.sqrt(1 - a))

def on_connect(client, userdata, flags, rc):
    print(f"[RSU] Connected to broker with code {rc}. Listening for SRMs...")
    client.subscribe(TOPIC_SRM)

def on_message(client, userdata, msg):
    global state

    try:
        data = json.loads(msg.payload.decode())
        veh_lat = data.get("latitude")
        veh_lon = data.get("longitude")

        distance = haversine_distance(RSU_LAT, RSU_LON, veh_lat, veh_lon)
        print(f"[RSU] Signal received. Distance: {distance:.2f}m")

        # State Machine Logic
        if distance <= EVP_THRESHOLD_METERS and state == "NORMAL":
            print("[RSU] *** THRESHOLD BREACHED. TRIGGERING EVP PREEMPTION (GREEN ALIGNMENT) ***")
            state = "EVP_PREEMPTION"
            if mb_serial:
                mb_serial.write(b"EVP_GREEN\n")

            denm_payload = {
                "rsu_id": "RSU_NORTH_01",
                "alert_type": "EVACUATION_ZONE",
                "radius": 50,
                "action": "CLEAR_INTERSECTION",
                "timestamp": data.get("timestamp", "N/A")
            }
            client.publish(TOPIC_DENM, json.dumps(denm_payload))
            print(f"[RSU] Published DENM Alert: {json.dumps(denm_payload)}")

        elif distance > EVP_THRESHOLD_METERS and state == "EVP_PREEMPTION":
            print("[RSU] Ambulance out of range. Restoring NORMAL traffic state.")
            state = "NORMAL"

    except json.JSONDecodeError:
        print("[RSU] Malformed payload dropped.")

def run_rsu():
    client = mqtt.Client(client_id="RSU_01")
    client.on_connect = on_connect
    client.on_message = on_message

    client.connect(BROKER, PORT, 60)
    client.loop_forever()

if __name__ == "__main__":
    run_rsu()
