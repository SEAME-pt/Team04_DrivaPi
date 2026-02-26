# HARA Overview: DrivaPi Autonomous Vehicle System

## 1. Item Definition & Scope
- **Item:** Full DrivaPi System (PiRacer with Raspberry Pi 5, STM32 firmware, ThreadX RTOS, Qt HMI, vision/ultrasonic sensors).
- **Functions:** Propulsion, steering, speed monitoring, obstacle detection (vision primary/ultrasonic fallback), autonomous control, HMI, communication, startup.
- **Operational Context:** Educational/lab environment; controlled test track; max speed 4 m/s; trained operators always present.
- **Global Assumptions:** Small-scale vehicle (low mass/torque); no public road use; E-stop always available; hazards limited to minor injuries.

## 2. Consolidated Hazard Summary
All 10 hazards with ASIL, linked URDs, and SGs.

| Hazard ID | Description | Linked URD(s) | Severity (S) | Exposure (E) | Controllability (C) | ASIL | Safety Goal (SG) |
|:----------|:------------|:--------------|:-------------|:-------------|:--------------------|:-----|:-----------------|
| H-01      | False Zero Speed Indication | URD-SPEED_MEASUREMENT, URD-FAULT_FAILSAFE | S1 | E2 | C1 | A | SG-01 |
| H-02      | Unintended Acceleration | URD-PROPULSION_CONTROL, URD-EMERGENCY_STOP | S1 | E3 | C2 | A | SG-02 |
| H-03      | Unintended Steering | URD-STEERING_CONTROL | S1 | E3 | C2 | A | SG-03 |
| H-04      | Missed Obstacle Detection (Vision primary) | URD-OBSTACLE_AVOIDANCE | S1 | E3 | C1 | A | SG-04 |
| H-05      | Lane Misdetection | URD-LANE_DETECTION | S1 | E2 | C1 | QM | SG-05 |
| H-06      | Scheduling Overrun/Delay | URD-DETERMINISTIC_SCHED | S2 | E2 | C2 | A | SG-06 |
| H-07      | Stale or Inaccurate HMI Display | URD-DRIVER_DASHBOARD | S1 | E3 | C1 | QM | SG-07 |
| H-08      | Communication Loss | URD-HMI_COMMUNICATION, URD-COMM_INTEGRITY | S2 | E3 | C2 | A | SG-08 |
| H-09      | Calibration/Startup Failure | URD-STARTUP_CALIBRATION | S1 | E3 | C1 | QM | SG-09 |
| H-10      | Control Instability | URD-DETERMINISTIC_SCHED | S1 | E3 | C1 | QM | SG-10 |

## 3. Overall Risk Assessment Rationale
- **Severity (S)**: Max S2 – small vehicle/low speed (bruises/cuts only).
- **Exposure (E)**: E2-E3 – lab tests intermittent.
- **Controllability (C)**: C1-C2 – operator supervision/E-stop.
- **ASIL Distribution**: 5 A, 5 QM – tailored for educational project (ISO 26262 Part 9).

## 4. References
- Detailed HARAs: hara_actuation.md, hara_motor_speed.md, hara_obstacle.md, etc.
- Traceability: SGs → URDs → SRD/SWD in TSF DAG.
