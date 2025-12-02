# CAN (Controller Area Network)

## What is CAN

Controller Area Network (CAN) is a multi‑master, event‑driven, message‑oriented serial bus standard widely used in automotive and industrial embedded systems. CAN transmits frames containing an identifier (which encodes message priority) and a payload (classical CAN up to 8 bytes; CAN‑FD supports larger payloads). The protocol provides robust error detection, automatic retransmission, and deterministic arbitration: when multiple nodes transmit simultaneously, the frame with the numerically lower identifier wins arbitration without data corruption.

Key properties:
- Deterministic arbitration for predictable priorities under load.
- Built‑in error handling and fault confinement for noisy vehicle environments.
- Error detection and recovery mechanisms:
  - CRC: a checksum computed over each CAN frame to detect corrupted bits; receivers recompute the CRC and reject frames that don't match.
  - ACK: after a frame is received correctly, at least one node on the bus drives the ACK bit to tell the sender the frame was accepted.
  - Bit‑stuffing: to keep clock synchronization, the transmitter inserts the opposite bit after five identical consecutive bits; the receiver removes these stuffed bits and checks stuffing rules to detect framing errors.
  - Automatic retransmission: if a frame is not acknowledged or an error is detected, the controller automatically retries transmission until success or until it moves to error‑passive / bus‑off state.
- Fault confinement: nodes that repeatedly fail are placed into error‑passive or bus‑off states to protect the bus.
- Wide ecosystem: mature transceivers, analyzers, software stacks and kernel support (SocketCAN) make integration and diagnostics straightforward.

### Physical layer and transceivers — how it works

- Bus wiring: CAN uses a twisted pair called CAN_H and CAN_L. All nodes share this pair.
- Differential signaling:
  - Recessive (bus idle / logical 1): CAN_H and CAN_L are at approximately the same voltage (mid‑rail). No node is actively driving the bus.
  - Dominant (logical 0 / active): a transceiver drives CAN_H higher and CAN_L lower, producing a voltage difference that all receivers detect. Dominant bits override recessive bits on the bus.
- Arbitration: if two nodes transmit simultaneously, each samples the bus while transmitting. A node that transmits recessive but senses dominant has lost arbitration and stops transmitting — the highest‑priority (lowest ID) message wins without collisions.
- Role of the transceiver:
  - MCU side: the FDCAN peripheral provides single‑ended TXD (transmit) and RXD (receive) signals (3.3 V logic).
  - Transceiver side (SN65HVD230): converts MCU TXD to differential CAN_H/CAN_L on transmit and converts the differential bus levels to RXD on receive. The transceiver also provides fail‑safe behavior, short‑circuit protection and common‑mode tolerance for vehicle buses.
- Termination and grounding: the bus must be terminated with 120 Ω at each physical end and all nodes must share a common ground. Proper termination minimizes reflections and ensures reliable timing.
- Why differential: a differential pair rejects common‑mode noise, improving robustness in automotive environments.

Simple signal flow:
- MCU (TXD high/low) → transceiver → drives CAN_H/CAN_L (dominant/recessive) → bus → other transceivers → MCU (their RXD)
- On receive: bus differential → transceiver converts → RXD toggles → FDCAN peripheral samples bits

---

## Message formats and ID map

This section defines canonical CAN IDs, DLCs (Data Length Code) and payload layouts used for remote→car commands and car→remote responses. Use standard 11‑bit IDs unless explicitly noted. Multi‑byte fields use big‑endian (network) byte order.

General rules:
- ID priority: numerically lower ID = higher bus arbitration priority.
- Keep messages small and atomic; prefer fixed DLCs for deterministic parsing.
- Use CAN‑FD when larger payloads are required; document FD DLCs and parsing accordingly.
- Reserve an ID range for future expansion and versioning.

Assigned IDs (examples, hex, standard 11‑bit)
- 0x100 — CMD_HEARTBEAT
  - DLC: 1
  - Payload: [flags: u8]
  - Description: periodic heartbeat from remote; car may respond with STATUS.
- 0x101 — CMD_ARM
  - DLC: 1
  - Payload: [arm: 0 = disarm, 1 = arm]
- 0x102 — CMD_THROTTLE
  - DLC: 2
  - Payload: [uint16_t throttle] (0..1000, big‑endian)
- 0x103 — CMD_STEER
  - DLC: 2
  - Payload: [int16_t steer] (-1000..1000, big‑endian)
- 0x110 — CMD_DIAGNOSTIC_REQUEST
  - DLC: 1
  - Payload: [diag_subcmd: u8]
- 0x120 — CMD_EMERGENCY_STOP
  - DLC: 1
  - Payload: [reserved]

Responses / telemetry (car → remote)
- 0x200 — STATUS
  - DLC: 4
  - Payload: [uint8_t state, uint8_t error_flags, uint16_t uptime_s] (big‑endian)
- 0x201 — TELEMETRY
  - DLC: variable (use CAN‑FD for >8 bytes). Use TLV or fixed packed fields as required.
- 0x2FF — ACK (generic acknowledgement)
  - DLC: 3
  - Payload: [uint8_t ack_code, uint8_t cmd_id, uint8_t seq]

Sequencing & reliability:
- Include an optional sequence number (u8) in flows that need loss detection.
- For critical commands (ARM, EMERGENCY_STOP) implement local watchdogs and require repeated command or explicit ACK.

Payload packing example (C-like):
- Throttle (2 bytes, big‑endian):
  - Send: tx_data[0] = (throttle >> 8) & 0xFF; tx_data[1] = throttle & 0xFF;
  - Parse: throttle = (tx_data[0] << 8) | tx_data[1];

CAN‑FD notes:
- If using CAN‑FD for TELEMETRY, include a small header (version, length, seq) at the start of the FD payload.
- Ensure both transceivers support the chosen FD data‑phase bitrates.

Filter recommendations:
- Configure hardware filters to accept only the ID ranges the node processes (e.g., 0x100..0x12F for commands, 0x200..0x2FF for responses) to reduce ISR load.

Versioning and extensibility:
- Reserve an ID range for message set versioning (e.g., 0x1xx = v1 commands, 0x3xx = v2 commands).
- When changing payloads, increment version and maintain backward compatibility where possible.

---

## Why CAN is used in this vehicle

- Industry relevance: CAN (and CAN‑FD) is widely used in automotive systems; using it mirrors real‑world architectures.
- Robustness: built‑in error handling and fault confinement are suitable for noisy vehicle environments.
- Determinism: arbitration by ID provides predictable message ordering under load.
- Tooling/ecosystem: many transceivers, analyzers and software libraries exist, easing integration and diagnostics.

We selected a Raspberry Pi 5 as the remote controller and the B‑U585I‑IOT02A (STM32U585) as the vehicle node to match common industry setups (separate gateway/host and MCU node).

## Selected CAN hardware
- MCU CAN peripheral: STM32U585 internal FDCAN peripheral (supports classical CAN and CAN‑FD).
- STM32 transceiver: SN65HVD230 — a low‑power CAN transceiver that interfaces STM32 FDCAN TX/RX pins to the bus differential lines (CAN_H / CAN_L).
- Remote host: Raspberry Pi 5 with a 2‑Channel CAN‑BUS(FD) Shield for Raspberry Pi (MCP2518FD). The shield contains the MCP2518FD CAN controller (SPI) and on‑board transceivers, providing two CAN‑FD channels for connection to the bus.

Notes:
- The MCP2518FD is accessed from the Pi over SPI; use the appropriate kernel driver / device‑tree overlay (mcp251xfd) or a userspace bridge to expose SocketCAN interfaces (e.g., can0, can1).

## Wiring and termination
- We connected the STM32 transceiver (SN65HVD230) and the Raspberry Pi MCP2518FD shield transceiver on a single differential bus: CAN_H ↔ CAN_H, CAN_L ↔ CAN_L. We used a twisted‑pair cable and kept stubs short.
- We placed two 120 Ω termination resistors — one at each physical end of the bus. If boards provide jumper‑configurable termination, enable only the terminators at the two ends.
- On the STM32 side we connected the FDCAN TX pin to the transceiver TXD and the FDCAN RX pin to the transceiver RXD (follow the SN65HVD230 datasheet). The transceiver was powered at 3.3 V.
- On the Raspberry Pi side we connected the MCP2518FD shield CAN_H/CAN_L to the same bus and verified the shield's termination jumpers and SPI link.
- We ensured a common ground between the Pi and STM32 (do not rely on USB ground if devices are powered separately).
- For EMC we routed the CAN differential pair as a twisted pair, avoided running it along noisy power traces, and grounded/shielded cable ends appropriately for the vehicle environment.

---

## CAN peripheral configuration (example)

The exact register values depend on your clock tree. Below are settings used in this project (FDCAN source clock = 36 MHz) to obtain ≈500 kbps for classical CAN.

Timing calculation (36 MHz)
- Bit rate = FDCAN_clock / (Prescaler * (1 + TSEG1 + TSEG2))
- With FDCAN_clock = 36 MHz and the init used in this project:
  - Prescaler = 4
  - TSEG1 = 15
  - TSEG2 = 2
  - Total time quanta = 1 + 15 + 2 = 18
  - Bit rate = 36e6 / (4 * 18) = 36e6 / 72 = 500000 bps
  - Sample point = (1 + TSEG1) / Total ≈ 16 / 18 ≈ 88.9%

Example HAL init excerpt used in this project:
```c
hfdcan1.Init.FrameFormat = FDCAN_FRAME_CLASSIC;
hfdcan1.Init.Mode = FDCAN_MODE_NORMAL;
hfdcan1.Init.NominalPrescaler = 4;        /* 36 MHz / (4 * 18 tq) = 500 kbps */
hfdcan1.Init.NominalSyncJumpWidth = 1;
hfdcan1.Init.NominalTimeSeg1 = 15;
hfdcan1.Init.NominalTimeSeg2 = 2;
```

---

## CAN speed and stability

Practical data and recommendations about CAN bitrates, bus length and factors affecting stability.

Speed vs. bus length (rules of thumb)
- Classical CAN (approximate maximum reliable length):
  - 1 Mbps → ≈40 m
  - 500 kbps → ≈100–120 m
  - 250 kbps → ≈250 m
  - 125 kbps → ≈500 m
- CAN‑FD: arbitration (nominal) phase uses classical timing; data phase runs faster and reduces reliable length drastically:
  - 2–5 Mbps data phase → typical reliable length <50 m
  - 8 Mbps data phase → often <10–20 m (depends on transceivers & cable)

Main stability drivers
- Termination & reflections: incorrect or missing 120 Ω termination or extra stubs cause reflections and CRC errors.
- Common‑mode / ground issues: missing common ground or large ground offsets produce unreliable signaling and stress transceivers.
- Cable quality & routing: untwisted pairs, long stubs, noisy proximity and poor connectors increase errors.
- Transceiver and FD support: some transceivers do not support CAN‑FD data rates — verify rise/fall times and maximum data rate.
- Timing mismatch: clock/timing differences and a poorly chosen sample point (TSEG1/TSEG2/SJW) cause bit errors.
- Bus load & congestion: heavy traffic and many nodes increase retransmissions and latency for lower‑priority frames.
- EMI/ESD and noisy power rails: cause intermittent errors that can escalate to error‑passive / bus‑off.

Recommended practices
- Sample point: target ≈75–90% (common ≈80–88%); tune TSEG1/TSEG2 to match topology and node clocks.
- SJW: 1–2 time quanta is typical.
- Filters & offload: use hardware filters + DMA to reduce ISR load.
- Minimise stubs, use twisted pair and proper shielding/grounding.
- Use FD‑capable transceivers when using CAN‑FD high data rates.
- Keep ISR work minimal; parse frames in a dedicated CAN thread.

Monitoring metrics
- Error counters (TEC/REC): watch for trends toward error‑passive (≥128) and bus‑off (≥255).
- Error frames / CRC errors: aim for near zero under normal conditions.
- Retransmit rate: a high retransmit rate indicates timing or noise issues.
- Bus‑off events: any bus‑off should trigger diagnostics and recovery.
- Message age / latency: monitor control message latency and missed heartbeats.

Bus‑off & recovery guidance
- On BUS_OFF: stop normal transmissions, log and signal failure, and enter a safe state (e.g., stop actuators).
- Recovery: perform controlled reinitialization (per ISO11898 or controller documentation) — e.g., reinitialize controller after a cooldown, then monitor error counters before resuming operation.
- Report status via STATUS frames and escalate to the remote controller.

Practical checklist
- Verify exactly two 120 Ω terminators at physical ends.
- Shorten stubs; use twisted pair and shield.
- Ensure common ground and stable transceiver VCC (3.3 V).
- Confirm transceivers support the chosen mode (classical vs FD) and data phase rates.
- Tune sample point and verify with an oscilloscope against another node.
- Use hardware filters, enable DMA for RX where possible, and keep ISR minimal.
- Run stress tests (high load, induced noise) and observe error counters and retransmit rates.

---

## ThreadX integration — CAN (implementation & flow)

Overview:
- CAN is implemented with two ThreadX threads: canTX (transmit) and canRX (receive).
- Data structure: t_can_message { uint32_t id; uint8_t data[8]; uint8_t len; } is used to pass frames between threads and queues.

Concurrency & IPC:
- Queues: tx queues deliver parsed command messages to subsystems (queue_speed_cmd, queue_steer_cmd).
- Event flags: an event_flags group signals sensor updates and message arrivals (e.g., FLAG_SENSOR_UPDATE, FLAG_CAN_SPEED_CMD).
- Mutex: speed_data_mutex protects the shared float g_vehicle_speed when canTX reads it.

canTX thread (transmit)
- Waits on FLAG_SENSOR_UPDATE (tx_event_flags_get).
- Reads g_vehicle_speed under speed_data_mutex.
- Builds a CAN status message via make_speed_status_msg (copies float into payload) and calls can_send().
- can_send() prepares an FDCAN_TxHeaderTypeDef and calls HAL_FDCAN_AddMessageToTxFifoQ(). On failure it logs via UART.
- The thread sleeps (tx_thread_sleep) between iterations.

canRX thread (receive)
- Polls RX FIFO fill level and calls HAL_FDCAN_GetRxMessage() when data is available.
- Converts HAL headers to t_can_message and routes messages by ID:
  - CMD_SPEED → enqueue to queue_speed_cmd and set FLAG_CAN_SPEED_CMD
  - CMD_STEERING → enqueue to queue_steer_cmd and set FLAG_CAN_STEER_CMD
- The thread sleeps briefly (tx_thread_sleep) between polls.

HAL / FDCAN usage:
- HAL FDCAN APIs are used for TX enqueue and RX reads.
- Notifications (FDCAN_IT_RX_FIFO0_NEW_MESSAGE) were enabled during init; current code uses polling in canRX but can be adapted to use HAL callbacks/ISR signaling.

Error handling:
- Transmission failure: can_send() logs "FailTransmitCAN!" via UART and returns (no software retransmit).
- RX path: unknown IDs are ignored (optionally logged).
- Recommendation: monitor controller error counters and implement bus‑off recovery (see Bus‑off section).

Design notes & suggestions:
- Consider using FDCAN RX interrupt / HAL callback to signal canRX instead of polling for lower latency and CPU use.
- Keep ISR work minimal: copy the hardware FIFO entry into a preallocated buffer and signal canRX for parsing.
- Manage TX queue/backpressure and message buffer lifetime when the bus is busy.
- For safety‑critical commands implement ACKs, sequence numbers and watchdogs.

---

## Diagrams

Place generated SVG diagrams (flow and sequence) here for GitHub viewers that do not render Mermaid inline:

![CAN ThreadX flow diagram](../diagrams/can_flow.svg)
![CAN ThreadX sequence diagram](../diagrams/can_seq.svg)

---

If you want, I can produce a small PR that replaces the current file with this corrected version and include the rendered SVG diagrams.