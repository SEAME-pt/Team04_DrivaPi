# CAN (Controller Area Network)

## What is CAN

Controller Area Network (CAN) is a multi-master, event-driven, message-oriented serial bus standard widely used in automotive and industrial embedded systems. CAN transmits frames containing an identifier (which encodes message priority) and a payload (classical CAN up to 8 bytes; CAN-FD larger). The protocol provides robust error detection, automatic retransmission, and deterministic arbitration: when multiple nodes transmit simultaneously, the frame with the numerically lower identifier wins arbitration without data corruption.

Key properties:
- Deterministic arbitration for predictable priorities under load.
- Built-in error handling and fault confinement were suitable for noisy vehicle environments.
- Error detection and recovery mechanisms:
  - CRC: a checksum computed over each CAN frame to detect corrupted bits; receivers recompute the CRC and reject frames that don't match.
  - ACK: after a frame is received correctly, at least one node on the bus drives the ACK bit to tell the sender the frame was accepted.
  - Bit‑stuffing: to keep clock synchronization, the transmitter inserts the opposite bit after five identical consecutive bits; the receiver removes these stuffed bits and checks stuffing rules to detect framing errors.
  - Automatic retransmission: if a frame is not acknowledged or an error is detected, the controller automatically retries transmission until success or until it moves to error‑passive / bus‑off state.
- Fault confinement: nodes that repeatedly fail are placed into error-passive or bus-off states to protect the bus.
- Wide ecosystem: mature transceivers, analyzers, software stacks and kernel support (SocketCAN) make integration and diagnostics straightforward.

### Physical layer and transceivers — how it works

- Bus wiring: CAN uses a single twisted‑pair differential wire called CAN_H and CAN_L. All nodes share this pair.
- Differential signaling:
  - Recessive (bus idle / logical 1): both CAN_H and CAN_L sit near the same voltage (approx. mid‑rail). No node is actively driving the bus.
  - Dominant (logical 0 / active): a transceiver actively drives CAN_H higher and CAN_L lower, producing a voltage difference that all receivers detect. Dominant bits override recessive bits on the bus.
- Arbitration: if two nodes start transmitting at the same time, each transmits bits while simultaneously sampling the bus. The node that transmits recessive but senses dominant has lost arbitration and stops transmitting — this lets the highest‑priority (lowest ID) message win without collisions.
- Role of the transceiver:
  - MCU side: the FDCAN peripheral exposes single‑ended TXD (transmit) and RXD (receive) signals (3.3 V logic).
  - Transceiver side (SN65HVD230): converts the MCU TXD into differential CAN_H/CAN_L levels for the bus on transmit, and converts the differential bus levels into a single‑ended RXD for the MCU on receive. The transceiver also implements fail‑safe behavior, short‑circuit protection and common‑mode voltage tolerance required on the vehicle bus.
- Termination and grounding: the bus must be terminated with 120 Ω at each physical end and all nodes must share a common ground. Proper termination minimizes reflections and ensures reliable bit timing.
- Why differential: using a differential pair makes the bus robust to common‑mode noise (both wires pick up the same interference, which is rejected by the receiver), important in automotive environments.

Simple signal flow:
- MCU (TXD high/low) → transceiver → drives CAN_H / CAN_L (dominant/recessive) → bus → other transceivers → MCU (their RXD)
- On receive: bus differential → transceiver converts → RXD toggles → FDCAN peripheral samples bits.


## Message formats and ID map

This section defines the canonical CAN IDs, DLCs (Data Length Code) and payload layouts used for remote→car commands and car→remote responses. Use standard 11‑bit IDs unless explicitly noted. Multi‑byte fields use big‑endian (network) byte order.

General rules
- ID priority: numerically lower ID = higher bus arbitration priority.
- Keep messages small and atomic; prefer fixed DLCs for deterministic parsing.
- Use CAN‑FD when larger payloads are required; document FD DLCs and parsing accordingly.
- Reserve an ID range for future expansion and versioning.


## Why CAN is used in this vehicle
- Industry relevance: CAN (and CAN-FD) is widely used in automotive systems; using it mirrors real-world architectures.  
- Robustness: built-in error handling and fault confinement are suitable for noisy vehicle environments.  
- Determinism: arbitration by ID gives predictable message delivery ordering under load.  
- Tooling/ecosystem: many transceivers, analyzers and libraries exist, easing integration with diagnostic/debug tools.

We selected a Raspberry Pi 5 as the remote controller and the B-U585I-IOT02A (STM32U585) as the vehicle node to match typical industry setups (separate gateway/host and MCU node).

## Selected CAN hardware
- MCU CAN peripheral: STM32U585 internal FDCAN peripheral (supports classical CAN and CAN FD).  
- STM32 transceiver: SN65HVD230 — a low‑power CAN transceiver that interfaces the STM32 FDCAN TX/RX pins to the bus differential lines (CAN_H / CAN_L).  
- Remote host: Raspberry Pi 5 with a 2‑Channel CAN‑BUS(FD) Shield for Raspberry Pi (MCP2518FD). The shield contains the MCP2518FD CAN controller (SPI) and on‑board transceivers, providing two CAN‑FD channels for connection to the same CAN bus.

Notes:
- The MCP2518FD is accessed from the Pi over SPI; use the appropriate kernel driver / device-tree overlay (mcp251xfd or userspace bridge) to expose socketcan interfaces (e.g., can0/can1).  

## Wiring and termination
- We connected the STM32 transceiver (SN65HVD230) and the Raspberry Pi MCP2518FD shield transceiver on a single differential bus: CAN_H ↔ CAN_H, CAN_L ↔ CAN_L. We used a twisted‑pair cable and kept stubs short.
- We placed two 120 Ω termination resistors — one at each physical end of the bus.
- On the STM32 side we connected the FDCAN TX pin to the transceiver TXD and the FDCAN RX pin to the transceiver RXD per the SN65HVD230 datasheet. We powered the transceiver with 3.3 V.
- On the Raspberry Pi side we connected the MCP2518FD shield CAN_H/CAN_L to the same bus and verified the shield's termination jumpers and SPI link.
- We ensured a common ground between the Pi and STM32.
- For EMC we routed the CAN differential pair as a twisted pair, avoided running it alongside noisy power traces, and grounded/shielded cable ends as appropriate for the vehicle environment.

## CAN peripheral configuration (example)

The exact register values depend on your clock tree. Below are settings used in this project (FDCAN source clock = 36 MHz) to obtain ~500 kbps for classical CAN.

Timing calculation (36 MHz)
- Bit rate = FDCAN_clock / (Prescaler * (1 + TSEG1 + TSEG2))
- With FDCAN_clock = 36 MHz and the init used in this project:
  - Prescaler = 4
  - TSEG1 = 15
  - TSEG2 = 2
  - Total time quanta = 1 + 15 + 2 = 18
  - Bit rate = 36e6 / (4 * 18) = 36e6 / 72 = 500000 bps
  - Sample point = (1 + TSEG1) / Total ≈ 16 / 18 ≈ 88.9%

Example HAL init excerpt used in this project
```c
hfdcan1.Init.FrameFormat = FDCAN_FRAME_CLASSIC;
hfdcan1.Init.Mode = FDCAN_MODE_NORMAL;
hfdcan1.Init.NominalPrescaler = 4;        /* 36 MHz / (4 * 18 tq) = 500 kbps */
hfdcan1.Init.NominalSyncJumpWidth = 1;
hfdcan1.Init.NominalTimeSeg1 = 15;    
hfdcan1.Init.NominalTimeSeg2 = 2;
```

## CAN speed and stability

Practical data and recommendations about CAN bitrates, bus length and factors that affect stability.

Speed vs. bus length (rules of thumb)
- Classical CAN (approximate maximum reliable length):
  - 1 Mbps → ~40 m
  - 500 kbps → ~100–120 m
  - 250 kbps → ~250 m
  - 125 kbps → ~500 m
- CAN‑FD: arbitration (nominal) phase uses classical timing; data phase runs faster and reduces reliable length drastically:
  - 2–5 Mbps data phase → typical reliable length <50 m
  - 8 Mbps data phase → often <10–20 m (depends on transceivers & cable)

Main stability drivers
- Termination & reflections: incorrect or missing 120 Ω terminations or extra stubs cause reflections and CRC errors.
- Ground/common‑mode: missing common ground or large ground offsets produce unreliable signaling and transceiver stress.
- Cable quality & routing: untwisted pairs, long stubs, noisy proximity and poor connectors increase errors.
- Transceiver and FD support: some transceivers do not support CAN‑FD data rates — verify rise/fall time and max data rate.
- Timing mismatch: clock/timing differences and poorly chosen sample point (TSEG1/TSEG2/SJW) cause bit errors.
- Bus load & congestion: heavy traffic and many nodes increase retransmissions and latency for lower‑priority frames.
- EMI/ESD and noisy power rails: cause intermittent errors escalating to error‑passive / bus‑off.

Recommended configuration and practices
- Sample point: target ~75–90% (common ~80–88%); tune TSEG1/TSEG2 to match cable topology and node clocks.
- SJW: 1–2 time quanta is typical.
- Filters & offload: use hardware filters + DMA to reduce ISR load and avoid software bottlenecks.
- Minimise stubs, use twisted pair and proper shielding/grounding for vehicle harnesses.
- Use FD‑capable transceivers when using CAN‑FD data phase high bitrates.
- Keep ISR work minimal; parse in a dedicated CAN thread.

Monitoring metrics to track stability
- Error counters (TEC/REC): track rising trends toward error‑passive (≥128) and bus‑off (≥255).
- Error frames / CRC errors: percent of frames with CRC or framing errors (aim ≈ 0).
- Retransmit rate: high retransmit rate indicates timing/noise issues.
- Bus‑off events: any bus‑off requires immediate diagnostics and recovery.
- Message age / latency: monitor end‑to‑end latency for control messages and missed heartbeats.

Bus‑off & recovery guidance
- On BUS_OFF: stop normal transmissions, log and signal failure, enter safe state (e.g., stop actuators).
- Recovery: perform controlled reinitialization (per ISO11898 or controller docs) — e.g., reinit controller after cooldown, then monitor error counters before normal operation.
- Report status via STATUS frames and escalate to remote controller.

Practical checklist
- Verify exactly two 120 Ω terminators at physical ends.
- Shorten stubs; use twisted pair and shield; keep CAN pair away from noisy lines.
- Ensure common ground and stable transceiver VCC (3.3 V).
- Confirm transceivers support chosen mode (classic vs FD) and data phase rates.
- Tune sample point and verify with oscilloscope against another node.
- Use hardware filters, enable DMA for RX where possible, keep ISR minimal.
- Run stress tests (high load, induced noise) and observe error counters and retransmit rates.




Overview
- We implemented CAN as two dedicated ThreadX threads: canTX (transmit) and canRX (receive).
- Data structure: t_can_message { uint32_t id; uint8_t data[8]; uint8_t len; } is used to pass frames between threads and queues.

Concurrency & IPC
- TX queues: tx queues are used to deliver parsed command messages to relevant subsystems (queue_speed_cmd, queue_steer_cmd).
- Event flags: an event_flags group signals sensor updates and message arrivals (e.g., FLAG_SENSOR_UPDATE, FLAG_CAN_SPEED_CMD).
- Mutex: speed_data_mutex protects the shared float g_vehicle_speed when canTX reads it.

canTX thread (transmit)
- Waits on FLAG_SENSOR_UPDATE (tx_event_flags_get).
- Reads g_vehicle_speed under speed_data_mutex.
- Builds a CAN status message via make_speed_status_msg (copies float into payload) and calls can_send().
- can_send() prepares an FDCAN_TxHeaderTypeDef and calls HAL_FDCAN_AddMessageToTxFifoQ(). On failure it logs over UART.
- Thread sleeps (tx_thread_sleep) between iterations.

canRX thread (receive)
- Polls FDCAN RX FIFO fill level and calls HAL_FDCAN_GetRxMessage() when data is available.
- Converts HAL headers to t_can_message and routes messages by ID:
  - CMD_SPEED → enqueue to queue_speed_cmd + set FLAG_CAN_SPEED_CMD
  - CMD_STEERING → enqueue to queue_steer_cmd + set FLAG_CAN_STEER_CMD
- Thread sleeps briefly (tx_thread_sleep) between polls.

HAL / FDCAN usage
- HAL FDCAN APIs are used for TX FIFO enqueue and RX FIFO read.
- Notifications were enabled (FDCAN_IT_RX_FIFO0_NEW_MESSAGE) in init; current code uses polling in canRX but can be adapted to use HAL callbacks/ISR signaling.

Error handling
- Transmission failure: can_send() logs "FailTransmitCAN!" via UART and returns (no retransmit logic in software).
- RX path: unknown IDs are ignored (optionally logged).
- Recommended: monitor controller error counters and handle bus-off per CAN recovery rules (see the Bus-off section).

Design notes & suggestions
- Polling in canRX is simple but consider using the FDCAN RX interrupt or HAL callback to signal a thread (faster, lower CPU).
- Keep ISR work minimal: copy hardware FIFO to a queue/buffer and signal canRX thread for parsing.
- Ensure TX queue/backpressure and message-buffer lifetime are managed when bus is busy.
- For critical safety commands implement ACKs, sequence numbers and watchdogs.

## ThreadX integration — CAN (implementation & flow diagrams)

Summary
- Two dedicated ThreadX threads handle CAN: canTX (transmit) and canRX (receive).
- canTX: waits for the speed sensor to update g_vehicle_speed, builds a speed status message, and enqueues it to the FDCAN TX FIFO (sent to the Raspberry Pi).
- canRX: waits for incoming CAN frames, parses ID, and enqueues messages to either the DC motor queue or servo queue depending on the ID.

graph LR
    Sensor["SpeedSensor (thread)"]
    CAN_TX["canTX (thread)"]
    Build["Build t_can_message"]
    FDCAN_TX["FDCAN TX FIFO"]
    TRANS["SN65HVD230 transceiver"]
    CANBUS["CAN bus (MCP2518FD on Pi)"]
    PI["Raspberry Pi (remote)"]
    FDCAN_RX["FDCAN RX FIFO"]
    CAN_RX["canRX (thread)"]
    Q_SPEED["queue_speed_cmd"]
    Q_STEER["queue_steer_cmd"]
    IGNORE["ignore / log"]

    Sensor -->|FLAG_SENSOR_UPDATE| CAN_TX
    CAN_TX -->|mutex read g_vehicle_speed| Build
    Build -->|send to FDCAN| FDCAN_TX

    FDCAN_TX --> TRANS
    TRANS --> CANBUS
    CANBUS --> PI

    PI -->|optional reply| CANBUS
    CANBUS --> TRANS
    TRANS --> FDCAN_RX
    FDCAN_RX --> CAN_RX

    CAN_RX -->|CMD_SPEED| Q_SPEED
    CAN_RX -->|CMD_STEERING| Q_STEER
    CAN_RX -->|other| IGNORE



Notes and mapping to your implementation
- Event sync: canTX uses tx_event_flags_get(FLAG_SENSOR_UPDATE) to wait for sensor updates.
- Mutual exclusion: canTX uses tx_mutex_get/put to read g_vehicle_speed safely.
- Transmit: can_send() populates FDCAN_TxHeaderTypeDef and calls HAL_FDCAN_AddMessageToTxFifoQ().
- Receive: can_receive() polls HAL_FDCAN_GetRxFifoFillLevel() and HAL_FDCAN_GetRxMessage(); canRX converts to t_can_message and routes by ID (CMD_SPEED → queue_speed_cmd, CMD_STEERING → queue_steer_cmd).
- IPC: queues (tx_queue_send) and event flags (tx_event_flags_set) are used to notify consumer threads.
- Improvements to consider:
  - Use FDCAN RX interrupt / HAL callback to signal canRX instead of polling for lower latency and lower CPU use.
  - In ISR only copy the hardware FIFO into a preallocated buffer or message and set an event to unblock canRX for parsing.
  - Add transmit completion/error handling and monitor FDCAN TEC/REC for bus-off recovery.

flowchart LR
  %% DrivaPi Autonomous Vehicle Safety and Functional Requirements Flow
  %% Layout: left-to-right, grouped and styled for readability

  %% ---------- Group headers (styled nodes to mimic boxed groups) ----------
  STANDARDS_HDR["STANDARDS & FRAMEWORK\nFOUNDATION"]
  ASSUMPTIONS_HDR["ASSUMPTIONS\nOF USE"]
  HARDWARE_HDR["HARDWARE\nARCHITECTURE"]
  FUNCTIONAL_HDR["FUNCTIONAL\nSAFETY CHAINS"]
  TELEMETRY_HDR["TELEMETRY &\nNON-SAFETY"]
  CURRICULUM_HDR["CURRICULUM &\nTOOLCHAIN"]
  SAFETY_HDR["SAFETY\nGOALS"]
  TOOLS_HDR["TOOLS &\nVERIFICATION"]

  %% ---------- STANDARDS & FRAMEWORK (left column) ----------
  subgraph STANDARDS_BLOCK [" "]
    ISO26262["ISO 26262"]
    HARA["Hazard Analysis\nand Risk Assessment"]
    TSF_trace["TSF traceability"]
    subgraph TSF_Framework["TSF Framework"]
      TRUSTABLE_SW["TRUSTABLE\nSOFTWARE"]
      TT_CHANGES["TT CHANGES"]
      TT_CONFIDENCE["TT CONFIDENCE"]
      TT_CONSTRUCTION["TT CONSTRUCTION"]
      TT_EXPECTATIONS["TT EXPECTATIONS"]
      TT_PROVENANCE["TT PROVENANCE"]
      TT_RESULTS["TT RESULTS"]
      TA_A01["TA A 01"]
      TA_A02["TA A 02"]
      TA_A03["TA A 03"]
      TA_A04["TA A 04"]
      TA_A05["TA A 05"]
      TA_A06["TA A 06"]
    end
  end

  STANDARDS_HDR --> ISO26262
  STANDARDS_HDR --> TSF_trace
  STANDARDS_HDR --> HARA

  AOU_details["Assumptions\nDetails"]
  AOU_001["AOU 001\nPhysical Braking\nReliability"]
  AOU_002["AOU 002\nHailo Inference\nLatency"]
  AOU_003["AOU 003\nOperational\nDesign Domain"]

  ASSUMPTIONS_HDR --> AOU_details
  AOU_details --> AOU_001
  AOU_details --> AOU_002
  AOU_details --> AOU_003
  AOU_details --> TT_EXPECTATIONS

  %% ---------- HARDWARE ARCHITECTURE (right) ----------
  subgraph HARDWARE_BLOCK ["Dual Computer Architecture"]
    HLC["HLC"]
    HLC_HMI["HLC HMI"]
    HLC_Perception["HLC Perception"]
    HLC_Planning["HLC Planning"]
    LLC["LLC"]
    LLC_SafetyGatekeeper["LLC Safety\nGatekeeper"]
    LLC_MotorControl["LLC Motor\nControl"]
    LLC_Watchdog["LLC Watchdog"]
    CAN_Bus["CAN Bus"]
  end

  HARDWARE_HDR --> HARDWARE_BLOCK

  %% ---------- FUNCTIONAL SAFETY CHAINS (center) ----------
  subgraph FUNCTIONAL_BLOCK ["FUNCTIONAL SAFETY CHAINS"]
    subgraph URD_block ["URD (User Requirements)"]
      URD_001["URD 001\nEmergency\nBraking"]
      URD_002["URD 002\nVehicle executes\nautonomous commands"]
      URD_003["URD 003\nSafe Speed\nLimit"]
      URD_004["URD 004\nAutonomous path\n& safety response"]
      URD_005["URD 005\nSystem alive\nmonitoring heartbeat"]
      URD_006["URD 006\nSystem Watchdog"]
      URD_007["URD 007\nEnergy management\nmonitoring"]
      URD_008["URD 008\nActuator\nResponse Time"]
      URD_009["URD 009\nODD Boundary\nCheck"]
      URD_010["URD 010\nCAN Bus\nSecurity"]
    end

    subgraph SRD_block ["SRD (System Requirements)"]
      SRD_001["SRD 001\nSTM32 Ultrasonic\nMonitor"]
      SRD_002["SRD 002\nRPi sends drive\ncommand packet\nSTM32 parses"]
      SRD_003["SRD 003\nSpeed\nGovernor"]
      SRD_004["SRD 004\nRPi vision lane\nobject CAN command"]
      SRD_005["SRD 005\nRPi sends\nheartbeat to STM32\nwatchdog"]
      SRD_006["SRD 006\nSTM32 Temp\nAcquisition"]
      SRD_007["SRD 007\nVoltage/current\nsense energy calc"]
      SRD_008["SRD 008\nThreadX Real-\nTime Task"]
      SRD_009["SRD 009\nRPi GPS\nGeofence"]
      SRD_010["SRD 010\nSTM32 CAN\nValidator"]
    end

    subgraph SWD_block ["SWD (Software Design)"]
      SWD_001["SWD 001\nEmergency Brake\nLogic"]
      SWD_002["SWD 002\nThreadX controller\ntask"]
      SWD_003["SWD 003\nSpeed Limiter\nLogic"]
      SWD_004["SWD 004\nPerception pipeline\nto command mixer"]
      SWD_005["SWD 005\nThreadX watchdog\ntask"]
      SWD_006["SWD 006\nWatchdog\nManager"]
      SWD_007["SWD 007\nSensor Monitor"]
      SWD_008["SWD 008\nActuator Driver"]
      SWD_009["SWD 009\nGeofence Logic"]
      SWD_010["SWD 010\nE2E Protection"]
    end

    subgraph LLTC_block ["LLTC (Low-level tests)"]
      LLTC_001["LLTC 001\nObstacle to\nBrake Test"]
      LLTC_002["LLTC 002\nDrive Command\nIntegration Test"]
      LLTC_003["LLTC 003\nSpeed\nCompliance Test"]
      LLTC_004["LLTC 004\nLane Keeping\nTest"]
      LLTC_005["LLTC 005\nHeartbeat\nTimeout Test"]
      LLTC_006["LLTC 006\nFault Injection\nWDT"]
      LLTC_007["LLTC 007\nSensor Fault\nTest"]
      LLTC_008["LLTC 008\nLatency\nMeasure"]
      LLTC_009["LLTC 009\nODD Exit\nTest"]
      LLTC_010["LLTC 010\nCAN Corruption\nTest"]
    end
  end

  FUNCTIONAL_HDR --> FUNCTIONAL_BLOCK

  %% URD -> SRD -> SWD -> LLTC (V-model chains)
  URD_001 --> SRD_001 --> SWD_001 --> LLTC_001
  URD_002 --> SRD_002 --> SWD_002 --> LLTC_002
  URD_003 --> SRD_003 --> SWD_003 --> LLTC_003
  URD_004 --> SRD_004 --> SWD_004 --> LLTC_004
  URD_005 --> SRD_005 --> SWD_005 --> LLTC_005
  URD_006 --> SRD_006 --> SWD_006 --> LLTC_006
  URD_007 --> SRD_007 --> SWD_007 --> LLTC_007
  URD_008 --> SRD_008 --> SWD_008 --> LLTC_008
  URD_009 --> SRD_009 --> SWD_009 --> LLTC_009
  URD_010 --> SRD_010 --> SWD_010 --> LLTC_010

  %% ---------- TELEMETRY & NON-SAFETY (bottom-left) ----------
  subgraph TELEMETRY_BLOCK ["Telemetry & Non-Safety Functions"]
    subgraph URT_block ["URT (User req - Telemetry)"]
      URT_01["UR T01\nDriver Sees\nSpeed"]
      URT_02["UR T02\nDriver Sees\nTemp"]
      URT_03["UR T03\nEnergy management\nmonitoring"]
      URT_04["UR T04\nOdometer\nDistance"]
      URT_05["UR T05\nReal-time dashboard\nvisualization sink"]
    end

    subgraph SRT_block ["SR T (Sensor req - Telemetry)"]
      SRT_01["SR T01\nWheel Pulses\nto CAN"]
      SRT_02["SR T02\nI2C Temp\nto CAN"]
      SRT_03["SR T03\nvoltage current\nsense -> energy calc"]
      SRT_04["SR T04\nCount Pulses\nto CAN"]
      SRT_05["SR T05\nRPi consumes\nSTM32 telemetry\nfeedback"]
    end

    subgraph SWT_block ["SW T (Software - Telemetry)"]
      SWT_01["SW T01\nThreadX Pulse\nCounter"]
      SWT_02["SW T02\nThreadX ADC\nPolling"]
      SWT_03["SW T03\npower monitor\ntask"]
      SWT_04["SW T04\nThreadX persistent\nstorage & accumulator"]
      SWT_05["SW T05\nQt QML dashboard\nengine"]
    end

    subgraph LLTCT_block ["LLTC T (Telemetry tests)"]
      LLTCT_01["LLTC T01\nPulse Test"]
      LLTCT_02["LLTC T02\nI2C Test"]
      LLTCT_03["LLTC T03\nADC Test"]
      LLTCT_04["LLTC T04\nODO Test"]
      LLTCT_05["LLTC T05\nHMI Data Test"]
    end
  end

  TELEMETRY_HDR --> TELEMETRY_BLOCK

  %% Telemetry chains
  URT_01 --> SRT_01 --> SWT_01 --> LLTCT_01
  URT_02 --> SRT_02 --> SWT_02 --> LLTCT_02
  URT_03 --> SRT_03 --> SWT_03 --> LLTCT_03
  URT_04 --> SRT_04 --> SWT_04 --> LLTCT_04
  URT_05 --> SRT_05 --> SWT_05 --> LLTCT_05

  %% Map telemetry sensors to HLC/LLC
  SRT_02 --- HLC_Perception
  SRT_04 --- HLC_Perception
  SRT_05 --- HLC_HMI

  %% ---------- CURRICULUM & TOOLCHAIN (left column) ----------
  subgraph CURRICULUM_BLOCK ["Educational Curriculum & Tools"]
    SDV["SDV"]
    RTOS["RTOS"]
    ADAS["ADAS"]
    GenAI["GenAI"]
    MobilityApps["Mobility Apps"]
    SafetyEng["Safety Engineering"]
  end

  CURRICULUM_HDR --> CURRICULUM_BLOCK

  %% Curriculum -> Requirements
  SDV --> SRD_009
  SDV --> SRT_05
  RTOS --> SWD_001
  RTOS --> SWD_003
  RTOS --> SWD_006
  RTOS --> SWD_008
  ADAS --> URD_002
  ADAS --> SWD_002
  GenAI --> SWD_002
  MobilityApps --> SWT_05
  SafetyEng --> HARA
  SafetyEng --> TSF_trace

  %% ---------- TOOLS & VERIFICATION (right-bottom) ----------
  subgraph TOOLS_BLOCK ["Tools & Verification"]
    SocketCAN["SocketCAN"]
    Oscilloscope["Oscilloscope"]
    I2C_Sniffer["I2C Sniffer"]
    CARLA["CARLA"]
    Hailo_SDK["Hailo SDK"]
    Qt_Creator["Qt Creator"]
    ThreadX_SDK["ThreadX SDK"]
    GTest["GTest"]
    CppCheck["CppCheck"]
    AGL_System["AGL System"]
  end

  TOOLS_HDR --> TOOLS_BLOCK

  %% Functional safety & telemetry link to tools
  FUNCTIONAL_HDR --> TOOLS_HDR
  TELEMETRY_HDR --> TOOLS_HDR

  %% ---------- SAFETY GOALS (small center-left block) ----------
  SG1["SG1 Prevent\ncollision"]
  SG2["SG2 Prevent\nrunaway actuator"]
  SG3["SG3 Maintain\nsafe speed"]
  SG4["SG4 System\navailability"]

  SAFETY_HDR --> SG1
  SAFETY_HDR --> SG2
  SAFETY_HDR --> SG3
  SAFETY_HDR --> SG4

  %% Safety goals -> URDs
  SG1 --> URD_001
  SG1 --> URD_002
  SG1 --> URD_004
  SG2 --> URD_008
  SG3 --> URD_003
  SG4 --> URD_006

  %% TSF / TA -> URD traceability
  TA_A01 --> URD_007
  TA_A03 --> URD_010
  TT_EXPECTATIONS --> URD_005
  TT_EXPECTATIONS --> URD_009

  %% Hardware allocation
  HLC --> HLC_HMI
  HLC --> HLC_Perception
  HLC --> HLC_Planning

  LLC --> LLC_SafetyGatekeeper
  LLC --> LLC_MotorControl
  LLC --> LLC_Watchdog

  SRD_002 --> LLC_SafetyGatekeeper
  SRD_003 --> LLC_SafetyGatekeeper
  SRD_006 --> LLC_Watchdog
  SRD_007 --> LLC_SafetyGatekeeper
  SRD_008 --> LLC_MotorControl
  SRD_010 --> LLC_SafetyGatekeeper

  HLC --- CAN_Bus
  LLC --- CAN_Bus
  CAN_Bus --> LLC_SafetyGatekeeper
  CAN_Bus --> HLC_Planning

  %% ---------- Styling (classDefs + assignments) ----------
  classDef hdr fill:#0b2233,stroke:#ffffff,stroke-width:1px,color:#ffffff,font-weight:700;
  classDef groupA fill:#082f2f,stroke:#2be6d6,stroke-width:1px,color:#dffbf7;
  classDef groupB fill:#2a1630,stroke:#c08bc0,stroke-width:1px,color:#f0dbf6;
  classDef groupC fill:#23302b,stroke:#8fe3a7,stroke-width:1px,color:#e9fbef;
  classDef small fill:#111214,stroke:#666666,stroke-width:1px,color:#cfcfcf;
  class STANDARDS_HDR,ASSUMPTIONS_HDR,HARDWARE_HDR,FUNCTIONAL_HDR,TELEMETRY_HDR,CURRICULUM_HDR,SAFETY_HDR,TOOLS_HDR hdr;
  class ISO26262,HARA,TSF_trace groupA;
  class TRUSTABLE_SW,TT_CHANGES,TT_CONFIDENCE,TT_CONSTRUCTION,TT_EXPECTATIONS,TT_PROVENANCE,TT_RESULTS groupA;
  class AOU_details,AOU_001,AOU_002,AOU_003 small;
  class HLC,LLC,CAN_Bus,LLC_SafetyGatekeeper,LLC_MotorControl,LLC_Watchdog groupB;
  class URD_001,URD_002,URD_003,URD_004,URD_005,URD_006,URD_007,URD_008,URD_009,URD_010 groupC;
  class SRD_001,SRD_002,SRD_003,SRD_004,SRD_005,SRD_006,SRD_007,SRD_008,SRD_009,SRD_010 groupC;
  class SWD_001,SWD_002,SWD_003,SWD_004,SWD_005,SWD_006,SWD_007,SWD_008,SWD_009,SWD_010 groupC;
  class LLTC_001,LLTC_002,LLTC_003,LLTC_004,LLTC_005,LLTC_006,LLTC_007,LLTC_008,LLTC_009,LLTC_010 small;
  class URT_01,URT_02,URT_03,URT_04,URT_05 SRT_block;
  class SRT_01,SRT_0	2,SRT_03,SRT_04,SRT_05 SWT_block;
  class SocketCAN,Oscilloscope,I2C_Sniffer,CARLA,Hailo_SDK,Qt_Creator,ThreadX_SDK,GTest,CppCheck,AGL_System small;
  class SDV,RTOS,ADAS,GenAI,MobilityApps,SafetyEng small;
  class SG1,SG2,SG3,SG4 small;

  %% ---------- Notes ----------
  %% - Mermaid does not allow absolute pixel-perfect placement; this layout uses subgraphs,
  %%   grouping and directional edges to preserve the structure and readability of your original.
  %% - If you want even closer visual parity with the original image (shadows, rounded boxes,
  %%   exact spacings), consider exporting as SVG from a diagram tool (Diagrams.net / Eraser)
  %%   or using multiple smaller Mermaid diagrams stacked in your README.

  %% End of diagram
