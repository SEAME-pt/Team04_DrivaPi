---
id: LLTC-ESTOP_COV
header: "Code Coverage for E-Stop Handler"
text: |
  "Ensures safety-critical stop logic is covered."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-ESTOP_EXEC

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

# evidence:
#   type: coverage_threshold_validator
#   configuration:
#     min_line_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/coverage/estop.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve 100% Line Coverage for the emergency stop handler, as this is an ASIL A component.
---
