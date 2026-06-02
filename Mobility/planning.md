# PLANNING.md: Emergency Vehicle Priority (EVP) V2X Project

## 1. Project Overview & Scope
This project implements an **Emergency Vehicle Preemption (EVP)** and **Vehicle-to-Vehicle (V2V) Coordination** mobility scenario. The goal is to build a micro-intersection simulation where an approaching priority vehicle communicates with a Roadside Unit (RSU) to force a green light corridor, while simultaneously broadcasting geofenced alerts to connected consumer vehicles (simulated via the PiRacer/STM32 stack) instructing them to clear the lane.

### Technical Pillars
1. **Signal Intelligence:** Real-world RF capturing and protocol reverse-engineering of local intersection signaling using an OpenSourceSDRLab HackRF One (R10C).
2. **V2X Communication Layer:** Emulated using an MQTT message broker processing JSON payloads structured after standardized SRM (Signal Request) and DENM (Decentralized Environmental Notification) architectures.
3. **Edge Control Loop:** Low-level execution on the STM32 MCU to handle real-time sensor processing, vehicle actuation, and automated lane-clearing maneuvers upon receiving V2X alerts.

---

## 2. Milestone Roadmap & Timeline

| Phase | Focus Area | Key Deliverables | Target Date | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Phase 1** | Requirements & Emulation | TSF Requirements PR, Mock Python MQTT simulators | June 2 – June 10 | 🔄 Active |
| **Phase 2** | SDR Signal Hunting | Hardware delivery, field capturing in Porto, signal analysis | June 11 – June 18 | ⏳ Pending |
| **Phase 3** | Target Integration | STM32 control loop implementation, PiRacer maneuver logic | June 19 – June 26 | ⏳ Pending |
| **Phase 4** | Verification & TSF | Automated test coverage execution, final code traceability | June 27 – Module End | ⏳ Pending |

---


## 3. System Architecture & Data Flow

    [ Priority Vehicle ] --(SRM via MQTT/SDR)--> [ Roadside Unit (RSU) ]
                                                        |
             +------------------------------------------+------------------------------------------+
             |                                                                                     |
             v                                                                                     v
    [ Traffic Light Phase ]                                                               [ V2X Alert Broadcast ]
    - Forces target lane GREEN                                                            - MQTT Topic: `v2x/intersection/alerts`
    - Truncates conflicting lanes RED                                                     - Payload: Geofenced Evacuation Zone
                                                                                                   |
                                                                                                   v
                                                                                          [ Connected Car (PiRacer) ]
                                                                                          - STM32 parses DENM payload
                                                                                          - Verifies path intersection
                                                                                          - Triggers automated lane evasion

### Data Contracts (MQTT Payloads)




## V2X Network Architecture & MQTT Integration Guide

This document outlines the Hardware-in-the-Loop (HIL) communication infrastructure for the Emergency Vehicle Priority (EVP) system simulation.

### A. Network Topology

The system bypasses direct node-to-node communication by utilizing a centralized **Publish/Subscribe (Pub/Sub)** architecture mediated by an MQTT Broker.

```text
       +------------------------------------+
       |       Central MQTT Broker          |
       |  (Mosquitto on Local Lab Laptop)   |
       +-----------------+----------+-------+
                         ^          |
    v2x/priority_vehicle/srm        | v2x/intersection/alerts
                         |          v
         +---------------+----------+---------------+
         |                                          |
+--------+-----------+                    +---------v---------+
|  Ghost Ambulance   |                    |    PiRacer Car    |
| (Software Node)    |                    | (Physical Vehicle)|
+--------------------+                    +-------------------+
         ^                                          |
         | (Calculates Virtual Coordinates)         | (Triggers GPIO Brake)
+--------+-----------+                              v
|   RSU Controller   |                    +-------------------+
| (Laptop + Microbit)|                    |   STM32 Control   |
+--------------------+                    +-------------------+

```

#### Node Network Profiles

* **MQTT Broker:** Runs on the host lab laptop. Acts as the central network router.
* **Ghost Ambulance:** Local software client simulating an approaching emergency vehicle.
* **RSU Controller:** Local script processing spatial math and actuating physical traffic lights via Micro:bit.
* **PiRacer:** Embedded edge client (Raspberry Pi 4) connected via the lab's local Wi-Fi network.

---

### B. Broker & Connection Configurations

To allow physical hardware (PiRacer) to communicate with your local scripts, the broker must be configured to listen on all interfaces, not just localhost.

#### Mosquitto Configuration (`mosquitto.conf`)

By default, Mosquitto blocks external connections. Modify your local configuration file to include:

```ini
listener 1883 0.0.0.0
allow_anonymous insecure

```

#### Network Parameter Matrix

| Parameter | Value | Scope | Description |
| --- | --- | --- | --- |
| **Broker IP** | `192.168.1.X` | Lab Local WLAN | The IPv4 address of the host laptop running Mosquitto. |
| **Port** | `1883` | Global | Default unencrypted MQTT listening port. |
| **Keepalive** | `60 seconds` | Client-side | Maximum interval before checking if the client is still alive. |

---

### C. Topic Topology & Data Contracts

Nodes interact dynamically using specific messaging paths. Messages utilize lightweight serialized JSON structures to mirror real C-V2X (Cellular V2X) communication payloads.

#### Topic 1: `v2x/priority_vehicle/srm`

* **Direction:** Ghost Ambulance $\rightarrow$ MQTT Broker $\rightarrow$ RSU Controller
* **Payload Schema:**

```json
{
  "vehicle_id": "AMB_01",
  "type": "AMBULANCE",
  "latitude": 41.178000,
  "longitude": -8.598000,
  "status": "EMERGENCY_ACTIVE",
  "signature": "8f3a2c..."
}

```

#### Topic 2: `v2x/intersection/alerts`

* **Direction:** RSU Controller $\rightarrow$ MQTT Broker $\rightarrow$ Connected Car (PiRacer)
* **Payload Schema:**

```json
{
  "rsu_id": "RSU_NORTH_01",
  "alert_type": "EVACUATION_ZONE",
  "radius_cm": 50,
  "action": "CLEAR_INTERSECTION",
  "timestamp": 1717367402
}

```

---

### D. Initialization and Lifecycle Sequence

To execute a test run on the physical track, follow this exact node activation sequence to prevent socket dropped errors:

```text
[Broker Setup]     [RSU/Microbit]     [PiRacer Car]     [Ghost Injection]
      |                  |                  |                   |
1. Start Broker          |                  |                   |
      |----------------->|                  |                   |
      |             2. Sub to SRM           |                   |
      |                  |                  |                   |
      |------------------------------------>|                   |
      |                               3. Sub to Alerts          |
      |                                     |                   |
      |<--------------------------------------------------------|
      |                                                   4. Pub SRM Trajectory
      |=== (Breach Event Detected by RSU Logic) ===             |
      |------------------------------------>|                   |
      |                               5. Parse DENM             |
      |                               6. Execute Stop           |

```

1. **Step 1:** Spin up the broker on the host laptop (`mosquitto -c /path/to/mosquitto.conf -v`).
2. **Step 2:** Start `rsu_controller.py`. It establishes a connection to the broker and subscribes to `v2x/priority_vehicle/srm`.
3. **Step 3:** Power on the PiRacer. Execute `piracer_v2x.py` on the car via SSH. It connects over Wi-Fi and subscribes to `v2x/intersection/alerts`.
4. **Step 4:** Launch `mock_ambulance.py`. The virtual coordinate trajectory begins streaming. The RSU evaluates distances, toggles the physical traffic lights via the Micro:bit serial line when a breach occurs, and commands the PiRacer to brake over the `alerts` loop.


---

#### Topic: `v2x/priority_vehicle/srm`
{
  "vehicle_id": "AMB_PORTO_01",
  "priority_level": 1,
  "timestamp": 1780417553,
  "telemetry": {
    "latitude": 41.1496,
    "longitude": -8.6110,
    "heading": 180.5,
    "speed_kmh": 75.2
  },
  "signature": "0x8f3cba42"
}

#### Topic: `v2x/intersection/alerts`
{
  "alert_id": "EVP_ACTIVE_INT_04",
  "status": "PREEMPTION_ACTIVE",
  "target_lane": "NORTH_BOUND",
  "clear_corridor_radius_meters": 30.0
}

## 4. Requirements & Traceability Matrix (TSF Framework)

This matrix tracks design intent straight into the implementation and test scripts to guarantee compliance with the **Trustable Software Framework**.

| Requirement ID | Type | Description | Component Trace | Verification Method |
| :--- | :--- | :--- | :--- | :--- |
| **REQ-FR-01** | Functional | The RSU shall calculate priority vehicle distance using incoming telemetry frames. | `rsu_controller.py` | `test_distance_calculation()` |
| **REQ-FR-02** | Functional | The RSU shall force conflicting traffic phases to RED within 500ms of validation. | `intersection_state.py` | `test_phase_truncation_latency()` |
| **REQ-FR-03** | Functional | The PiRacer (STM32) shall execute an evasive path shift upon receiving an active geofenced path alert. | `stm32_control_loop.c` | `HIL (Hardware-in-the-Loop)` Test Case |
| **REQ-SR-01** | Security | The RSU shall drop unauthenticated or replayed SRM signals to prevent spoofing attacks (ISO 21434 alignment). | `crypto_verify.py` | `test_replay_attack_rejection()` |

---

## 5. Task Allocation & Backlog

### 🟢 Sprint 1: Emulation & Protocol Design (Current)
- [ ] Write `REQUIREMENTS.md` and submit the formal PR to the SEA:ME course book.
- [ ] Configure local Mosquitto MQTT broker environment.
- [ ] Write `mock_ambulance.py` to generate dynamic trajectory coordinate strings.
- [ ] Write `rsu_logic.py` core state machine to handle lane states.

### 🟡 Sprint 2: SDR Signal Processing (Post-June 11)
- [ ] Unbox OpenSourceSDRLab R10C board and run initial hardware diagnostic (`hackrf_info`).
- [ ] Configure GNU Radio / Universal Radio Hacker environment on development laptops.
- [ ] Field-test signal hunting around Porto traffic intersections to record legacy RF bands.
- [ ] Document modulation schemes found in the field within the architecture file.

### 🔵 Sprint 3: Embedded Integration & Testing
- [ ] Implement MQTT client subscriber on the PiRacer host processor.
- [ ] Write UART/CAN data frames to pass the alert state from host down to the STM32 MCU.
- [ ] Program the STM32 PWM actuator control overrides for automated lane-clearing maneuvers.
- [ ] Run end-to-end automated validation tests to hit module test coverage goals.
