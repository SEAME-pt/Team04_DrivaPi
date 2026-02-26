---
id: LLTC-SPEED_SENSOR_UNIT
header: "Unit Test Verification for Speed Logic"
text: |
  "Verifies logic correctness via CI-generated `junit_results.xml`."

# TSF Type: Evidence
verification_method: "Automated Unit Testing (CTest/Unity)"

parents:
  - id: SWD-SPEED_CALC

reviewers:
  - name: "Bernardo Esteves"
    email: "bernardo.esteves@seame.pt"

reviewed: '2026-01-09 - Approved by Bernardo Esteves <bernardo.esteves@seame.pt>'

references:
  - type: "file"
    path: "tests/unit/speed-sensor/test/test_speed_sensor.c"
    description: "Test Source Code"

evidence:
  type: junit_pass_rate_validator
  configuration:
    min_pass_rate: 100
    references:
      - type: file
        path: artifacts/verification/tests/speed-sensor.xml

active: true
derived: false
normative: true
level: 4.0
---
Speed sensor unit tests must pass (100%) covering movement, overflows, and edge cases.
---
