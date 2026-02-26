---
id: LLTC-SERVO_MOTOR_COV
header: "Code Coverage for Servo"
text: |
  "Ensures steering safety limits are exercised during testing."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-SERVO_DRIVER

reviewers:
  - name: "Miguel Cardoso"
    email: "miguel.cardoso@seame.pt"
reviewed: '2026-01-14 - Approved by Miguel Cardoso <miguel.cardoso@seame.pt>'

evidence:
  type: coverage_threshold_validator
  configuration:
    min_line_rate: 90
    references:
    - type: file
      path: artifacts/verification/coverage/servo-motor.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Branch Coverage for `servo_motor.c`.
---
