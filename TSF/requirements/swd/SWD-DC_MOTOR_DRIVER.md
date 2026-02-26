---
id: SWD-DC_MOTOR_DRIVER
header: "DC Motor PWM Driver"
text: |
  "Implements safe propulsion logic with clamping and dead-zone."
ASIL: "A"
verification_method: "Unit Testing, Code Coverage, Static Analysis"
parents:
  - id: SRD-ACT-MOTOR_DRIVE
children:
  - id: LLTC-DC_MOTOR_UNIT
  - id: LLTC-DC_MOTOR_COV
  - id: LLTC-DC_MOTOR_STATIC
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: firmware/Core/Src/dc_motor.c
    description: "Production Implementation"
  - type: "file"
    path: docs/standards/iso26262/asil_justification_SWD-DC_MOTOR.md
    description: "ASIL A Justification"
active: true
derived: false
normative: true
level: 3.0
---
The 'dc_motor' component shall implement input validation (clamp >1.0/< -1.0), direction GPIOs, dead-zone handling, and PWM calculation (speed * 4095).
