---
id: LLTC-DEGRADED_COV
header: "Code Coverage for Degraded Control"
text: |
  "Ensures the degraded mode state machine and speed limiting logic are covered."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-DEGRADED_CONTROL

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
#       path: artifacts/verification/coverage/degraded_control.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for the implementation of SWD-DEGRADED_CONTROL.
---
