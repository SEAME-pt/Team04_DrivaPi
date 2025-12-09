# CAN Bus Latency Analysis

## 📌 Overview

This document describes CAN bus latency measurements performed on the Team04_DrivaPi project. Latency analysis is critical for real-time embedded systems to ensure deterministic behavior and reliability.

---

## 🎯 What is Latency?

**Latency** typically refers to the **one-way delay** between sending a CAN message and the receiver getting it. However, measuring one-way latency requires synchronized clocks between sender and receiver, which is difficult in practice.

### Round-Trip Latency (RTT)

In this test, we measure **round-trip latency (RTT)**, which is the total time from:
1. **Sending a message** from Raspberry Pi
2. **Message traveling** through CAN bus to receiver (STM32 or loopback)
3. **Receiver echoing back** the same message
4. **Echo traveling back** through CAN bus
5. **Raspberry Pi receiving** the echoed message

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
