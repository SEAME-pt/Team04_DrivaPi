---
id: LLTC-ULTRASONIC_COV
header: "Code Coverage for Ultrasonic Driver"
text: |
  "Ensures driver logic is covered."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-ULTRASONIC_DRIVER

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

# evidence:
#   type: coverage_threshold_validator
#   configuration:
#     min_line_rate: 90
#     references:
#     - type: file
#       path: artifacts/verification/coverage/ultrasonic.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for the ultrasonic driver.
---
