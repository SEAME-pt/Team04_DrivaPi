---
id: LLTC-SPEED_SENSOR_COV
header: "Code Coverage for Speed Sensor"
text: |
  "Ensures unit tests exercise the vast majority of source code using CI-generated reports."

# TSF Type: Evidence
verification_method: "Code Coverage Analysis (LCOV/GCOVR)"

parents:
  - id: SWD-SPEED_CALC

reviewers:
  - name: "Bernardo Esteves"
    email: "bernardo.esteves@seame.pt"

reviewed: '2026-01-05 - Approved by Bernardo Esteves <bernardo.esteves@seame.pt>'

evidence:
  type: coverage_threshold_validator
  configuration:
    min_line_rate: 90
    references:
    - type: file
      path: artifacts/verification/coverage/speed-sensor.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% line coverage for 'speed_sensor.c' to verify safety-critical branches.
---
