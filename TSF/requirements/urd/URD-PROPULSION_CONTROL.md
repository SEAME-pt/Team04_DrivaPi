---
id: URD-PROPULSION_CONTROL
header: "Propulsion Control"
text: |
  "The user expects the "Gas" and "Brake/Reverse" commands to translate into physical motion."
verification_method: "System Testing"
children:
  - id: SRD-ACT-MOTOR_DRIVE
  - id: HLTC-PROPULSION_NOMINAL
  - id: HLTC-INT-THROTTLE_I2C_ACK
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_actuation.md
    description: "Mitigates Hazard H-02 (Unintended Acceleration)"
active: true
derived: false
normative: true
level: 1.0
---
The vehicle shall translate throttle/brake commands into forward or reverse motion at the requested speed (0–100% of full speed).
---
