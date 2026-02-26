---
id: LLTC-ESTOP_UNIT
header: "Unit Tests for E-Stop Handler"
text: |
  "Verifies immediate state transition on trigger."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-ESTOP_EXEC

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
#       path: artifacts/verification/tests/estop.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify that the E-Stop function immediately zeroes PWM targets and sets the servo to neutral.
---
