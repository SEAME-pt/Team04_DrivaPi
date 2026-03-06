# TSF Validation Report: Emergency Braking System (AEB)

**Document Status:** DRAFT / UNDER REVIEW
**Date of Execution:** 2026-03-06
**Testing Engineer:** Bernardo - bernardo.esteves@seame.pt

## 1. Traceability
* **Target Epic / Safety Requirement ID:** `Functional Safety Testing & TSF Evidence
#386`
* **Validation Goal:** Generate physical and software evidence of AEB latency and track stopping distance for TSF compliance.

## 2. System Under Test (SUT) Specification
* **Chassis Platform:** PiRacer
* **Microcontroller:** STM32 (System Core Clock: 84 MHz)
* **High-Level Compute:** Raspberry Pi 5 
* **Speed Sensor:** Physical LM393 Optical Encoder (Independent of motor PWM)
* **Telemetry Bus:** FDCAN (Classic CAN mode, 8-byte payload limit)
* **Measurement Strategy:** ARM Cortex-M Data Watchpoint and Trace (DWT) Hardware Cycle Counter

## 3. Phase 1: Dynamic Software Latency Validation (Bench & CAN Trace)
**Objective:** Measure the internal MCU processing delay between obstacle detection and PWM termination, isolating RTOS overhead from physical momentum.
**Methodology:** DWT cycle counts captured at `t_detect`, `t_kill`, and `t_stop`. Deltas transmitted over CAN ID `0x102`.

**Empirical Data (Baseline):**
* **Software Processing Latency (Detection to PWM Kill):** 888,399 CPU Cycles
* **Software Time:** 10.57 ms
* **Evaluation:** System architecture meets strict real-time execution constraints. Software overhead is negligible compared to physical chassis inertia.

```
root@raspberrypi5:~# candump can1
  can1  100   [4]  00 00 00 00
  can1  100   [4]  00 00 00 00
  can1  02C   [8]  80 02 00 00 80 02 00 00
  can1  02C   [8]  30 05 00 00 30 05 00 00
  can1  02C   [8]  27 08 00 00 27 08 00 00
  can1  02C   [8]  B8 0B 00 00 B8 0B 00 00
  can1  100   [4]  80 8F 67 3C
  can1  100   [4]  80 8F 67 3C
  can1  300   [1]  02
  can1  100   [4]  04 A0 A4 3F
  can1  100   [4]  04 A0 A4 3F
  can1  100   [4]  04 A0 A4 3F
  can1  300   [1]  00
  can1  100   [4]  BB 41 DE 3F
  can1  100   [4]  BB 41 DE 3F
  can1  100   [4]  BB 41 DE 3F
  can1  100   [4]  9F AB AD 3E
  can1  100   [4]  9F AB AD 3E
  can1  02C   [8]  F7 07 00 00 F7 07 00 00
  can1  02C   [8]  B4 03 00 00 B4 03 00 00
  can1  02C   [8]  00 00 00 00 00 00 00 00
  can1  100   [4]  97 24 3C 3E
  can1  02C   [8]  AB 01 00 00 AB 01 00 00
  can1  02C   [8]  A1 04 00 00 A1 04 00 00
  can1  02C   [8]  27 08 00 00 27 08 00 00
  can1  02C   [8]  B8 0B 00 00 B8 0B 00 00
  can1  100   [4]  97 24 3C 3E
  can1  100   [4]  97 24 3C 3E
  can1  300   [1]  02
  can1  100   [4]  B5 A6 79 3F
  can1  100   [4]  B5 A6 79 3F
  can1  300   [1]  00
  can1  100   [4]  5A 8C BF 3F
  can1  100   [4]  5A 8C BF 3F
  can1  100   [4]  5A 8C BF 3F
  can1  02C   [8]  00 00 00 00 00 00 00 00
  can1  100   [4]  13 61 C3 3E
  can1  100   [4]  13 61 C3 3E
  can1  100   [4]  00 00 00 00
  can1  400   [8]  BD 94 EE 41 1A EB BB 41
  can1  100   [4]  00 00 00 00
  can1  100   [4]  00 00 00 00
  can1  100   [4]  00 00 00 00
  can1  100   [4]  00 00 00 00
  can1  102   [8]  4F 8E 0D 00 96 00 00 00
  can1  100   [4]  00 00 00 00

```

## 4. Phase 2: Physical Track Validation (Efficacy)
**Objective:** Validate the total physical stopping distance against a standardized obstacle.

* **Track Length:** 2.0 meters
* **Obstacle Specification:** 12 x 10 x 5 cm rigid object
* **Target Detection Distance:** 80 cm
* **Target Velocity (v_0):** `1.5 m/s`

**Theoretical Braking Baseline:**
d_total = (v_0 * t_latency) + (v_0^2 / (2 * mu * g))

* Variables: v_0 = 1.5 m/s, t_latency = 0.0105 s, mu (estimated) = 0.62, g = 9.81 m/s^2
* Software Latency Distance Travelled: 1.58 cm
* Physical Braking Distance Travelled: 18.42 cm
* Calculated Expected Stopping Distance: <≈20.0 cm


**Track Test Results:**
* **Attempt 1:** `80 cm` stopping distance from obstacle face
* **Average Stopping Margin:** `~ 9cm`
* **Recorded Video Evidence:** 

## 5. Final Conclusion
**[PASS/FAIL]** - The Emergency Braking System demonstrates a software latency of ~10.5ms and successfully halts the vehicle within the acceptable stopping margin outlined by the Epic's Acceptance Criteria.