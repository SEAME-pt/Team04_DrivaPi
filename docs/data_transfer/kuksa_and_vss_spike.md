# DrivaPi Architecture Spike #194: Native AGL Kuksa & C++ Integration

**Status:** Research & Design Phase
**Date:** December 05, 2025
**Context:** Migration from direct `QCanBus` to a standard “Data Broker” architecture using Eclipse Kuksa within the Automotive Grade Linux (AGL) environment.

***

## 1. Executive Summary

This spike defines the theoretical architecture for integrating **Eclipse Kuksa Val (Databroker)** natively into the DrivaPi AGL image. Unlike the current monolithic approach where the Qt UI directly accesses the CAN bus, the proposed architecture introduces a standardized middleware layer based on **VSS (Vehicle Signal Specification)**.[1][2]

**Constraint Checklist:**

- **No Docker:** Kuksa Databroker will be installed as a native system service via Yocto/BitBake.
- **No Python:** All integration components (Feeder and Client) will be developed in C++ using Qt 6.
- **Validation:** Performance validation is deferred to a future phase, where the latency of “Direct CANReader” vs. “Kuksa QtGrpc” will be empirically compared on the target hardware.[3]

**Recommendation: Proceed with Kuksa Integration.**
The strategic benefits of VSS standardization (decoupling, simulation capability) outweigh the implementation complexity. Latency risk will be managed via a comparative benchmark before final merge.[2][4]

***

## 2. Strategic Analysis: Why Kuksa?

Moving from raw CAN to Kuksa adds complexity (IPC, serialization, extra processes), but it aligns DrivaPi with modern SDV and VSS-based architectures.[5][1]

| Feature            | Raw CAN (Current)                                                                 | Kuksa VSS (Proposed)                                                              | Value Add for DrivaPi                                                       |
|--------------------|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| **Hardware Coupling** | High. UI knows CAN IDs (0x100). Firmware changes require UI recompilation.        | UI only knows `Vehicle.Speed`; Feeder handles CAN–VSS translation.                | Decouples UI development from STM32 firmware evolution.                    |
| **Simulation**     | Hard. Requires `vcan` modules and CAN frame injection.                            | Easy. Publish `Vehicle.Speed` to the broker via CLI or script.                    | UI team can work without a hardware bench.                                 |
| **Cloud Sync**     | Complex. Binary CAN frames must be decoded before cloud upload.                   | Native. VSS tree is structured JSON-like data ready for MQTT/Cloud pipelines.[6] | Enables “Digital Twin” and telemetry features out of the box.              |
| **Interoperability** | Zero. Custom binary protocol.                                                    | High. Standard **COVESA VSS** taxonomy.[7][4]                           | Future‑proofs the stack for other AGL apps (navigation, voice, etc.).      |

***

## 3. Architectural Design (Native AGL)

The system is split into **three native Linux processes** communicating via local **gRPC over HTTP/2**.[8][1]

### 3.1 Middleware (Kuksa Databroker)

- **Role:** “Single Source of Truth” for vehicle state, owning the VSS data tree.
- **Implementation:** Rust binary installed via AGL package management (`meta-agl-kuksa-val`).[5]
- **Lifecycle:** Managed by `systemd` as `kuksa-databroker.service`.

### 3.2 The Feeder (Southbound C++)

- **Role:** Gateway between the physical world (CAN) and the digital world (VSS).
- **Implementation:** New console-only `QCoreApplication`.
- **Logic:** Uses `QCanBus` to read CAN frames and QtGrpc to publish updates to the Databroker on `localhost`.

### 3.3 The Dashboard (Northbound C++)

- **Role:** Visualization only.
- **Implementation:** Existing `qt_app`, refactored.
- **Logic:** Removes `CANReader` and uses QtGrpc to subscribe to VSS signals.

***

## 4. VSS Schema Definition (drivapi.vss.json)

Existing C++ members in `vehicledata.hpp` are mapped to standard VSS signals. The resulting JSON file is baked into the AGL image (typically at `/etc/kuksa/drivapi.vss.json`).[4][7]

| C++ Variable       | Type    | Proposed VSS Path                                           | Unit |
|--------------------|---------|-------------------------------------------------------------|------|
| `m_speed`          | float   | `Vehicle.Speed`                                            | km/h |
| `m_battery`        | int     | `Vehicle.Powertrain.TractionBattery.StateOfCharge`        | %    |
| `m_energy`         | double  | `Vehicle.Powertrain.TractionBattery.NetCapacity`          | kWh  |
| `m_gear`           | QString | `Vehicle.Powertrain.Transmission.CurrentGear`             | int8 |
| `m_temperature`    | int     | `Vehicle.Cabin.HVAC.AmbientAirTemperature`                | °C   |
| `m_autonomousMode` | bool    | `Vehicle.ADAS.Active`                                     | bool |

This follows VSS data type and unit recommendations for speed, SoC, and related signals.[9][4]

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
          "Active": {
            "datatype": "boolean",
            "type": "Actuator",
            "description": "DrivaPi Auto-Pilot State"
          }
        }
      }
    }
  }
}
```

***

## 5. Future Validation Strategy: Comparative Latency Test

Because the design moves from a zero-copy, in‑process flow to a multi‑process one, a dedicated latency comparison will quantify the “Cost of Abstraction.”[3]

### 5.1 Test Setup (AGL Target)

Both implementations will log microsecond‑precision timestamps.

**Scenario A (Current – Baseline):**

1. `CANReader` receives frame from kernel (start timer \(T_0\)).
2. Signal emitted → slot called in UI thread.
3. `VehicleData` value updated (end timer \(T_1\)).

Latency A: \(\text{Latency}_A = T_1 - T_0\).

**Scenario B (Proposed – Kuksa):**

1. Feeder `QCanBus` receives frame (start timer \(T_0\)).
2. Feeder sends gRPC Publish.
3. Kuksa processes message and notifies subscribers.
4. Dashboard receives gRPC `OnUpdate` (end timer \(T_2\)).

Latency B: \(\text{Latency}_B = T_2 - T_0\).

### 5.2 Success Criteria

If \(\text{Latency}_B < \text{Latency}_A + 16\text{ ms}\) (one 60 Hz frame), the architecture is considered acceptable for dashboard use.

***

## 6. Implementation Roadmap

### Phase 1: AGL Image Configuration (Yocto)

The AGL build must be extended to include the native Kuksa service.

- Edit `conf/local.conf` or the image recipe.
- Ensure the `meta-agl-kuksa-val` layer is included.
- Add:

  ```bitbake
  IMAGE_INSTALL:append = " kuksa-databroker kuksa-client"
  ```

- Create a `.bbappend` to install `drivapi.vss.json` into `/etc/kuksa/`.[5]

### Phase 2: The C++ Feeder (can-feeder)

Create a simple `QCoreApplication` to bridge CAN to VSS.

- **Input:** `QCanBusDevice` (reuse parsing logic from `CANReader`).
- **Output:** QtGrpc client.
- **Note:** Generate C++ gRPC client code using `qt_add_grpc` in CMake against `kuksa/val/v1/val.proto`.[10]

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
- Update `VehicleData` to initialize a QtGrpc channel to `localhost:55555` and subscribe to `Vehicle.Speed`.

***

## 7. Risks

- **Build Time:** Adding Rust‑based Kuksa components into the Yocto build can significantly increase compile times due to additional toolchains and dependencies.[11][12]
- **Qt Version:** QtGrpc was introduced in Qt 6.5 (Tech Preview) and stabilized around Qt 6.7, so the AGL baseline must provide a compatible Qt 6 version.[10]

[1](https://github.com/eclipse-kuksa/kuksa-databroker)
[2](https://www.w3.org/auto/wg/wiki/Vehicle_Signal_Specification_(VSS)/Vehicle_Data_Spec)
[3](https://github.com/eclipse-kuksa/kuksa-perf)
[4](https://covesa.github.io/vehicle_signal_specification/rule_set/data_entry/data_units/)
[5](https://docs.digital.auto/docs/epic/runtime/reference/technical-reference/index.html)
[6](https://www.etas.com/ww/en/about-etas/newsroom/overview/security-audit-for-eclipse-kuksa-released/)
[7](https://covesa.global/vehicle-signal-specification/)
[8](https://github.com/eclipse-kuksa/kuksa-databroker/blob/main/doc/user_guide.md)
[9](https://covesa.github.io/vehicle_signal_specification/rule_set/data_entry/data_types/)
[10](https://eclipse.dev/velocitas/docs/tutorials/grpc_service_generation/)
[11](https://stackoverflow.com/questions/77450784/need-help-to-build-kuksa-databroker-for-aarch64-or-for-arm64)
[12](https://ostif.org/wp-content/uploads/2024/05/Kuksaaudit1.2.pdf)
