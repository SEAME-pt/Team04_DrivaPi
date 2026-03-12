# KUKSA CAN Feeder

A C++ daemon that reads CAN frames from SocketCAN and publishes vehicle signals to
KUKSA databroker using the VAL v2 gRPC API.

## Architecture

```
[STM32 ThreadX]  ──CAN──>  [RPi5: kuksa_feeder]  ──gRPC──>  [KUKSA Databroker]  ──gRPC──>  [Qt Dashboard]
 (0x100..0x400)                  CAN→VSS                        (localhost:55555)             Subscribe
```

All components run on the same device (RPi5). The databroker is bound exclusively to
the loopback interface — no network exposure occurs.

## Features

- **Zero-copy CAN reading**: Direct SocketCAN integration via `feeder_can`
- **VAL v2 native**: Uses the latest KUKSA databroker gRPC API
- **Type-safe publishing**: Typed methods (`PublishFloat`, `PublishInt32`, etc.)
- **Multi-signal pipeline**: Speed, battery (STM32 + RPi), gear and environment
- **Graceful shutdown**: SIGINT/SIGTERM handled; gRPC and Protobuf state cleaned up
- **No Python dependency**: Pure C++ — same toolchain as the Qt app

## Signal Mapping

| CAN ID | Payload | VSS Path | Unit | Type |
|--------|---------|----------|------|------|
| `0x100` | 4-byte float LE — m/s | `Vehicle.Speed` | km/h | float |
| `0x200` | `[0]` uint8 percent, `[1..4]` float LE — V | `Vehicle.ControlUnit.STM32.Health.Resources.BatteryLevel` | % | float |
| `0x200` | same frame | `Vehicle.ControlUnit.STM32.Health.Resources.BatteryVoltage` | V | float |
| `0x210` | `[0]` uint8 percent, `[1..4]` float LE — V | `Vehicle.ControlUnit.Central.Health.Resources.BatteryLevel` | % | float |
| `0x210` | same frame | `Vehicle.ControlUnit.Central.Health.Resources.BatteryVoltage` | V | float |
| `0x300` | `[0]` uint8 — `0`=N, `1`=R, `2`=D | `Vehicle.Powertrain.Transmission.CurrentGear` | — | int32 (`0`/`-1`/`1`) |
| `0x400` | `[0..3]` float LE — °C, `[4..7]` float LE — % | `Vehicle.ControlUnit.STM32.Health.Resources.Temperature` | °C | float |
| `0x400` | same frame | `Vehicle.ControlUnit.STM32.Health.Resources.Humidity` | % | float |

> **Gear encoding:** STM32 raw `0`→VSS `0` (Neutral), `1`→VSS `-1` (Reverse), `2`→VSS `1` (Drive).

## Building

The feeder is built alongside the Qt app via CMake:

```bash
cd meta-cross/recipes-apps/qt-app/files/qt-app
mkdir build && cd build
cmake ..
make -j$(nproc) kuksa_feeder
```

This produces the `kuksa_feeder` executable.

## Prerequisites

### 1. KUKSA Databroker

Ensure the databroker is running on the RPi5:

```bash
systemctl status kuksa-databroker
sudo systemctl start kuksa-databroker   # if not running
```

Configuration file: `/etc/default/kuksa-databroker`

**Production (TLS + authorization):**
```bash
EXTRA_ARGS="--address 127.0.0.1 --port 55555 --vss /etc/kuksa/vss.json --tls /etc/kuksa/server.crt --tls-key /etc/kuksa/server.key"
```

> The broker is bound to `127.0.0.1` (loopback only). Both the feeder and the Qt app
> run on the same device — no network traversal is required. Do **not** use `0.0.0.0`
> unless remote access is explicitly required; if it is, TLS is mandatory.

**Development/Testing ONLY (⚠️ insecure — loopback only):**
```bash
EXTRA_ARGS="--address 127.0.0.1 --port 55555 --vss /etc/kuksa/vss.json --insecure --disable-authorization"
```

> ⚠️ This configuration disables encryption and authorization. It is safe **only** because
> the broker is bound to `127.0.0.1`. **Never bind to `0.0.0.0` with `--insecure`.**

### 2. VSS Signal Definitions

`vss.json` must declare every path the feeder publishes. Minimum required entries:

```json
{
  "Vehicle.Speed": {
    "datatype": "float", "type": "sensor", "unit": "km/h",
    "description": "Vehicle speed"
  },
  "Vehicle.ControlUnit.STM32.Health.Resources.BatteryLevel": {
    "datatype": "float", "type": "sensor", "unit": "percent",
    "description": "STM32 12V battery state of charge"
  },
  "Vehicle.ControlUnit.STM32.Health.Resources.BatteryVoltage": {
    "datatype": "float", "type": "sensor", "unit": "V",
    "description": "STM32 12V battery voltage"
  },
  "Vehicle.Powertrain.Transmission.CurrentGear": {
    "datatype": "int8", "type": "sensor",
    "description": "Current gear: 0=Neutral, -1=Reverse, 1=Drive"
  },
  "Vehicle.ControlUnit.STM32.Health.Resources.Temperature": {
    "datatype": "float", "type": "sensor", "unit": "celsius",
    "description": "STM32 internal temperature"
  },
  "Vehicle.ControlUnit.STM32.Health.Resources.Humidity": {
    "datatype": "float", "type": "sensor", "unit": "percent",
    "description": "STM32 internal humidity"
  },
  "Vehicle.ControlUnit.Central.Health.Resources.BatteryLevel": {
    "datatype": "float", "type": "sensor", "unit": "percent",
    "description": "RPi UPS battery level"
  },
  "Vehicle.ControlUnit.Central.Health.Resources.BatteryVoltage": {
    "datatype": "float", "type": "sensor", "unit": "V",
    "description": "RPi UPS battery voltage"
  }
}
```

Restart the databroker after modifying `vss.json`:

```bash
sudo systemctl restart kuksa-databroker
```

### 3. CAN Interface

```bash
# Physical CAN (adjust bitrate to match STM32 configuration)
sudo ip link set can1 type can bitrate 500000
sudo ip link set can1 up

# Virtual CAN (for testing without hardware)
sudo modprobe vcan
sudo ip link add dev can1 type vcan
sudo ip link set can1 up
```

## Usage

### Permissions

The feeder opens a raw CAN socket (`AF_CAN, SOCK_RAW`), which normally requires root.
Instead of running the binary as root, grant only the specific capability it needs:

```bash
sudo setcap cap_net_raw+ep ./kuksa_feeder
```

This follows the **principle of least privilege**: the binary can open raw network sockets
without having a full root context. Re-run `setcap` after every recompile (the capability
is cleared when the file is replaced).

To also allow higher scheduling priority (reduces CAN latency jitter):

```bash
sudo setcap cap_net_raw,cap_sys_nice+ep ./kuksa_feeder
nice -n -20 ./kuksa_feeder   # no sudo needed once cap_sys_nice is granted
```

### Basic

```bash
./kuksa_feeder
```

Defaults:
- CAN interface: `can1`
- KUKSA address: `localhost:55555`
- Security: insecure (loopback only)

### Named flags

```bash
./kuksa_feeder --can-if can0 --address localhost:55555
```

### TLS and Authorization

```bash
# TLS with root CA only
./kuksa_feeder --tls --ca /etc/kuksa/ca.crt

# mTLS with JWT token
./kuksa_feeder --tls --ca /etc/kuksa/ca.crt \
  --cert /etc/kuksa/client.crt --key /etc/kuksa/client.key \
  --token eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

> ⚠️ Never pass a non-loopback `--address` without `--tls`. The feeder will print a
> warning and the channel will transmit telemetry in plaintext.

### All CLI flags

| Flag | Default | Description |
|------|---------|-------------|
| `--can-if <name>` | `can1` | SocketCAN interface |
| `--address <host:port>` | `localhost:55555` | KUKSA databroker address |
| `--insecure` | *(default)* | Use insecure channel |
| `--tls` | — | Enable TLS |
| `--ca <path>` | — | Root CA certificate |
| `--cert <path>` | — | Client certificate (mTLS) |
| `--key <path>` | — | Client private key (mTLS) |
| `--token <jwt>` | — | JWT authorization token |
| `--help`, `-h` | — | Print usage |

### Expected Output

```
========================================
  KUKSA CAN Feeder Configuration
========================================
CAN Interface:    can1
KUKSA Address:    localhost:55555
Security Mode:    Insecure
========================================
[Publisher] Connected to KUKSA databroker at localhost:55555 (insecure)
[Feeder] Connected to KUKSA databroker.
[Feeder] Running. Press Ctrl+C to stop.
[Handler] Published Vehicle.Speed = 19.08 km/h (5.3 m/s)
[Handler] Published Vehicle.ControlUnit.STM32.Health.Resources.BatteryLevel = 87 %
[Handler] Published Vehicle.ControlUnit.STM32.Health.Resources.BatteryVoltage = 12.4 V
[Handler] Published Vehicle.Powertrain.Transmission.CurrentGear = 1 (raw=2)
[Handler] Published Vehicle.ControlUnit.STM32.Health.Resources.Temperature = 34.2 C
[Handler] Published Vehicle.ControlUnit.STM32.Health.Resources.Humidity = 52.1 %
[Handler] Published Vehicle.ControlUnit.Central.Health.Resources.BatteryLevel = 91 %
[Handler] Published Vehicle.ControlUnit.Central.Health.Resources.BatteryVoltage = 4.15 V
```

## Testing

### Send test CAN frames

```bash
sudo apt-get install can-utils

# Speed frame (0x100): 5.3 m/s as float LE → 0x4229999A
cansend can1 100#9A992942

# STM32 battery frame (0x200): 87% + 12.4V (float LE → 0x41469999)
cansend can1 200#579999464100000000

# RPi battery frame (0x210): 91% + 4.15V (float LE → 0x40851EB8)
cansend can1 210#5BB81E854000000000

# Gear frame (0x300): Drive (raw=2)
cansend can1 300#02

# Environment frame (0x400): 34.2°C + 52.1% humidity
# 34.2 float LE → 0x42091EB8, 52.1 float LE → 0x42503333
cansend can1 400#B81E0942333350420000000000000000
```

### Verify in KUKSA CLI

```bash
kuksa-client --protocol grpc --insecure
> get Vehicle.Speed
> get Vehicle.ControlUnit.STM32.Health.Resources.BatteryLevel
> get Vehicle.Powertrain.Transmission.CurrentGear
```

### Verify in Qt Dashboard

```bash
./myqtapp --kuksa
```

The dashboard subscribes to all VSS paths above via `KuksaReader` and updates the
speedometer, battery indicators, gear display, and health panels in real time.

## Adding a New Signal

### 1. Add the CAN ID — `inc/feeder/can_ids.hpp`

```cpp
constexpr uint32_t ID_NEW_SENSOR = 0x500;  // document payload layout here
```

### 2. Add the VSS path — `inc/feeder/signals.hpp`

```cpp
constexpr const char* NEW_SENSOR_VALUE = "Vehicle.Some.VssPath";
```

### 3. Add the handler — `inc/feeder/handlers.hpp` + `src/feeder/handlers.cpp`

```cpp
// handlers.hpp
void HandleNewSensor(const can_frame& frame, feeder::Publisher& publisher);

// handlers.cpp
void HandleNewSensor(const can_frame& frame, feeder::Publisher& publisher) {
    if (frame.can_dlc < 4) return;
    float value = can_decode::FloatLe(frame.data);
    publisher.PublishFloat(vss::NEW_SENSOR_VALUE, value);
}
```

### 4. Wire the dispatcher — `src/feeder/main.cpp`

```cpp
case can::ID_NEW_SENSOR:
    handlers::HandleNewSensor(frame, publisher);
    break;
```

### 5. Update `vss.json` and restart the databroker

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Path not found` on publish | VSS path missing from `vss.json` | Add entry + restart databroker |
| `No such device` on CAN open | Interface not up | `sudo ip link set can1 up` |
| `Failed to connect` / channel error | Databroker not running | `sudo systemctl start kuksa-databroker` |
| No CAN frames received | STM32 not transmitting or wrong interface | `candump can1` to verify traffic |
| `WARNING: insecure channel for non-loopback` | `--address` is a remote IP without `--tls` | Add `--tls --ca <path>` |

## Performance

- Average CAN → KUKSA publish latency: **~2 ms**
- OS scheduling spikes: up to ~37 ms (non-RTOS Linux)
- To reduce scheduling jitter on the RPi5: `nice -n -20 ./kuksa_feeder` (requires `cap_sys_nice` — see Permissions above)

## License

Apache-2.0 (matches KUKSA proto definitions)
