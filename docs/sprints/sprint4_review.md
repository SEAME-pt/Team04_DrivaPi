# Sprint 4 Review - Team04 DrivaPi

**Date:** December 9, 2025
**Project:** DrivaPi - Autonomous Vehicle Platform

---

## Sprint Summary

Sprint 4 **exceeded expectations**, achieving nearly all objectives and going beyond initial scope. The team delivered **complete end-to-end communication** from speed sensor to display and **full motor control via ThreadX**.

---

## Major Achievements

### Complete Speed Monitoring System ✅
**End-to-end pipeline operational:**
- GPIO speed sensor pulses → STM32 capture
- ThreadX data conversion and calculation
- CAN communication: STM32 → Raspberry Pi 5
- Qt Serial Bus library reads CAN socket (Linux)
- Real-time speed displayed on Qt application

### Full Motor Control via ThreadX ✅
- Steering and DC motors fully integrated
- Real-time control established

### Research Spikes Completed ✅
- **Kuksa databroker** - spike completed
- **UProtocol** - evaluated and rejected (CAN 8-byte limit vs ~40-byte header requirement)
- **USB Dongle** - theoretical spike concluded
- **CAN documentation** - comprehensive docs completed and approved

---

## Technical Challenges

**CAN & Kuksa Latency (Unknown):**
- Need comprehensive latency testing for CAN communication
- Must measure Kuksa overhead as middleware layer
- Critical for determining optimal architecture

**Pin Conflicts (Resolved):**
- Miguel discovered PB8/PB9 motor pins conflict with FDCAN
- Requires GPIO reconfiguration

---

## Sprint 5 Focus

### Testing Infrastructure (Priority 1)
- Unit tests for STM32 ThreadX code
- Code coverage analysis
- Static analysis (cppcheck)

### Latency Analysis (Priority 2)
- CAN communication latency measurement
- Kuksa databroker overhead evaluation
- Document requirements and benchmarks

### AGL Setup (Priority 3)
- Complete AGL environment for Kuksa testing
- Validate Qt performance with Kuksa on AGL

### Remote Control Integration
- Integrate Gaspar's Rust code
- Define CAN addresses (servo, motor, speed sensor)

**Deferred:** HAILO energy consumption testing (facilitator recommendation - not prioritized)

---

## Overall Sentiment

The team is **extremely proud** of achieving the complete sensor-to-display system. Strong cohesion and technical execution continue to drive exceptional results.

---

**Next review:** Sprint 5 Review (December 22, 2025)
