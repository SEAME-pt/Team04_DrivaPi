# DrivaPi Architecture Spike #194: Native AGL Kuksa & C++ Integration

**Status:** Research & Design Phase
**Date:** December 05, 2025
**Context:** Migration from direct `QCanBus` to a standard “Data Broker” architecture using Eclipse Kuksa within the Automotive Grade Linux (AGL) environment.[1][2]

***

## 1. Executive Summary

This spike defines the theoretical architecture for integrating **Eclipse Kuksa Val (Databroker)** natively into the DrivaPi AGL image, replacing the current monolithic approach where the Qt UI talks directly to the CAN bus. The proposed design introduces a standardized middleware layer around a VSS-based data broker to decouple UI and firmware.[3][4]

**Constraint Checklist:**

- **No Docker:** Kuksa Databroker runs as a native system service via Yocto/BitBake (e.g., `kuksa-databroker-agl` in an AGL layer).[5][3]
- **No Python:** All integration components (Feeder and Client) are written in C++ using Qt 6.
- **Validation:** Performance validation is deferred; a later phase will empirically compare “Direct CANReader” vs. “Kuksa QtGrpc” latency on target hardware.[6]

**Recommendation:** Proceed with Design.
The strategic benefits of VSS standardization (decoupling from CAN, easier simulation, interoperability) outweigh the added complexity, and latency risk will be controlled via a comparative benchmark before merge.[7][8]

***

## 2. Strategic Analysis: Why Kuksa?

Moving from raw CAN to Kuksa adds IPC boundaries, serialization, and an extra process, but it aligns DrivaPi with open VSS-based in-vehicle data models.[4][9]

| Feature            | Raw CAN (Current)                                                                 | Kuksa VSS (Proposed)                                                              | Value Add for DrivaPi                                                       |
|--------------------|------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| **Hardware Coupling** | High. UI knows CAN IDs (0x100); any firmware change forces UI recompilation.      | UI only knows `Vehicle.Speed`; Feeder maps CAN → VSS paths.                       | Decouples UI development from STM32 firmware and DBC changes.[1]      |
| **Simulation**     | Hard. Needs `vcan` plus custom CAN frame injection.                               | Trivial. Publish `Vehicle.Speed` into the Databroker via CLI or script.           | Lets UI team work without a physical hardware bench.[10]                |
| **Cloud Sync**     | Complex. Binary frames must be decoded and reshaped for cloud APIs.               | Native. VSS tree is structured JSON-like data suitable for MQTT/telemetry.[11] | Enables “Digital Twin” and analytics features with minimal glue.           |
| **Interoperability** | Zero. Custom binary protocol.                                                    | High. Uses **COVESA VSS** taxonomy shared across projects.[8][7]       | Future‑proofs stack for other AGL/SDV apps (navigation, voice, etc.).      |

***

## 3. Architectural Design (Native AGL)

The system is split into **three native Linux processes** communicating over local **gRPC on HTTP/2** to the Kuksa Databroker.[10][4]

### 3.1 Middleware (Kuksa Databroker)

- **Role:** Acts as the “Single Source of Truth” for vehicle state, hosting the VSS tree.
- **Implementation:** Rust `kuksa-databroker` binary integrated via an AGL/Yocto recipe (e.g., `kuksa-databroker-agl` in `meta-agl-demo` or related layers).[3][1]
- **Lifecycle:** Managed by `systemd` as `kuksa-databroker.service`, exposing gRPC endpoints defined in `.proto` files.[4]

### 3.2 The Feeder (Southbound C++)

- **Role:** Gateway between physical CAN and VSS signals in the Databroker.
- **Implementation:** New console-only `QCoreApplication` (e.g., `can-feeder`).
- **Logic:** Uses `QCanBus`/`QCanBusDevice` to read `can0` frames and QtGrpc client stubs to publish VSS updates to the Databroker on `localhost`.[12][10]

### 3.3 The Dashboard (Northbound C++)

- **Role:** Visualization-only Qt UI.
- **Implementation:** Refactored existing `qt_app`.
- **Logic:** Removes `CANReader` and uses QtGrpc to subscribe to VSS signals from the Databroker, binding them into QML/Qt widgets.

***

## 4. VSS Schema Definition (drivapi.vss.json)

Existing C++ members from `vehicledata.hpp` are mapped to standard VSS signals, forming `drivapi.vss.json` baked into the AGL image (e.g., `/etc/kuksa/drivapi.vss.json`).[2][8]

| C++ Variable  | Type    | Proposed VSS Path                                           | Unit |
|--------------|---------|-------------------------------------------------------------|------|
| `m_speed`    | float   | `Vehicle.Speed`                                            |  m/s |
| `m_battery`  | int     | `Vehicle.Powertrain.TractionBattery.StateOfCharge`        | %    |
| `m_energy`   | double  | `Vehicle.Powertrain.TractionBattery.NetCapacity`          | kWh  |
| `m_gear`     | QString | `Vehicle.Powertrain.Transmission.CurrentGear`             | int8 |
| `m_temperature` | int  | `Vehicle.Cabin.HVAC.AmbientAirTemperature`                | °C   |
| `m_autonomousMode` | bool | `Vehicle.ADAS.Active`                                   | bool |

VSS explicitly defines `Vehicle.Speed` as a `float` sensor with unit `km/h`, matching this mapping.[13][14]

***

## 5. Future Validation Strategy: Comparative Latency Test

The move from an in‑process, zero‑copy design to a multi‑process design requires quantifying the additional latency, i.e., the “Cost of Abstraction”. This will be done once the C++ path via QtGrpc is implemented.[6]

### 5.1 Test Setup (AGL Target)

Both implementations will log microsecond‑precision timestamps on the target system.

**Scenario A (Current – Baseline):**

1. `CANReader` receives frame from kernel (start timer \(T_0\)).
2. Signal emitted → slot invoked in UI thread.
3. `VehicleData` is updated (end timer \(T_1\)).

Latency A: $\(\text{Latency}_A = T_1 - T_0\)$.

**Scenario B (Proposed – Kuksa):**

1. Feeder `QCanBus` receives frame (start timer \(T_0\)).
2. Feeder sends gRPC Publish to Databroker.
3. Kuksa processes message and notifies subscribers.
4. Dashboard receives gRPC `OnUpdate` (end timer \(T_2\)).

Latency B: $\(\text{Latency}_B = T_2 - T_0\)$.

### 5.2 Success Criteria

Overhead is acceptable if $\(\text{Latency}_B < \text{Latency}_A + 16\text{ ms}\)$, corresponding to one 60 Hz display frame, meaning the added broker layer remains visually imperceptible.

***

## 6. Implementation Roadmap

### Phase 1: AGL Image Configuration (Yocto)

The AGL build must be extended to include the native Kuksa service.

- Edit `conf/local.conf` or the image recipe.
- Ensure the `meta-agl-kuksa-val` / demo layer that carries the Databroker recipe is included.[5][3]
- Add to the image configuration:

  ```bitbake
  IMAGE_INSTALL:append = " kuksa-databroker kuksa-client"
  ```

- Define a `.bbappend` to install `drivapi.vss.json` into `/etc/kuksa/`, aligning with existing AGL+Kuksa demos.[1][2]

### Phase 2: The C++ Feeder (can-feeder)

Create a simple `QCoreApplication` that bridges CAN frames to VSS data points.

- **Input:** `QCanBusDevice` reading from `can0`, reusing existing CAN decoding where possible.
- **Output:** QtGrpc client to Kuksa Databroker.
- **Note:** Use `qt_add_grpc` and `qt_add_protobuf` in CMake to generate C++ client code from `kuksa/val/v1/val.proto`.[15][16]

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
- Add `find_package(Qt6 COMPONENTS Grpc Protobuf)` to `CMakeLists.txt` and link generated stubs.[17][15]
- Update `VehicleData` constructor to create a QtGrpc channel to `localhost:55555` (or the configured Databroker port) and subscribe to `Vehicle.Speed`.

***

## 7. Risks

- **Build Time:** Adding Rust-based Kuksa components into a Yocto/AGL pipeline can noticeably increase build times due to Rust toolchain and dependencies.[18][1]
- **Qt Version:** The Qt GRPC module was introduced in Qt 6.5 (Tech Preview) and matured by later 6.x releases; the chosen AGL baseline must provide a Qt 6 build with QtGrpc and QtProtobuf available.[19][16]

[1](https://archive.fosdem.org/2024/events/attachments/fosdem-2024-2842-vehicle-abstraction-in-automotive-grade-linux-with-eclipse-kuksa/slides/22324/Vehicle_Abstraction_in_AGL_with_Eclipse_KUKSA_1MvE4AB.pdf)
[2](https://www.konsulko.com/portfolio-item/evolving-vss-usage-agl)
[3](https://layers.openembedded.org/layerindex/recipe/396482/)
[4](https://github.com/eclipse-kuksa/kuksa-databroker)
[5](https://wiki.automotivelinux.org/eg-v2c)
[6](https://github.com/eclipse-kuksa/kuksa-perf)
[7](https://covesa.global/project/vehicle-signal-specification/)
[8](https://covesa.global/vehicle-signal-specification/)
[9](https://sdv.eclipse.org/sdv-contribution-day-sept-2022/slides/07-eclipse-kuksa.pdf)
[10](https://eclipse.dev/velocitas/docs/concepts/development_model/val/)
[11](https://eclipse-kuksa.github.io/kuksa-website/categories/use-cases/)
[12](https://eclipse.dev/velocitas/docs/tutorials/grpc_service_generation/)
[13](https://covesa.github.io/vehicle_signal_specification/rule_set/data_entry/data_units/)
[14](https://covesa.github.io/vehicle_signal_specification/rule_set/data_entry/data_types/)
[15](https://doc.qt.io/qt-6.5/qtgrpc-index.html)
[16](https://doc.qt.io/qt-6/qtgrpc-module.html)
[17](https://doc.qt.io/qt-6/qtgrpc-index.html)
[18](https://static.sched.com/hosted_files/aglammspring2023/8f/VSS%20and%20KUKSA.val%20in%20AGL.pdf)
[19](https://www.ics.com/blog/whats-new-qt-65)
[20](https://qt.developpez.com/doc/6.7/whatsnew65/)
[21](https://github.com/COVESA/vehicle_signal_specification/blob/master/spec/units.yaml)
[22](https://github.com/eclipse-leda/leda-distro)
