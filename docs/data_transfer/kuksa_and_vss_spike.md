# DrivaPi Architecture Spike #194: Native AGL Kuksa & C++ Integration

## 1. Executive Summary

This spike evaluates the architectural impact of replacing the current direct SocketCAN integration in **DrivaPi** with **Eclipse Kuksa Val (Databroker)**. Currently, the application (`qt_app`) reads raw CAN frames directly via `QCanBus`. The proposed architecture introduces a middleware layer (Kuksa) to abstract hardware specifics using the **Vehicle Signal Specification (VSS)**.

**Constraint Checklist:**

- **No Docker:** Kuksa Databroker will be installed as a native system service via Yocto/BitBake.
- **No Python:** All integration components (Feeder and Client) will be developed in C++ using Qt 6.
- **Validation:** Performance validation is deferred to a future phase where the latency of the “Direct CANReader” vs. “Kuksa QtGrpc” implementations will be empirically compared on the target hardware.

**Recommendation:** Proceed with design. The strategic benefits of VSS standardization (decoupling, simulation capability) outweigh the implementation complexity, and latency risk will be managed via a comparative benchmark before final merge.

***

## 2. Strategic Analysis: Why Kuksa?

Moving from raw CAN to Kuksa adds complexity (IPC, serialization, extra processes). Why is this the right choice for DrivaPi?

| Feature            | Raw CAN (Current)                                                                 | Kuksa VSS (Proposed)                                                        | Value Add for DrivaPi                                                |
|--------------------|------------------------------------------------------------------------------------|----------------------------------------------------------------------------|----------------------------------------------------------------------|
| **Hardware Coupling** | High. UI knows CAN IDs (0x100). If firmware changes, UI must be recompiled.      | None. UI knows `Vehicle.Speed`. Feeder handles the translation.            | Decouples UI development from STM32 firmware development.           |
| **Simulation**     | Hard. Requires `vcan` kernel modules and CAN frame injection.                     | Trivial. Just publish `Vehicle.Speed` to the broker via CLI or script.     | Allows UI team to work without hardware bench.                      |
| **Cloud Sync**     | Complex. Must decode binary frames before sending to cloud.                       | Native. VSS tree is already structured data (JSON-like) ready for MQTT/Cloud. | Enables “Digital Twin” features out of the box.                    |
| **Interoperability** | Zero. Custom binary protocol.                                                    | High. Standard COVESA VSS taxonomy.                                        | Future-proofs the stack for other AGL apps (e.g., Navigation, Voice). |

***

## 3. Architectural Design (Native AGL)

The system is split into three native Linux processes communicating via local gRPC over HTTP/2.

### 3.1 Middleware (Kuksa Databroker)

- **Role:** The “Single Source of Truth” for vehicle state.
- **Implementation:** Rust binary installed via AGL package management (`meta-agl-kuksa-val`).
- **Lifecycle:** Managed by `systemd` (`kuksa-databroker.service`).

### 3.2 The Feeder (Southbound C++)

- **Role:** Gateway between the physical world (CAN) and the digital world (VSS).
- **Implementation:** A new console-only `QCoreApplication`.
- **Logic:** Uses `QCanBus` to read frames and QtGrpc to publish to `localhost`.

### 3.3 The Dashboard (Northbound C++)

- **Role:** Visualization only.
- **Implementation:** The existing `qt_app`, refactored.
- **Logic:** Drops `CANReader`. Uses QtGrpc to subscribe to signals.

***

## 4. VSS Schema Definition (drivapi.vss.json)

We map the existing C++ member variables from `vehicledata.hpp` to standard VSS signals. This JSON file will be baked into the AGL image (typically at `/etc/kuksa/drivapi.vss.json`).

| C++ Variable       | Type    | Proposed VSS Path                                           | Unit |
|--------------------|---------|-------------------------------------------------------------|------|
| `m_speed`          | float   | `Vehicle.Speed`                                            | km/h |
| `m_battery`        | int     | `Vehicle.Powertrain.TractionBattery.StateOfCharge`        | %    |
| `m_energy`         | double  | `Vehicle.Powertrain.TractionBattery.NetCapacity`          | kWh  |
| `m_gear`           | QString | `Vehicle.Powertrain.Transmission.CurrentGear`             | int8 |
| `m_temperature`    | int     | `Vehicle.Cabin.HVAC.AmbientAirTemperature`                | °C   |
| `m_distance`       | int     | `Vehicle.TraveledDistance`                                | km   |
| `m_autonomousMode` | bool    | `Vehicle.ADAS.Active`                                     | bool |

**Draft Schema Artifact:**

```json
{
  "Vehicle": {
    "children": {
      "Speed": { "datatype": "float", "type": "Sensor", "unit": "km/h" },
      "TraveledDistance": { "datatype": "float", "type": "Sensor", "unit": "km" },
      "Powertrain": {
        "children": {
          "TractionBattery": {
            "children": {
              "StateOfCharge": { "datatype": "float", "type": "Sensor", "unit": "percent" },
              "NetCapacity": { "datatype": "float", "type": "Sensor", "unit": "kWh" }
            }
          },
          "Transmission": {
            "children": {
              "CurrentGear": { "datatype": "int8", "type": "Sensor" }
            }
          }
        }
      },
      "ADAS": {
        "children": {
          "Active": { "datatype": "boolean", "type": "Actuator", "description": "DrivaPi Auto-Pilot State" }
        }
      }
    }
  }
}
```

***

## 5. Future Validation Strategy: Comparative Latency Test

Since we are moving from a zero-copy (in-process) design to a multi-process design, we must measure the “Cost of Abstraction.” This test will be performed once the C++ implementation is ready.

### 5.1 Test Setup (AGL Target)

Both versions of the application will be instrumented to log microsecond-precision timestamps.

**Scenario A (Current – Baseline):**

1. `CANReader` receives frame from kernel (start timer \(T_0\)).
2. Signal emitted → slot called in UI thread.
3. Value updated in `VehicleData` (end timer \(T_1\)).

Latency A: \(\text{Latency}_A = T_1 - T_0\).

**Scenario B (Proposed – Kuksa):**

1. Feeder `QCanBus` receives frame (start timer \(T_0\)).
2. Feeder sends gRPC Publish.
3. Kuksa processes message and notifies subscribers.
4. Dashboard receives gRPC `OnUpdate` (end timer \(T_2\)).

Latency B: \(\text{Latency}_B = T_2 - T_0\).

### 5.2 Success Criteria

Acceptable overhead: if \(\text{Latency}_B < \text{Latency}_A + 16\text{ ms}\) (1 frame at 60 Hz), the architecture is approved.

***

## 6. Implementation Roadmap

### Phase 1: AGL Image Configuration (Yocto)

We need to modify the AGL build to include the native Kuksa service.

- Edit `conf/local.conf` or the image recipe.
- Ensure `meta-agl-kuksa-val` layer is included.
- Add:

  ```bitbake
  IMAGE_INSTALL:append = " kuksa-databroker kuksa-client"
  ```

- Define a `.bbappend` to install the custom `drivapi.vss.json` into `/etc/kuksa/`.

### Phase 2: The C++ Feeder (can-feeder)

Create a simple `QCoreApplication` that bridges CAN to VSS.

- **Input:** Use `QCanBusDevice` (reuse logic from `CANReader`).
- **Output:** Use QtGrpc.
- **Note:** Generate the C++ gRPC client code using `qt_add_grpc` in CMake against `kuksa/val/v1/val.proto`.

**Conceptual C++ Feeder Logic:**

```cpp
// In Feeder::onCanFrame(const QCanBusFrame &frame)
if (frame.frameId() == 0x100) {
    float speed = parseSpeed(frame);
    // Create gRPC request
    PublishRequest req;
    auto entry = req.add_entries();
    entry->set_path("Vehicle.Speed");
    entry->mutable_value()->set_float_value(speed);
    // Send to Databroker via QtGrpc
    m_grpcClient->Publish(req);
}
```

### Phase 3: The Dashboard Refactoring

- Remove `canreader.cpp` and `canreader.hpp` from `qt_app`.
- Add `find_package(Qt6 COMPONENTS Grpc Protobuf)` to `CMakeLists.txt`.
- Update `VehicleData` constructor to initialize a QtGrpc channel to `localhost:55555` and subscribe to `Vehicle.Speed`.

***

## 7. Risks & Mitigation

| Risk        | Impact | Mitigation                                                                 |
|-------------|--------|----------------------------------------------------------------------------|
| Complexity  | High   | Use `kuksa-client` (Python) for the Feeder initially to keep complexity low. |
| Performance | Low    | Keep “Emergency Stop” functionality on direct CAN/Hardware lines (bypass Kuksa). |
| Stale Data  | Medium | Implement a “Heartbeat” signal in VSS. If heartbeat stops, the UI greys out. |

***

## 8. Next Steps

1. Commit VSS: Finalize `drivapi.vss.json` and push to repo.
2. Feeder Spike: Write a ~50-line Python script using `python-can` and `kuksa-client` to bridge `can0` to the broker.
3. Qt Spike: Create a branch of `qt_app`, strip `CANReader`, and implement a QtGrpc client for just the `Vehicle.Speed` signal.
