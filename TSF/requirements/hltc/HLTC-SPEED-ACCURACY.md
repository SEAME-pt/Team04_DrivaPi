---
id: HLTC-SPEED_ACCURACY
header: "Speed Measurement Accuracy Test"
text: |
  "Verifies odometer accuracy against external ground truth."
verification_method: "System Test (External Chronometer/Laser)"

parents:
  - id: SRD-SENS-ENCODER_SPD
  - id: URD-SPEED_MEASUREMENT

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
Reported vehicle speed shall match external ground truth measurements within +/- 5% at speeds up to 4 m/s.
