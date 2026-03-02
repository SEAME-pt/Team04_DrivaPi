---
id: URD-STEERING_CONTROL
header: "Steering Control"
text: |
  "The user expects the steering command input to translate into physical wheel angle changes."
verification_method: "System Testing"
children:
  - id: SRD-ACT-SERVO_STEER
  - id: HLTC-STEERING_ACCURACY
  - id: HLTC-INT-STEERING_I2C_ACK
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_actuation.md
    description: "Mitigates Hazard H-03 (Unintended Steering)"
active: true
derived: false
normative: true
level: 1.0
---
The vehicle shall steer left and right according to the commanded angle.
---
