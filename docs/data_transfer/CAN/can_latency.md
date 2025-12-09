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

### Formulas

**One-way latency (theoretical):**
```
Latency_one_way = t_reception - t_transmission
```

**Round-trip latency (what we measure):**
```
RTT = t_echo_received - t_original_sent
```

**Estimated one-way latency:**
```
Latency_one_way ≈ RTT / 2
```
(Assumes symmetric send/receive paths)

---

## 🔄 Test Setup Clarification

### How the Test Works

1. **Raspberry Pi** sends a CAN frame with embedded timestamp `t0`
2. **Receiver** (STM32 or kernel loopback) **echoes back** the exact same frame
3. **Raspberry Pi** receives the echo and calculates `RTT = t1 - t0`

### Two Test Configurations

#### Configuration 1: STM32 Hardware Echo
- Raspberry Pi → CAN bus → STM32 transceiver → STM32 firmware → STM32 transceiver → CAN bus → Raspberry Pi
- **Measures:** Full hardware round-trip including:
  - Physical bus propagation
  - CAN transceiver delays
  - STM32 firmware processing time
  - OS scheduling on both sides

#### Configuration 2: Loopback Mode
- Raspberry Pi → Linux kernel SocketCAN → **immediate echo** → Raspberry Pi
- **Measures:** Software stack overhead only (no hardware)
- Kernel automatically echoes frames back to sender

---

## 📊 Interpreting the Results

### What the Measured Values Mean

| Measured RTT | Approximate One-Way Latency | Description |
|--------------|----------------------------|-------------|
| 789 µs (STM32 median) | ~395 µs | Time for message to reach STM32 |
| 593 µs (Loopback median) | ~297 µs | Kernel processing time only |
| 16,724 µs (STM32 max) | ~8,362 µs | Worst-case with OS interference |

**Important:** These are **round-trip** measurements. For one-way latency estimates, divide by 2 (assuming symmetric paths).

### Test Environment 1: STM32 Hardware (CAN1) + Raspberry Pi
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

### Test Environment 2: Loopback Mode (CAN Virtual Interface)
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

---

## 📈 Comparative Analysis

### STM32 vs Loopback (Round-Trip Times)

```
╔═══════════════════════╦════════════════╦═══════════════╦════════════════╗
║ Metric                ║ STM32 RTT (µs) ║ Loopback (µs) ║ Difference (%) ║
╠═══════════════════════╬════════════════╬═══════════════╬════════════════╣
║ Minimum Latency       ║ 710            ║ 522           ║ -26.5%         ║
║ Maximum Latency       ║ 16,724         ║ 721           ║ +2,220%        ║
║ Mean Latency          ║ 1,003          ║ 592           ║ +69.3%         ║
║ Median Latency        ║ 789            ║ 593           ║ +33.0%         ║
║ P95 Latency           ║ 917            ║ 605           ║ +51.6%         ║
╚═══════════════════════╩════════════════╩═══════════════╩════════════════╝
```

### Key Observations

#### 1. **Hardware Adds ~200 µs to Round-Trip Time**
- STM32 RTT median: 789 µs
- Loopback RTT median: 593 µs
- Hardware overhead: **196 µs total** (~98 µs each direction)
- This includes CAN transceiver delays + physical bus propagation + STM32 processing

#### 2. **Estimated One-Way Latencies**
- **STM32:** ~395 µs typical one-way latency
- **Loopback:** ~297 µs typical (software stack only)
- **Hardware contribution:** ~98 µs per direction

#### 3. **Both Are Suitable for Motor Control**
- Motor control loops run at 10–100 Hz (10–100 ms periods)
- Even worst-case one-way latency of ~8 ms is acceptable
- P95 one-way latency of ~459 µs provides excellent real-time performance

---

## 🎯 Conclusions

### System Performance Assessment

✅ **Suitable for Real-Time Motor Control**
- **Median one-way latency:** ~395 µs is excellent for motor control
- **P95 one-way latency:** ~459 µs provides good determinism
- **Worst-case (P99):** ~1.3 ms one-way still acceptable for control loops

📌 **Hardware Contribution is Reasonable**
- Physical CAN adds ~98 µs per direction
- Total hardware overhead: ~196 µs round-trip
- Within expected range for CAN bus communication

⚠️ **Round-Trip vs One-Way Clarification**
- All measurements are **round-trip times (RTT)**
- For one-way latency estimates, divide by 2
- Actual one-way latency may vary slightly due to asymmetric processing

### Recommendations

- ✅ **Proceed with STM32 CAN implementation** - RTT latency is suitable
- 🔧 **Set timeouts based on RTT values** - use 5 ms (conservative margin above P99 RTT)
- 📊 **Consider one-way latency** when designing control loops (~400 µs typical)
- 🎯 **Account for both directions** - total control loop delay includes send + receive

---

## 📚 Technical References

- **ISO 11898-1:** CAN Protocol Specification
- **Linux SocketCAN:** https://www.kernel.org/doc/html/latest/networking/can.html
- **STM32U585 CAN Hardware:** https://www.st.com/en/microcontrollers/stm32u585ai.html
- **Real-Time Requirements:** ISO 26262 (Functional Safety)

---

## 📁 Related Files

| File | Purpose |
|------|---------|
| `can_latency_receive_test.cpp` | Latency measurement tool source code |
| `latency_log.txt` | STM32 hardware test results (1000 samples) |
| `can_lat_loop_log.txt` | Loopback test results (1000 samples) |
| `can_latency.md` | This document |

## 🔗 How to Reproduce

### STM32 Hardware Test
```bash
cd /path/to/project
g++ -O2 -o can_latency_receive_test can_latency_receive_test.cpp
sudo ./can_latency_receive_test > latency_log.txt
```

### Loopback Test
```bash
sudo ip link add dev can-virt type vcan
sudo ip link set can-virt up
# Modify can_latency_receive_test.cpp to use "can-virt"
./can_latency_receive_test > can_lat_loop_log.txt
```

---

**Last Updated:** December 2025  
**Test Platform:** Raspberry Pi + STM32U585  
**Author:** Team04_DrivaPi
