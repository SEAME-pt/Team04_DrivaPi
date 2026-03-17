---
id: HLTC-SPEED-ACCURACY
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

references:
  - type: "file"
    path: "tests/system/speed/speed_accuracy_system_test.md"
    note: "System test result — 2.52% deviation at ~1.05 m/s over 2 m, PASS (tolerance < 5%). Measurements from KUKSA data broker cross-checked against stopwatch timing."

score:
  MelanieReis: 1.0

active: true
derived: false
normative: true
level: 2.0
---
Reported vehicle speed shall match external ground truth measurements within +/- 5% at speeds up to 4 m/s.
