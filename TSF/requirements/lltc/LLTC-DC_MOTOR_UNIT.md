---
id: LLTC-DC_MOTOR_UNIT
header: "Unit Tests for DC Motor"
text: |
  "Verifies the logic within `dc_motor.c`."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-DC_MOTOR_DRIVER

reviewers:
  - name: "Miguel Cardoso"
    email: "miguel.cardoso@seame.pt"
reviewed: '2026-01-14 - Approved by Miguel Cardoso <miguel.cardoso@seame.pt>'

references:
  - type: "file"
    path: "tests/unit/dc-motor/test/test_dc_motor_functions.c"
  - type: "file"
    path: "tests/unit/dc-motor/test/test_threadx_dc_motor_with_mocks.c"
  - type: "file"
    path: "tests/unit/dc-motor/test/test_dc_motor_LLTC_UNIT.c"

evidence:
  type: junit_pass_rate_validator
  configuration:
    min_pass_rate: 100
    references:
    - type: file
      path: artifacts/verification/tests/dc-motor.xml

active: true
derived: false
normative: true
level: 4.0
---
All unit tests for the DC Motor module shall pass, verifying forward/reverse logic and PWM calculations.
---
