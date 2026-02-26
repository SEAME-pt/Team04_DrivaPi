---
id: LLTC-ULTRASONIC_UNIT
header: "Unit Tests for Ultrasonic Driver"
text: |
  "Verifies pulse width to distance conversion logic."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-ULTRASONIC_DRIVER

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

# evidence:
#   type: junit_pass_rate_validator
#   configuration:
#     min_pass_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/tests/ultrasonic.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify the calculation of distance (cm) from timer ticks, including filtering of noise/outliers.
---
