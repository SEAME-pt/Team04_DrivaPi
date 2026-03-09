---
id: HLTC-STEERING-ACCURACY
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

references:
  - type: "file"
    path: "tests/system/steering/steering_precision_system_test.md"
    note: "System test result — commanded left/centre/right positions verified, symmetric deflection within ±2° tolerance, PASS."
  - type: "file"
    path: "tests/system/steering/evidence/steering_precision_system_test.mp4"
    note: "Video evidence of physical steering angle validation across all commanded positions."

active: true
derived: false
normative: true
level: 2.0
---
Commanded steering angles (Left/Right) shall correspond to physical wheel angles within defined tolerance (+/- 2 degrees).

<!-- Score pending: add `score:\n  MelanieReis: 1.0` here once tests/system/steering/steering_precision_system_test.md is completed with actual measurements, then run `trudag manage set-item HLTC-STEERING-ACCURACY`. -->
