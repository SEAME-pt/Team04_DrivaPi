# KUKSA CAN Feeder

A C++ daemon that reads CAN frames from SocketCAN and publishes vehicle signals to KUKSA databroker using the VAL v2 gRPC API.

## Architecture

```
[STM32 ThreadX]  ──CAN──>  [RPi5: kuksa_feeder]  ──gRPC──>  [KUKSA Databroker]  ──gRPC──>  [Qt Dashboard]
     (0x100)                   CAN→VSS                          (localhost:55555)              Subscribe
```

## Features

- **Zero-copy CAN reading**: Direct SocketCAN integration
- **VAL v2 native**: Uses latest KUKSA databroker API
- **Type-safe publishing**: Typed helper methods (publishFloat, publishDouble, etc.)
- **Extensible handlers**: Easy to add new CAN IDs and VSS signals
- **No Python dependency**: Pure C++ for low latency

## Current Signal Mapping

| CAN ID | Payload | VSS Path | Unit | Type |
|--------|---------|----------|------|------|
| 0x100 | 4-byte float (LE) m/s | `Vehicle.Speed` | km/h | float |

## Building

The feeder is built automatically with the Qt app via CMake:

```bash
cd qt-app
mkdir build && cd build
cmake ..
make kuksa_feeder
```

This produces the `kuksa_feeder` executable.

## Prerequisites

### 1. KUKSA Databroker Running

Ensure KUKSA databroker is running on the target system (RPi5):

```bash
# Check if databroker is running
systemctl status kuksa-databroker

# Start if needed
sudo systemctl start kuksa-databroker
```

Configuration (typically in `/etc/default/kuksa-databroker`):

**Production (with TLS/authorization):**
```bash
EXTRA_ARGS="--address 0.0.0.0 --port 55555 --vss /etc/kuksa/vss.json --tls /etc/kuksa/server.crt --tls-key /etc/kuksa/server.key"
```

**Development/Testing ONLY (⚠️ INSECURE - exposes signals without credentials):**
```bash
EXTRA_ARGS="--address 0.0.0.0 --port 55555 --vss /etc/kuksa/vss.json --insecure --disable-authorization"
```
⚠️ **WARNING:** The test-only configuration above allows any local network client to read or actuate all vehicle signals without encryption or authentication. **Never use in production or on networked deployments.**

### 2. VSS Signal Definitions

Your `vss.json` **must** include the signals you publish. At minimum:

```json
{
  "Vehicle.Speed": {
    "datatype": "float",
    "type": "sensor",
    "unit": "km/h",
    "description": "Vehicle speed"
  }
}
```

Restart databroker after updating `vss.json`:
```bash
sudo systemctl restart kuksa-databroker
```

### 3. CAN Interface Setup

Bring up your CAN interface before running the feeder:

```bash
# For real CAN (adjust bitrate as needed)
sudo ip link set can0 type can bitrate 500000
sudo ip link set can0 up

# For testing with virtual CAN
sudo modprobe vcan
sudo ip link add dev can1 type vcan
sudo ip link set can1 up
```

## Usage

### Basic Usage

```bash
./kuksa_feeder
```

Default values:
- CAN interface: `can0`
- KUKSA address: `localhost:55555`

### Custom Interface/Address

```bash
./kuksa_feeder can1 192.168.1.100:55555
### TLS and Authorization

The feeder supports TLS and optional mTLS, plus JWT-based authorization.

Flags:
- `--tls` / `--insecure`: Enable TLS or use insecure mode (default: insecure)
- `--ca <path>`: Root CA certificate
- `--cert <path>`: Client certificate (for mTLS)
- `--key <path>`: Client private key (for mTLS)
- `--token <jwt>`: Authorization token (sends `Authorization: Bearer <jwt>`)

Examples:

```bash
# TLS with root CA
./kuksa_feeder can1 kuksa.local:55555 --tls --ca /etc/kuksa/ca.crt

# mTLS with token
./kuksa_feeder can1 kuksa.local:55555 --tls --ca /etc/kuksa/ca.crt \
  --cert /etc/kuksa/client.crt --key /etc/kuksa/client.key \
  --token eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
```

### Expected Output

```
========================================
  KUKSA CAN Feeder
========================================
CAN Interface: can0
KUKSA Address: localhost:55555
========================================
[Publisher] Connected to KUKSA databroker at localhost:55555
[CAN] Listening on interface: can0
[Feeder] Running. Press Ctrl+C to stop.
[Handler] Published Vehicle.Speed = 19.08 km/h (5.3 m/s)
[Handler] Published Vehicle.Speed = 20.88 km/h (5.8 m/s)
```

## Testing

### 1. Send Test CAN Frame (can1)

```bash
# Install can-utils if needed
sudo apt-get install can-utils

# Send a speed frame (0x100) with float value 12.5 m/s (45.0 km/h)
# Convert 12.5 to little-endian hex: 0x41480000
cansend can1 100#00004841
```

### 2. Verify in KUKSA CLI

```bash
kuksa-client
> get Vehicle.Speed
```

Expected output:
```
Vehicle.Speed: 12.5
```

### 3. Verify in Qt Dashboard

Run the Qt app in KUKSA mode:
```bash
./myqtapp --kuksa
```

The speedometer should display the value published by the feeder.

## Adding New Signals

### 1. Define CAN ID

Edit `src/feeder/can_ids.hpp`:

```cpp
namespace can {
constexpr uint32_t ID_SPEED = 0x100;
constexpr uint32_t ID_TEMPERATURE = 0x200;  // New ID
}
```

### 2. Define VSS Path

Edit `src/feeder/signals.hpp`:

```cpp
namespace vss {
constexpr const char* VEHICLE_SPEED = "Vehicle.Speed";
constexpr const char* VEHICLE_EXTERIOR_TEMP = "Vehicle.Exterior.AirTemperature";  // New path
}
```

### 3. Create Handler

Edit `src/feeder/handlers.hpp`:

```cpp
void handleTemperature(const can_frame& frame, kuksa::Publisher& publisher);
```

Edit `src/feeder/handlers.cpp`:

```cpp
void handleTemperature(const can_frame& frame, kuksa::Publisher& publisher) {
    if (frame.can_dlc < 2) return;
    
    int16_t temp_x10 = can_decode::i16_le(frame.data);
    float temp_c = temp_x10 / 10.0f;
    
    publisher.publishFloat(vss::VEHICLE_EXTERIOR_TEMP, temp_c);
}
```

### 4. Wire Dispatcher

Edit `src/feeder/main.cpp` in `dispatchFrame()`:

```cpp
case can::ID_TEMPERATURE:
    handlers::handleTemperature(frame, publisher);
    break;
```

### 5. Update VSS File

Add to `/etc/kuksa/vss.json`:

```json
{
  "Vehicle.Exterior.AirTemperature": {
    "datatype": "float",
    "type": "sensor",
    "unit": "celsius",
    "description": "Ambient air temperature"
  }
}
```

Restart databroker and rebuild the feeder.

## Troubleshooting

### "Path not found" Error

```
[Publisher] PublishValue(Vehicle.Speed, 10.5) failed: Path not found
```

**Fix**: Ensure the VSS path exists in `/etc/kuksa/vss.json` and restart databroker.

### CAN Interface Not Found

```
[CAN] Failed to get interface index for can0: No such device
```

**Fix**: Bring up the interface:
```bash
sudo ip link set can0 up
```

### Connection Refused

```
[Publisher] Failed to connect to localhost:55555
```

**Fix**: Start KUKSA databroker:
```bash
sudo systemctl start kuksa-databroker
```

### No CAN Frames Received

Check if CAN traffic exists:
```bash
candump can0
```

If empty, verify STM32 is transmitting and the CAN bus is wired correctly.

## Performance Notes

- The feeder introduces **~2 ms average latency** (CAN → KUKSA publish), which is acceptable for 60 Hz UI updates.
- Occasional spikes up to 37 ms may occur due to OS scheduling (non-RTOS Linux).
- For critical signals, consider prioritizing the feeder process:

```bash
sudo nice -n -20 ./kuksa_feeder
```

## Architecture Benefits vs. kuksa-can-provider

| Aspect | kuksa-can-provider (Python) | C++ Feeder |
|--------|----------------------------|------------|
| Language | Python | C++ |
| Latency | Higher (interpreter overhead) | Lower (native) |
| Dependencies | Python runtime + libs | gRPC + protobuf (already used by Qt) |
| Integration | Separate tool | Same codebase as Qt app |
| Customization | DBC + mapping.json | Direct handler code |
| Cross-compilation | Requires Python on target | Same toolchain as Qt |

## License

Apache-2.0 (matches KUKSA proto definitions)
