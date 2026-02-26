---
id: HLTC-ESTOP_TIME
header: "Emergency Stop Timing (System Functional)"
text: |
  "Proves URD-EMERGENCY_STOP behavior with objective timing evidence (stop + safe steering)."
verification_method: "System Functional Test (Measurement + Logs + Video)"

parents:
  - id: URD-EMERGENCY_STOP

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
On critical stop trigger, propulsion PWM shall reach zero and steering shall enter the defined safe state within 100ms.
