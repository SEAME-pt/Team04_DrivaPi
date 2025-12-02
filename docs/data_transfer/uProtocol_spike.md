# Spike \#193: Eclipse uProtocol Feasibility on STM32 with Classic CAN

## 1\. Executive Summary

This investigation evaluates the feasibility of replacing custom CAN parsing with Eclipse uProtocol on an STM32 microcontroller connected via **Classic CAN (ISO 11898-1)**.
**Verdict:** Implementation on STM32 is **NOT Recommended**.
The 8-byte payload limit of Classic CAN imposes severe fragmentation penalties when carrying uProtocol's rich metadata, rendering it unsuitable for real-time control loops. uProtocol is best positioned on the Raspberry Pi 5 as a gateway.

## 2\. Technical Constraint: Classic CAN vs. uProtocol

The fundamental conflict lies between the protocol's metadata requirements and the physical layer's capacity.

### 2.1 The Math of Overhead

Eclipse uProtocol messages are based on CloudEvents, requiring attributes such as source URI, sink URI, message ID, and timestamp.

  * **Minimum uProtocol Header:** \~30–38 bytes (using Protobuf serialization).
  * **Classic CAN Payload:** **8 bytes** maximum.

Unlike CAN-FD, which offers 64 bytes and could potentially fit a header, Classic CAN requires every single uProtocol message to be fragmented.

### 2.2 Fragmentation Latency (ISO-TP)

To transport a \~40-byte uProtocol message over Classic CAN, the system must employ **ISO-TP (ISO 15765-2)**.

**Transmission Sequence for 1 Message:**

1.  **First Frame (FF):** 6 bytes payload + 2 bytes header.
2.  **Flow Control (FC):** Receiver acknowledges (Latency spike).
3.  **Consecutive Frames (CF):** Remaining data sent in chunks of **7 bytes**.

**Impact:** A single sensor update requires at least **6 CAN frames** and a bidirectional handshake.

  * **Bus Utilization:** Increases by \~500% compared to raw signal packing.
  * **Latency:** The Flow Control wait time (typically 5-10ms on non-RTOS Linux receivers) violates the \<1ms requirements for braking/steering loops.

## 3\. STM32 Resource Analysis

### 3.1 Memory Footprint

The `up-c` (uProtocol C SDK) relies on dynamic features or complex struct mappings.

  * **Flash Usage:** The library + Protobuf (NanoPB) runtime requires \~60-100KB.
  * **RAM Usage:** ISO-TP reassembly buffers require allocating max message size (e.g., 4096 bytes) per connection to avoid overflow, consuming critical SRAM on the STM32.

### 3.2 CPU Overhead

Serialization using NanoPB on Cortex-M3 takes significant cycles compared to raw register copying. While acceptable for telemetry, it introduces jitter in high-frequency ISRs (Interrupt Service Routines) used for motor commutation.

## 4\. Recommendation

  * **STM32 (Low-Level):** Retain **Pure CAN** (Raw DBC-based signals). It fits the 8-byte frame perfectly without fragmentation.
  * **RPi5 (High-Level):** Implement uProtocol here. The RPi5 will act as the "Adapter," converting raw CAN frames into uProtocol messages for the rest of the Software Defined Vehicle (SDV) network.
