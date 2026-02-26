---
id: SRD-ACT-MOTOR_DRIVE
header: "DC Motor Propulsion Interface"
text: |
  "Bridges user propulsion command to hardware PWM constraints."
verification_method: "Integration Testing + System Testing"
parents:
  - id: URD-PROPULSION_CONTROL
children:
  - id: SWD-DC_MOTOR_DRIVER
  - id: HLTC-PROPULSION-NOMINAL
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
references:
  - type: "file"
    path: docs/standards/iso26262/hara_actuation.md
    description: "Supports SG-02 (Safe Propulsion)"
active: true
derived: false
normative: true
level: 2.0
---
The system shall control the DC motor via the PCA9685 PWM channels, mapping commanded speed (–1.0…+1.0) to calibrated pulse widths with a dead-zone at 0.0.
