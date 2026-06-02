import paho.mqtt.client as mqtt
import time
import json
import hashlib

# Configuration
BROKER = "localhost"
PORT = 1883
TOPIC_SRM = "v2x/priority_vehicle/srm"

# Coordinates (Simulating an approach in Porto)
START_LAT, START_LON = 41.1780, -8.5980
RSU_LAT, RSU_LON = 41.1770, -8.5970
STEPS = 20  # Number of steps to reach the intersection

def generate_signature(vehicle_id, lat, lon):
    """Placeholder for ECDSA/Hash signature required by REQ-SR-01"""
    raw_data = f"{vehicle_id}{lat}{lon}SECRET_KEY".encode()
    return hashlib.sha256(raw_data).hexdigest()

def run_ambulance():
    client = mqtt.Client(client_id="AMB_01")
    client.connect(BROKER, PORT, 60)
    
    print("[AMBULANCE] Starting emergency run...")
    
    for i in range(STEPS + 1):
        # Linear interpolation for trajectory
        current_lat = START_LAT + (RSU_LAT - START_LAT) * (i / STEPS)
        current_lon = START_LON + (RSU_LON - START_LON) * (i / STEPS)
        
        payload = {
            "vehicle_id": "AMB_01",
            "type": "AMBULANCE",
            "latitude": round(current_lat, 6),
            "longitude": round(current_lon, 6),
            "status": "EMERGENCY_ACTIVE",
            "signature": generate_signature("AMB_01", current_lat, current_lon)
        }
        
        client.publish(TOPIC_SRM, json.dumps(payload))
        print(f"[AMBULANCE] Published SRM: Lat {payload['latitude']}, Lon {payload['longitude']}")
        
        time.sleep(1) # Simulate 1Hz transmission rate

if __name__ == "__main__":
    run_ambulance()
