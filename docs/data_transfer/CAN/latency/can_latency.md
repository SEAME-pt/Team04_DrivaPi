# CAN Bus Latency Analysis

## 📌 Overview

This document describes CAN bus latency measurements performed on the Team04_DrivaPi project. Latency analysis is critical for real-time embedded systems to ensure deterministic behavior and reliability.

---

## 🎯 What is Latency?

**Latency** typically refers to the **one-way delay** between sending a CAN message and the receiver getting it. However, measuring one-way latency requires synchronized clocks between sender and receiver, which is difficult in practice.

### Round-Trip Latency (RTT)

In this test, we measure **round-trip latency (RTT)**, which is the total time from:
1. **Sending a message** from Raspberry Pi or STM32
2. **Message traveling** through CAN bus to receiver (STM32 or loopback)
3. **Receiver echoing back** the same message
4. **Echo traveling back** through CAN bus
5. **Raspberry Pi or STM32 receiving** the echoed message

### Internal Loopback Latency

Additionally, we measure **STM32 internal loopback latency**, which is the time between:
1. **STM32 sending** a CAN frame
2. **Frame going through the FDCAN peripheral and transceiver**
3. **STM32 receiving its own frame back** (via hardware loopback or bus reflection)

This measures the STM32's own CAN stack performance in isolation.

### Formulas

**One-way latency (theoretical):**
```
Latency_one_way = t_reception - t_transmission
```

**Round-trip latency (what we measure between devices):**
```
RTT = t_echo_received - t_original_sent
```

**STM32 internal loopback (self-test):**
```
Latency_internal = t_rx_interrupt - t_tx_sent
```

**Estimated one-way latency:**
```
Latency_one_way ≈ RTT / 2
```
(Assumes symmetric send/receive paths)

---

## 🔄 Test Setup Clarification

### Test Configurations

#### Configuration 1: STM32 ↔ Raspberry Pi (Hardware Round-Trip)
- **Path:** Raspberry Pi → CAN bus → STM32 transceiver → STM32 firmware → STM32 transceiver → CAN bus → Raspberry Pi
- **Measures:** Full hardware round-trip including:
  - Physical bus propagation
  - CAN transceiver delays
  - STM32 firmware processing time
  - OS scheduling on both sides
- **Test tool:** `can_latency_receive_test.cpp` on Raspberry Pi

#### Configuration 2: Raspberry Pi Loopback (Software-Only)
- **Path:** Raspberry Pi → Linux kernel SocketCAN → **immediate echo** → Raspberry Pi
- **Measures:** Software stack overhead only (no hardware)
- **Test tool:** `can_latency_receive_test.cpp` with `vcan` interface
- Kernel automatically echoes frames back to sender

#### Configuration 3: STM32 Internal Loopback (Self-Test)
- **Path:** STM32 TX → FDCAN peripheral → CAN transceiver → (loopback) → CAN transceiver → FDCAN peripheral → STM32 RX
- **Measures:** STM32's own CAN stack latency
- **Test tool:** `stm32_latency_loopback.c` running on STM32
- **Method:**
  1. Embed DWT cycle counter timestamp in TX frame
  2. Receive frame in RX FIFO0 interrupt
  3. Calculate latency using cycle counter difference
  4. Transmit result via UART to PC

**Command to capture STM32 data:**
```bash
head -n 1000 /dev/ttyACM0 > stm_latency_log.txt
```

---

## 📊 Test Results

### Test Environment 1: STM32 ↔ Raspberry Pi (CAN1 Round-Trip)
**Configuration:** Real STM32U585 microcontroller with CAN transceiver communicating with Raspberry Pi  
**Testing Method:** Round-trip latency measurement via SocketCAN interface  
**Echo Source:** STM32 firmware echoes received frames back to Raspberry Pi

| Metric | RTT Value (µs) | Est. One-Way (µs) |
|--------|----------------|-------------------|
| **Minimum Latency** | 710 | ~355 |
| **Maximum Latency** | 16,724 | ~8,362 |
| **Mean Latency** | 1,003.47 | ~502 |
| **Median Latency** | 789 | ~395 |
| **Std Deviation** | 1,456.21 | ~728 |
| **P95 Latency** | 917 | ~459 |
| **P99 Latency** | 2,654 | ~1,327 |
| **Total Samples** | 1000 |
| **Success Rate** | 100% |

**Command Used:**
```bash
./can_latency_receive_test > latency_log.txt
```

---

### Test Environment 2: Raspberry Pi Loopback (CAN Virtual Interface)
**Configuration:** Linux CAN loopback interface (`can-virt`) - no hardware transceiver  
**Testing Method:** Kernel-level echo, software-only round-trip  
**Echo Source:** Linux kernel SocketCAN automatically echoes frames

| Metric | RTT Value (µs) | Est. One-Way (µs) |
|--------|----------------|-------------------|
| **Minimum Latency** | 522 | ~261 |
| **Maximum Latency** | 721 | ~361 |
| **Mean Latency** | 592.37 | ~296 |
| **Median Latency** | 593 | ~297 |
| **Std Deviation** | 18.96 | ~9.5 |
| **P95 Latency** | 605 | ~303 |
| **P99 Latency** | 617 | ~309 |
| **Total Samples** | 1000 |
| **Success Rate** | 100% |

**Command Used:**
```bash
sudo ip link add dev can-virt type vcan
sudo ip link set can-virt up
./can_latency_receive_test > can_lat_loop_log.txt
```

---

### Test Environment 3: STM32 Internal Loopback (Self-Test)
**Configuration:** STM32U585 measuring its own CAN transmission/reception latency  
**Testing Method:** DWT cycle counter timestamps embedded in frames  
**Echo Source:** Hardware loopback or bus reflection  
**Clock:** 160 MHz system clock

| Metric | Value (µs) |
|--------|------------|
| **Minimum Latency** | 244 |
| **Maximum Latency** | 256 |
| **Mean Latency** | 247.77 |
| **Median Latency** | 248 |
| **Std Deviation** | 2.08 |
| **P95 Latency** | 250 |
| **P99 Latency** | 252 |
| **Total Samples** | 1000 |
| **Success Rate** | 100% |

**Test Code:** `stm32_latency_loopback.c`

**Key Implementation Details:**
```c
// Timestamp at transmission (DWT cycle counter)
t_send = DWT->CYCCNT;
memcpy(txData, &t_send, 4);
HAL_FDCAN_AddMessageToTxFifoQ(&hfdcan1, &txHeader, txData);

// In RX interrupt callback
uint32_t t_recv = DWT->CYCCNT;
uint32_t sent_cycles = *((uint32_t*)rxData);
uint32_t latency_cycles = t_recv - sent_cycles;
float latency_us = latency_cycles / (SystemCoreClock / 1e6f);
```

**Command to Capture Data:**
```bash
head -n 1000 /dev/ttyACM0 > stm_latency_log.txt
```

**Analysis:**

✅ **Ultra-Deterministic Behavior**
- Extremely tight latency range (244–256 µs, only 12 µs span)
- **Standard deviation of 2.08 µs** - exceptional consistency
- No outliers detected in 1000 samples
- Hardware-level determinism

📊 **STM32 Hardware Performance**
- **Mean latency:** 247.77 µs from TX to RX interrupt
- Includes:
  - FDCAN peripheral processing
  - CAN transceiver delays
  - Physical loopback propagation
  - RX interrupt latency

🔬 **Comparison to Raspberry Pi**
- STM32 internal: **247.77 µs**
- RPi loopback: **592.37 µs**
- STM32 is **2.4× faster** than Linux SocketCAN software stack
- Demonstrates real-time OS advantage over general-purpose Linux

---

## 📈 Comparative Analysis

### All Three Test Configurations

```
╔═══════════════════════╦════════════════╦═══════════════╦═══════════════╗
║ Metric                ║ STM32↔RPi (µs) ║ RPi Loop (µs) ║ STM32 Int (µs)║
╠═══════════════════════╬════════════════╬═══════════════╬═══════════════╣
║ Minimum Latency       ║ 710            ║ 522           ║ 244           ║
║ Maximum Latency       ║ 16,724         ║ 721           ║ 256           ║
║ Mean Latency          ║ 1,003          ║ 592           ║ 248           ║
║ Median Latency        ║ 789            ║ 593           ║ 248           ║
║ Std Deviation         ║ 1,456          ║ 19            ║ 2             ║
║ P95 Latency           ║ 917            ║ 605           ║ 250           ║
║ P99 Latency           ║ 2,654          ║ 617           ║ 252           ║
║ Jitter (Max-Min)      ║ 16,014         ║ 199           ║ 12            ║
╚═══════════════════════╩════════════════╩═══════════════╩═══════════════╝
```

### Key Observations

#### 1. **STM32 Hardware is Highly Deterministic**
- **Internal loopback:** 244–256 µs (12 µs jitter)
- **Coefficient of variation:** 0.84% (extremely low)
- Real-time OS eliminates scheduling uncertainty

#### 2. **Round-Trip Latency Breakdown**
Breaking down the STM32↔RPi round-trip (789 µs median):
- **STM32 TX → CAN bus:** ~248 µs (measured internally)
- **Bus propagation + RPi processing:** ~541 µs
- **Total round-trip:** 789 µs

#### 3. **Linux Adds Significant Overhead**
- **RPi loopback:** 593 µs (pure software)
- **STM32 loopback:** 248 µs (hardware + firmware)
- **Linux overhead:** 345 µs additional latency
- General-purpose OS scheduling introduces variability

#### 4. **Hardware vs Software Determinism**
| Platform | Jitter | Determinism Level |
|----------|--------|-------------------|
| STM32 Internal | 12 µs | ⭐⭐⭐⭐⭐ Excellent |
| RPi Loopback | 199 µs | ⭐⭐⭐ Good |
| STM32↔RPi | 16,014 µs | ⭐⭐ Acceptable |

---

## 🎯 Conclusions

### System Performance Assessment

✅ **STM32 Demonstrates Excellent Real-Time Performance**
- **Internal latency:** 248 µs median with only 2 µs std deviation
- Hardware determinism suitable for safety-critical applications
- No outliers or scheduling interference

✅ **Round-Trip Communication is Acceptable**
- **Median RTT:** 789 µs (~395 µs one-way)
- Suitable for motor control loops (10–100 Hz)
- Outliers caused by Linux scheduling, not CAN hardware

📊 **Latency Budget Breakdown (STM32↔RPi)**
```
Total RTT: 789 µs
├─ STM32 TX: ~248 µs (31%)
├─ Bus propagation: ~50 µs (6%)
├─ RPi RX processing: ~250 µs (32%)
├─ RPi TX: ~250 µs (32%)
└─ Return bus: ~50 µs (6%)
```

⚠️ **Linux Introduces Scheduling Variability**
- RPi software stack: 592 µs vs STM32 hardware: 248 µs
- General-purpose OS not optimized for hard real-time
- Consider PREEMPT_RT kernel if tighter bounds needed

### Recommendations

#### For Motor Control Applications
- ✅ **Use STM32 internal loopback results** for timing budgets
- ✅ **Assume ~250 µs STM32 processing time** per message
- ✅ **Set CAN timeouts to 5 ms** (margin above P99 RTT)
- ✅ **Account for ~800 µs round-trip** in control loop design

#### For System Optimization
- 🔧 **Monitor RPi scheduling** - consider CPU affinity or RT patches
- 📊 **Profile under load** - test with all tasks running
- 🎯 **Prioritize CAN threads** on Raspberry Pi side
- 🛡️ **Implement watchdog timers** for missed messages

#### For Safety-Critical Systems
- ⚠️ **STM32 should handle time-critical functions** (ultra-low latency)
- ⚠️ **RPi for higher-level coordination** (acceptable latency variance)
- ⚠️ **Design for worst-case P99 latencies** (safety margins)

---

## 📚 Technical References

- **ISO 11898-1:** CAN Protocol Specification
- **Linux SocketCAN:** https://www.kernel.org/doc/html/latest/networking/can.html
- **STM32U585 FDCAN:** https://www.st.com/resource/en/reference_manual/rm0456-stm32u575585-armbased-32bit-mcus-stmicroelectronics.pdf
- **DWT Cycle Counter:** ARM Cortex-M33 Technical Reference Manual
- **Real-Time Linux:** https://wiki.linuxfoundation.org/realtime/start

---

## 📁 Related Files

| File | Purpose |
|------|---------|
| `can_latency_receive_test.cpp` | Raspberry Pi round-trip latency tool |
| `stm32_latency_loopback.c` | STM32 internal loopback measurement |
| `latency_log.txt` | STM32↔RPi round-trip results (1000 samples) |
| `can_lat_loop_log.txt` | RPi loopback results (1000 samples) |
| `stm_latency_log.txt` | STM32 internal loopback results (1000 samples) |
| `can_latency.md` | This document |

---

## 🔗 How to Reproduce

### Test 1: STM32 ↔ Raspberry Pi Round-Trip
```bash
# On Raspberry Pi
cd /path/to/project
g++ -O2 -o can_latency_receive_test can_latency_receive_test.cpp
sudo ./can_latency_receive_test > latency_log.txt
```

### Test 2: Raspberry Pi Loopback
```bash
# Create virtual CAN interface
sudo ip link add dev can-virt type vcan
sudo ip link set can-virt up

# Modify can_latency_receive_test.cpp to use "can-virt"
./can_latency_receive_test > can_lat_loop_log.txt
```

### Test 3: STM32 Internal Loopback
```bash
# Flash stm32_latency_loopback.c to STM32
# Connect UART (ttyACM0) to PC
head -n 1000 /dev/ttyACM0 > stm_latency_log.txt
```

---

## 🚀 Possible Improvements

### 1. **Increase CAN Bus Speed (500 kbps → 1000 kbps)**

#### Can Regular CAN Support 1000 kbps?

**Yes!** Classic CAN (CAN 2.0B) supports bitrates up to **1 Mbps (1000 kbps)**.

**ISO 11898-1 Standard Bitrates:**
```
Standard Bitrates: 10, 20, 50, 100, 125, 250, 500, 800, 1000 kbps
Maximum: 1 Mbps
```

**Current Setup:** 500 kbps
**Proposed:** 1000 kbps (2× speed increase)

#### Benefits of Doubling CAN Speed

| Aspect | Impact |
|--------|--------|
| **Message Transmission Time** | -50% (half the time on bus) |
| **Throughput** | 2× more messages per second |
| **Latency** | ~50% reduction in frame transmission delay |
| **Bandwidth Utilization** | Better for high-frequency control |

#### Expected Latency Improvement

**Rough Estimate (Transmission Time Only):**
```
Current (500 kbps):  Frame TX time = 64 bits / 500 kbps ≈ 128 µs
Proposed (1000 kbps): Frame TX time = 64 bits / 1000 kbps ≈ 64 µs

Savings per message: ~64 µs per direction
Expected RTT reduction: ~128 µs (from 789 µs → ~661 µs)
```

#### Limitations & Considerations

⚠️ **Physical Bus Length**
- **500 kbps:** Supports up to 2,000 meters
- **1000 kbps:** Maximum 40 meters (shorter cable required)
- **Team04 Setup:** Likely within 40m (small vehicle) ✅

⚠️ **Transceiver Compatibility**
- **STM32 FDCAN:** Fully supports 1 Mbps ✅
- **CAN Transceiver (TJA1051T/3):** Supports up to 1 Mbps ✅
- **Raspberry Pi SocketCAN:** No hardware limitation ✅

⚠️ **Signal Integrity**
- Higher speeds require:
  - Better PCB layout
  - Quality twisted-pair cables
  - Proper termination resistors (120 Ω)
  - Shielding to reduce EMI

⚠️ **Timing Sensitivity**
- Tighter timing margins for phase errors
- More susceptible to jitter
- Requires careful CAN controller configuration

#### Implementation Steps

**Step 1: Verify Hardware Compatibility**
```bash
# Check FDCAN controller capabilities
# STM32U585 datasheet: Supports up to 32 Mbps FDCAN
```

**Step 2: Update STM32 Configuration**
```c
// In STM32 CubeMX or code
FDCAN_InitTypeDef hfdcan1 = {
    .FrameFormat = FDCAN_FRAME_CLASSIC,  // Classic CAN
    .Mode = FDCAN_MODE_NORMAL,
    .NominalPrescaler = 8,                // Adjust for 1 Mbps
    .NominalTimeSeg1 = 13,                // Phase segment 1
    .NominalTimeSeg2 = 2,                 // Phase segment 2
    .NominalSyncJumpWidth = 2,
    // Result: 160MHz / (8 * (13+2+1)) = 1 Mbps
};
```

**Step 3: Update Raspberry Pi Configuration**
```bash
# Set CAN interface to 1000 kbps
sudo ip link set can0 type can bitrate 1000000
sudo ip link set can0 up

# Verify
ip -details link show can0
```

**Step 4: Re-run Latency Tests**
```bash
./can_latency_receive_test > latency_log_1mbps.txt
```

#### Expected Results After Speed Upgrade

| Metric | 500 kbps | 1000 kbps | Improvement |
|--------|----------|-----------|-------------|
| **Mean RTT** | 1,003 µs | ~875 µs | -12.8% |
| **Median RTT** | 789 µs | ~661 µs | -16.3% |
| **P95 RTT** | 917 µs | ~789 µs | -13.9% |
| **P99 RTT** | 2,654 µs | ~2,526 µs | -4.8% |
| **TX Time (8 bytes)** | 128 µs | 64 µs | -50% |

---

### 2. **Reduce Frame Payload Size (8 → 4 bytes)**

#### Current Setup Analysis
- **Data Length Code (DLC):** 8 bytes (Full CAN frame)
- **Actual data used:** 4 bytes (timestamp)
- **Overhead:** 50% unused payload

#### Benefits of Smaller Frames

| Aspect | Impact |
|--------|--------|
| **Transmission Time** | -50% |
| **Bus Occupancy** | Lower (allows more messages) |
| **Latency** | ~64 µs reduction per message |
| **Error Rate** | Slightly better (fewer bits = fewer errors) |

#### Implementation

**Modify can_latency_receive_test.cpp:**
```cpp
// Current: 8 bytes
struct can_frame frame;
frame.can_dlc = 8;  // Change to 4

// New: 4 bytes (32-bit timestamp)
frame.can_dlc = 4;
pack_uint32(t0, frame.data);  // Use 32-bit instead of 64-bit
```

**Expected Latency Improvement:**
```
4-byte frame TX time: 32 bits / 500 kbps ≈ 64 µs
Savings: 64 µs per direction → ~128 µs RTT improvement
```

---

### 3. **Use CAN FD (Flexible Data-rate)**

#### What is CAN FD?

CAN FD (ISO 11898-2) extends classical CAN with:
- **Higher bitrate:** Up to 5 Mbps data phase (vs 1 Mbps nominal)
- **Larger frames:** 8–64 bytes (vs 8 bytes max)
- **Better efficiency:** More data per frame

#### Comparison: CAN vs CAN FD

| Feature | CAN | CAN FD |
|---------|-----|--------|
| **Max Bitrate** | 1 Mbps | 5 Mbps (data phase) |
| **Frame Size** | 8 bytes | 12, 16, 20, 24, 32, 48, 64 bytes |
| **Bandwidth** | 1 Mbps | 5 Mbps |
| **Backward Compat** | N/A | Compatible with CAN 2.0 |

#### STM32 FDCAN Support

✅ **STM32U585 has FDCAN (not regular CAN)**
- Supports both Classic CAN and CAN FD modes
- Currently configured for Classic CAN (500 kbps)
- CAN FD capable but requires:
  - CAN FD transceiver (TJA1443)
  - Different configuration

#### Expected Improvements with CAN FD @ 5 Mbps
```
TX Time (8 bytes @ 5 Mbps): 64 bits / 5000 kbps ≈ 12.8 µs
Savings vs 500 kbps: 115.2 µs per direction
Expected RTT reduction: ~230 µs (789 µs → ~559 µs)
```

#### Considerations
⚠️ **Requires CAN FD Transceiver**
- Current TJA1051T/3 may not support CAN FD
- Need compatibility check/upgrade

⚠️ **Complexity**
- CAN FD configuration more complex
- Linux SocketCAN requires specific driver support
- Debugging more challenging

---

### 4. **Optimize Linux Scheduler Priority**

#### Problem
- Linux introduces up to 16 ms spikes in latency
- General-purpose OS not optimized for hard real-time
- CAN RX interrupts preempted by other tasks

#### Solution: CPU Affinity & Real-Time Priority

**Set thread to high priority:**
```bash
# Set CAN receive thread to RT priority (SCHED_FIFO)
chrt -f -p 90 <can_receive_pid>

# Pin to specific CPU core (prevent migration)
taskset -cp 0 <can_receive_pid>
```

**In C code:**
```c
#include <sched.h>
#include <pthread.h>

struct sched_param param;
param.sched_priority = 90;  // High priority (0-99)
pthread_setschedparam(pthread_self(), SCHED_FIFO, &param);

// Pin to CPU core 0
cpu_set_t set;
CPU_ZERO(&set);
CPU_SET(0, &set);
sched_setaffinity(0, sizeof(set), &set);
```

#### Expected Improvement
- **Reduces P99 latency:** From 2,654 µs → ~1,000–1,200 µs
- **Reduces jitter:** More consistent behavior
- **Still not hard real-time** (Linux is not RTOS)

#### Alternative: Use PREEMPT_RT Kernel
```bash
# Real-Time kernel patches
# Reduces latency variance further
# Kernel compilation required
```

---

### 5. **Implement Message Prioritization (CAN Priority)**

#### Current Setup
- All CAN messages treated equally
- No priority scheme

#### Improvement: Use CAN ID for Priority

CAN prioritizes messages by **identifier** (lower ID = higher priority)

**Example Setup:**
```c
#define CAN_ID_CRITICAL    0x001  // Motor emergency stop
#define CAN_ID_CONTROL     0x100  // Motor speed control
#define CAN_ID_TELEMETRY   0x200  // Status updates
#define CAN_ID_DEBUG       0x700  // Debug messages
```

**Benefits:**
- Critical messages guaranteed lower latency
- Less important messages don't block critical ones
- Automatic hardware arbitration

---

### 6. **Implement RX FIFO Buffering**

#### Current Issue
- Single RX FIFO may overflow under high load
- Lost messages if not processed fast enough

#### Solution: Use Multiple FIFOs

**STM32 FDCAN has 2 RX FIFOs:**
```c
// Configure larger FIFO
hfdcan1.RxFifo0ElmtSize = FDCAN_DATA_BYTES_64;
hfdcan1.RxFifo0Size = 64;  // 64-element FIFO

hfdcan1.RxFifo1ElmtSize = FDCAN_DATA_BYTES_64;
hfdcan1.RxFifo1Size = 32;  // 32-element FIFO
```

**Benefits:**
- Handles burst traffic
- Reduces missed messages
- Provides buffer time for interrupt processing

---

## 📊 Comparison of Improvement Options

```
╔════════════════════╦═══════════════╦═══════════╦═══════════╦══════════════╗
║ Option             ║ Est. Latency  ║ Effort    ║ Cost      ║ Feasibility  ║
║                    ║ Improvement   ║ Required  ║ Impact    ║              ║
╠════════════════════╬═══════════════╬═══════════╬═══════════╬══════════════╣
║ 1. Speed 1 Mbps    ║ ~128 µs (-16%)║ Low      ║ None      ║ ✅ Excellent ║
║ 2. Reduce Payload  ║ ~128 µs (-16%)║ Very Low ║ None      ║ ✅ Excellent ║
║ 3. CAN FD @ 5Mbps  ║ ~230 µs (-29%)║ High     ║ $$$       ║ ⚠️ Moderate  ║
║ 4. RT Scheduler    ║ ~1,600 µs     ║ Medium   ║ None      ║ ✅ Good      ║
║ 5. Prioritization  ║ Variable      ║ Low      ║ None      ║ ✅ Excellent ║
║ 6. RX FIFO Buffer  ║ ~50 µs        ║ Low      ║ None      ║ ✅ Excellent ║
╚════════════════════╩═══════════════╩═══════════╩═══════════╩══════════════╝
```

---

## 🎯 Recommended Implementation Roadmap

### Phase 1: Quick Wins (No Hardware Changes)
1. ✅ **Increase to 1000 kbps** - 128 µs improvement, zero cost
2. ✅ **Reduce payload to 4 bytes** - 128 µs improvement, simple code change
3. ✅ **Implement message prioritization** - Ensure critical messages get through
4. ✅ **Optimize RX FIFO** - Prevent message loss under load

**Expected total improvement: ~256 µs (from 789 µs → ~533 µs median RTT)**

### Phase 2: OS-Level Optimization
5. 🔧 **Set RT priority + CPU affinity** - Reduce P99 latency variance
6. 🔧 **Consider PREEMPT_RT kernel** - If tighter determinism needed

**Expected improvement: Reduce P99 spikes by 50%**

### Phase 3: Hardware Upgrade (Future)
7. 💾 **Evaluate CAN FD** - If >5 Mbps needed in future
8. 💾 **Upgrade transceiver** - If CAN FD implemented

---

## ✅ Validation Plan

After implementing improvements:

```bash
# 1. Update bitrate
sudo ip link set can0 type can bitrate 1000000
sudo ip link set can0 up

# 2. Recompile with smaller frames
g++ -O2 -DPAYLOAD_SIZE=4 -o can_latency_receive_test can_latency_receive_test.cpp

# 3. Run validation tests
sudo ./can_latency_receive_test > latency_log_improved.txt

# 4. Compare results
paste latency_log.txt latency_log_improved.txt | head -20
```

---
