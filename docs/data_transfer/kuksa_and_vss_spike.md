# DrivaPi Architecture Spike #194: Native AGL Kuksa & C++ Integration

## 1. Executive Summary

This spike evaluates the architectural impact of replacing the current direct SocketCAN integration in **DrivaPi** with **Eclipse Kuksa Val (Databroker)**, moving `qt_app` from reading raw CAN frames via `QCanBus` to consuming normalized VSS signals. The proposed middleware abstracts hardware details behind the **Vehicle Signal Specification (VSS)** and a gRPC/HTTP‑2 API.[1][2][3]

**Constraint Checklist:**

- **No Docker:** Kuksa Databroker will be installed as a native system service via Yocto/BitBake (e.g., `meta-agl-kuksa-val`).[2]
- **No Python:** All integration components (Feeder and Client) will be developed in C++ using Qt 6.
- **Validation:** Performance validation is deferred and will empirically compare “Direct CANReader” vs. “Kuksa QtGrpc” latency on the target hardware using dedicated perf tooling.[4]

**Recommendation:** Proceed with design. VSS standardization (decoupling, simulation, interoperability) provides clear strategic benefits, and latency risk will be mitigated through a comparative benchmark before final merge.[5][6]

***

## 2. Strategic Analysis: Why Kuksa?

Moving from raw CAN to Kuksa adds IPC, serialization, and extra processes, but it aligns DrivaPi with SDV best practices and the COVESA VSS ecosystem.[7][1]

| Feature            | Raw CAN (Current)                                                                 | Kuksa VSS (Proposed)                                                                 | Value Add for DrivaPi                                                        |
|--------------------|------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|------------------------------------------------------------------------------|
| **Hardware Coupling** | High. UI knows CAN IDs (e.g., `0x100`); firmware changes require UI recompilation. | UI only knows `Vehicle.Speed`; Feeder translates CAN → VSS.                           | Decouples UI development from STM32 firmware and DBC changes.[8]       |
| **Simulation**     | Hard. Requires `vcan` and custom CAN frame injection.                             | Trivial. Just publish `Vehicle.Speed` to the broker via CLI or client.[9][10] | UI can be developed and tested without a hardware bench.                    |
| **Cloud Sync**     | Complex. Binary frames must be decoded and reshaped for cloud APIs.               | Native. VSS tree is structured data ideal for MQTT/telemetry and digital twin use.[11][12] | Enables analytics and remote monitoring with minimal glue code.             |
| **Interoperability** | Zero. Custom binary protocol.                                                    | High. Uses standard **COVESA VSS** taxonomy and units.[13][6]               | Future‑proofs the stack for other AGL/SDV apps (navigation, voice, etc.).   |

***

## 3. Architectural Design (Native AGL)

The system is split into **three native Linux processes** that communicate via local **gRPC over HTTP/2** to the Kuksa Databroker.[14][1]

### 3.1 Middleware (Kuksa Databroker)

- **Role:** “Single Source of Truth” for vehicle state, hosting the VSS data tree.
- **Implementation:** Rust `kuksa-databroker` binary installed via AGL package management (e.g., `meta-agl-kuksa-val`) and listening on a local gRPC port (commonly 55555 or 55556).[1][2]
- **Lifecycle:** Managed by `systemd` as `kuksa-databroker.service`, starting before Feeder and Dashboard.[14]

### 3.2 The Feeder (Southbound C++)

- **Role:** Gateway between the physical world (CAN) and the digital world (VSS).
- **Implementation:** New console‑only `QCoreApplication` that uses `QCanBus` to read frames from `can0` and QtGrpc to publish updates to the Databroker on localhost.[15][1]
- **Logic:** Decode CAN payloads, map them onto corresponding VSS paths (e.g., `Vehicle.Speed`), and send streaming updates over gRPC.

### 3.3 The Dashboard (Northbound C++)

- **Role:** Visualization only.
- **Implementation:** Refactored existing `qt_app`.
- **Logic:** Drops `CANReader` and uses QtGrpc to subscribe to VSS signals from Databroker, binding them into QML/Qt widgets (speed, SoC, etc.).[8][16]

***

## 4. VSS Schema Definition (drivapi.vss.json)

Existing members from `vehicledata.hpp` are mapped to VSS signals in `drivapi.vss.json`, which will be baked into the AGL image (e.g., `/etc/kuksa/drivapi.vss.json`).[6][13]

| C++ Variable       | Type    | Proposed VSS Path                                           | Unit  |
|--------------------|---------|-------------------------------------------------------------|-------|
| `m_speed`          | float   | `Vehicle.Speed`                                            | km/h  |
| `m_battery`        | int     | `Vehicle.Powertrain.TractionBattery.StateOfCharge`        | %     |
| `m_energy`         | double  | `Vehicle.Powertrain.TractionBattery.NetCapacity`          | kWh   |
| `m_gear`           | QString | `Vehicle.Powertrain.Transmission.CurrentGear`             | int8  |
| `m_temperature`    | int     | `Vehicle.Cabin.HVAC.AmbientAirTemperature`                | °C    |
| `m_distance`       | int     | `Vehicle.TraveledDistance`                                | km    |
| `m_autonomousMode` | bool    | `Vehicle.ADAS.Active`                                     | bool  |

VSS rules state that `Vehicle.Speed` should use km/h with a float datatype, which this mapping follows.[17][6]

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

Because the design moves from a zero‑copy in‑process flow to a multi‑process architecture, a dedicated latency comparison will measure the “cost of abstraction” once the C++ path is implemented.[4]

### 5.1 Test Setup (AGL Target)

Both implementations will be instrumented with microsecond‑precision timestamps on the target.

**Scenario A – Current (Baseline):**

1. `CANReader` receives a frame from the kernel (start timer \(T_0\)).
2. Signal is emitted and delivered to the UI slot.
3. `VehicleData` is updated (end timer \(T_1\)).

Latency A: \(\text{Latency}_A = T_1 - T_0\).

**Scenario B – Proposed (Kuksa):**

1. Feeder `QCanBus` receives a CAN frame (start timer \(T_0\)).
2. Feeder publishes the update via gRPC to Databroker.
3. Databroker processes and notifies subscribers.
4. Dashboard receives gRPC `OnUpdate` (end timer \(T_2\)).

Latency B: \(\text{Latency}_B = T_2 - T_0\).

### 5.2 Success Criteria

If \(\text{Latency}_B < \text{Latency}_A + 16\text{ ms}\) (one 60 Hz display frame), the architecture is considered acceptable for dashboard use.

***

## 6. Implementation Roadmap (Qt Refactoring)

The `qt_app` source requires specific refactoring to integrate with Kuksa via QtGrpc.[15][1]

### 6.1 Remove CANReader

- Remove `CANReader` (`canreader.cpp`) from the GUI application.
- Move CAN parsing logic into a standalone Feeder process; an initial implementation can be prototyped with a simple client to keep complexity low.

### 6.2 Update VehicleData to Use QtGrpc

`VehicleData` will initialize a gRPC client instead of parsing raw CAN payloads.

**Prerequisites:**

- Add `Qt::Grpc` and `Qt::Protobuf` to `CMakeLists.txt`.
- Generate C++ stubs from `kuksa/val/v1/val.proto` using the Qt Protobuf compiler, aligned with Databroker’s gRPC definitions.[1][15]

**Refactoring Logic:**

```cpp
// OLD (Pure CAN)
void VehicleData::handleCanMessage(const QByteArray &payload, uint32_t canId) {
    if (canId == SPEED_CAN_ID) {
        //... bitwise logic...
        setSpeed(value);
    }
}

// NEW (Kuksa gRPC)
void VehicleData::subscribeToSignals() {
    auto stream = m_client->Subscribe();
    SubscribeRequest request;
    // Add path "Vehicle.Speed"
    stream->writeMessage(request);

    connect(stream, &QGrpcHttp2Stream::messageReceived, this,
            [this](const SubscribeResponse &msg) {
        auto update = msg.updates().value("Vehicle.Speed");
        if (update.has_value()) {
             setSpeed(update.value().float_value());
        }
    });
}
```

### 6.3 Deployment Strategy (Docker)

For RPi5 development, Databroker can be deployed via Docker with the VSS schema mounted as metadata.[9][14]

```bash
docker run -d --name kuksa-databroker \
  -p 55555:55555 \
  -v $(pwd)/drivapi.vss.json:/etc/kuksa/drivapi.vss.json \
  ghcr.io/eclipse-kuksa/kuksa-databroker:master \
  --metadata /etc/kuksa/drivapi.vss.json
```

On production AGL, the same configuration is loaded by the native `kuksa-databroker` service instead of Docker.[3][2]

***

## 7. Risks & Mitigation

| Risk        | Impact | Mitigation                                                                                 |
|-------------|--------|--------------------------------------------------------------------------------------------|
| Complexity  | High   | Use `kuksa-client` style patterns and a minimal Feeder initially to reduce integration risk.[10][18] |
| Performance | Low    | Keep emergency stop and other safety‑critical actions on direct CAN/hardware paths.       |
| Stale Data  | Medium | Implement a VSS heartbeat signal; if it stops updating, the UI greys out or signals error. |

***

## 8. Next Steps

1. **Commit VSS:** Finalize `drivapi.vss.json` and push it to the repository as the canonical VSS schema.
2. **Feeder Spike:** Implement a small Feeder bridging `can0` to Databroker using the defined mappings.
3. **Qt Spike:** Create a branch of `qt_app`, remove `CANReader`, and implement a QtGrpc client for `Vehicle.Speed` as the first end‑to‑end signal.
4. **Latency Benchmark:** Run the comparative latency tests (Scenarios A and B) on the AGL target using microsecond logging and `kuksa-perf` to validate overhead.[4]

[1](https://github.com/eclipse-kuksa/kuksa-databroker)
[2](https://docs.digital.auto/docs/epic/runtime/reference/technical-reference/index.html)
[3](https://gitee.com/aricwang88/kuksa-databroker/blob/main/README.md?skip_mobile=true)
[4](https://github.com/eclipse-kuksa/kuksa-perf)
[5](https://www.w3.org/auto/wg/wiki/Vehicle_Signal_Specification_(VSS)/Vehicle_Data_Spec)
[6](https://covesa.github.io/vehicle_signal_specification/rule_set/data_entry/data_units/)
[7](https://wiki.covesa.global/download/attachments/364372/VSS%20Presentation.pdf?version=1&modificationDate=1463646083000&api=v2)
[8](https://wiki.covesa.global/download/attachments/78840403/VSS-in-vehicle-KUKSA-State.pdf?version=1&modificationDate=1697552147551&api=v2)
[9](https://eclipse-kuksa.github.io/kuksa-website/quickstart/)
[10](https://pypi.org/project/kuksa-client/0.4.0/)
[11](https://www.etas.com/ww/en/about-etas/newsroom/overview/security-audit-for-eclipse-kuksa-released/)
[12](https://www.semantic-web-journal.net/system/files/swj2085.pdf)
[13](https://covesa.global/vehicle-signal-specification/)
[14](https://github.com/eclipse-kuksa/kuksa-databroker/blob/main/doc/user_guide.md)
[15](https://eclipse.dev/velocitas/docs/tutorials/grpc_service_generation/)
[16](https://eclipse.dev/velocitas/docs/concepts/development_model/val/)
[17](https://covesa.github.io/vehicle_signal_specification/rule_set/data_entry/data_types/)
[18](https://pypi.org/project/kuksa-client/)
[19](https://ostif.org/wp-content/uploads/2024/05/Kuksaaudit1.2.pdf)
[20](https://github.com/eclipse-kuksa/kuksa-gps-provider)
[21](http://www.roylongbottom.org.uk/Raspberry%20Pi%205%20%20Benchmarks%20and%20Stress%20Tests.htm)
[22](https://www.makerhero.com/blog/raspberry-pi-5-benchmarks-em-diferentes-aplicacoes/)
[23](https://rpubs.com/harpomaxx/rpi5llm)
[24](https://github.com/COVESA/vehicle_signal_specification/issues/690)
[25](https://www.reddit.com/r/kubernetes/comments/1ad81mv/any_benchmarks_out_there_for_desktop_vs_raspberry/)
