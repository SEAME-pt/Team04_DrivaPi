DrivaPi Architecture Spike #194: Eclipse Kuksa Val & VSS Integration

Status: Draft

Date: December 03, 2025

Context: Migration from "Pure CAN" (Direct QCanBus) to "Data Broker" (Kuksa VSS).

1. Executive Summary
This spike evaluates the architectural impact of replacing the current direct SocketCAN integration in DrivaPi with Eclipse Kuksa Val (Databroker).
Recommendation: [TBD]

2. Problem Statement & Comparison
2.1 Current State ("Pure CAN")
Your current architecture allows the Qt application to act as both the Consumer (UI) and the Driver (CAN Reader).

* Implementation: CANReader class (in canreader.cpp) accesses socketcan directly.

* Coupling: VehicleData::handleCanMessage contains hardcoded decoding logic (e.g., SPEED_CAN_ID = 0x100, memcpy for float conversion).

* Pros: Extremely low latency (<0.1ms), simple deployment (single binary).

* Cons: "DBC Hell." Changing a sensor on the STM32 requires recompiling the Qt dashboard. The UI logic is tightly coupled to the wire protocol.

2.2 Proposed State (Kuksa VSS)
The architecture splits into two distinct components:

1. The Feeder (Backend): A background service (C++, Rust, or Python) that reads socketcan and publishes to Kuksa.

2. The Dashboard (Frontend): The Qt application uses gRPC to subscribe to standardized VSS signals (e.g., Vehicle.Speed).

* Pros: The Qt app never sees a CAN ID. It only knows Vehicle.Speed. You can swap the STM32 for a Simulation or a different ECU without touching the UI code.

* Cons: Requires running the Kuksa Databroker container; increases RAM usage by ~10-20MB.

3. VSS Schema Definition (drivapi.vss.json)

4. Performance & Latency Analysis

5. Implementation Roadmap (Qt Refactoring)

6. Risks & Mitigation

7. Next Steps
