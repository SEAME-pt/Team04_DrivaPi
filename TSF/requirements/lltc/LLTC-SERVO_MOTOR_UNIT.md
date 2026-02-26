---
id: LLTC-SERVO_MOTOR_UNIT
header: "Unit Tests for Steering Servo"
text: |
  "Verifies the logic within `servo_motor.c`."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-SERVO_DRIVER

reviewers:
  - name: "Miguel Cardoso"
    email: "miguel.cardoso@seame.pt"
reviewed: '2026-01-14 - Approved by Miguel Cardoso <miguel.cardoso@seame.pt>'

references:
  - type: "file"
    path: "tests/unit/servo-motor/test/test_servo_functions.c"
  - type: "file"
    path: "tests/unit/servo-motor/test/test_threadx_servo_motor_with_mocks.c"

evidence:
  type: junit_pass_rate_validator
  configuration:
    min_pass_rate: 100
    references:
    - type: file
      path: artifacts/verification/tests/servo-motor.xml

active: true
derived: false
normative: true
level: 4.0
---
All unit tests for the Servo Motor module shall pass, verifying angle clamping and pulse mapping.
---
