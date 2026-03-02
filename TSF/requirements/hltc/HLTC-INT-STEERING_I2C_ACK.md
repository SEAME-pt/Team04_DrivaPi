---
id: HLTC-INT-STEERING_I2C_ACK
header: "Steering I2C Command & ACK (Integration Test)"
text: |
  "Verifies that steering commands are translated into I2C transactions to the steering controller (0x40) and that ACK/NACK handling is correct."
verification_method: "Integration Test (I2C ACK/NACK + UART Logs)"

parents:
  - id: SRD-ACT-SERVO_STEER
  - id: URD-STEERING_CONTROL

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

references:
  - type: "file"
    path: "tests/integration/integration_tests_plan.md"
    note: "Phase C — CAN steering command → I2C write to 0x40 → ACK received."
  - type: "file"
    path: "tests/integration/motors-and-speed-sensor-integration/src/i2c_integration_test.c"
    note: "Phase C — steering write + ACK test implementation."
  - type: "file"
    path: "tests/integration/motors_integration.mp4"
    note: "Phase C — demonstration of successful steering I2C communication and servo motion."

score:
  MelanieReis: 1.0
active: true
derived: false
normative: true
level: 2.0
---
For valid steering commands, STM32 shall issue I2C writes to address 0x40 and receive ACK. NACK/timeouts shall be handled without crash and without unintended movement on startup.
---
