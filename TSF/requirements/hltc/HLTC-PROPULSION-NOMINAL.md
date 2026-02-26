---
id: HLTC-PROPULSION_NOMINAL
header: "Propulsion Control System Test"
text: |
  "Verifies that throttle commands translate to correct wheel rotation and direction."
verification_method: "System Test (Tachometer/Encoder + Logs)"

parents:
  - id: SRD-ACT-MOTOR_DRIVE
  - id: URD-PROPULSION_CONTROL

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
Throttle commands (0-100%) shall produce proportional wheel speeds, and direction commands shall correctly define motor rotation.
