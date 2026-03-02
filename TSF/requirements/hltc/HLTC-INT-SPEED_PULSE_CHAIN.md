---
id: HLTC-INT-SPEED_PULSE_CHAIN
header: "Speed Sensor Pulse Chain (Integration Test)"
text: |
  "Validates the speed sensor integration chain: PD9 rising-edge interrupt → pulse counter → UART confirmation output, including stable behavior with zero pulses and sustained operation."
verification_method: "Integration Test (EXTI Interrupt + UART Log Consistency)"

parents:
  - id: SRD-SENS-ENCODER_SPD
  - id: URD-SPEED_MEASUREMENT

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

references:
  - type: "file"
    path: "tests/integration/integration_tests_plan.md"
    note: "Phase D — speed sensor PD9 rising-edge interrupt, pulse counting, UART output, pass criteria."
  - type: "file"
    path: "tests/integration/motors-and-speed-sensor-integration/src/stm32u5xx_it.c"
    note: "Phase D — EXTI9_IRQHandler increments pulse_count and prints UART message."
  - type: "file"
    path: "tests/integration/motors-and-speed-sensor-integration/src/main.c"
    note: "Phase D — speed sensor interrupt configuration."
  - type: "file"
    path: "tests/integration/speed_sensor_integration.mp4"
    note: "Phase D — demonstration video of pulse detection and UART output."

score:
  MelanieReis: 1.0

active: true
derived: false
normative: true
level: 2.0
---
The EXTI9 interrupt shall fire on each PD9 pulse, pulse_count shall increment correctly, UART shall output a confirmation per pulse, and the system shall remain stable with zero pulses and under sustained pulse input.
---
