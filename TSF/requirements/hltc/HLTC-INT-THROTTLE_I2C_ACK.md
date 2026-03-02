---
id: HLTC-INT-THROTTLE_I2C_ACK
header: "Throttle I2C Command & ACK (Integration Test)"
text: |
  "Verifies that throttle commands are translated into I2C transactions to the throttle motor controller (0x60) and that ACK/NACK handling is correct."
verification_method: "Integration Test (I2C ACK/NACK + UART Logs)"

parents:
  - id: SRD-ACT-MOTOR_DRIVE
  - id: URD-PROPULSION_CONTROL

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

references:
  - type: "file"
    path: "tests/integration/integration_tests_plan.md"
    note: "Phase C — CAN throttle command → I2C write to 0x60 → ACK received."
  - type: "file"
    path: "tests/integration/motors-and-speed-sensor-integration/src/i2c_integration_test.c"
    note: "Phase C — throttle write + ACK test implementation."
  - type: "file"
    path: "tests/integration/motors_integration.mp4"
    note: "Phase C — demonstration of successful I2C communication and actuation."

score:
  MelanieReis: 1.0

active: true
derived: false
normative: true
level: 2.0
---
For valid throttle commands, STM32 shall issue I2C writes to address 0x60 and receive ACK. NACK/timeouts shall be handled without crash and without unintended motor activation.
---
