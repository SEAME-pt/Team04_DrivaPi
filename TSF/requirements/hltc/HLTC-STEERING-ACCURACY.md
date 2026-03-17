---
id: HLTC-STEERING_ACCURACY
header: "Steering Angle Accuracy System Test"
text: |
  "Verifies that steering commands result in correct physical wheel angles."
verification_method: "System Test (Angle Measurement)"

parents:
  - id: SRD-ACT-SERVO_STEER
  - id: URD-STEERING_CONTROL

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
Commanded steering angles (Left/Right) shall correspond to physical wheel angles within defined tolerance (+/- 2 degrees).
