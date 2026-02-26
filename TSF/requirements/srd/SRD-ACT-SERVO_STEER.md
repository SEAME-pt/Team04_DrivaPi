---
id: SRD-ACT-SERVO_STEER
header: "Servo Steering Interface"
text: |
  "Ensures commanded angle translates to safe physical wheel position."
verification_method: "Integration Testing"
parents:
  - id: URD-STEERING_CONTROL
children:
  - id: SWD-SERVO_DRIVER
  - id: HLTC-STEERING-ACCURACY
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
references:
  - type: "file"
    path: docs/standards/iso26262/hara_actuation.md
    description: "Supports SG-03 (Safe Steering)"
active: true
derived: false
normative: true
level: 2.0
---
The system shall control the steering servo via PCA9685, mapping 0–180° angles to calibrated PWM values and enforcing mechanical limits.
