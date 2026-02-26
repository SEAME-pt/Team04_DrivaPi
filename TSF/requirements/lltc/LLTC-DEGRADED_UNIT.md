---
id: LLTC-DEGRADED_UNIT
header: "Unit Tests for Degraded Control Logic"
text: |
  "Verifies state machine transitions to degraded mode."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-DEGRADED_CONTROL

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
#       path: artifacts/verification/tests/degraded_control.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify that the control logic restricts speed output when the degraded state flag is active.
