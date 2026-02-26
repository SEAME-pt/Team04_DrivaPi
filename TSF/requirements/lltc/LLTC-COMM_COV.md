---
id: LLTC-COMM_COV
header: "Code Coverage for Comm Protocol"
text: |
  "Ensures protocol logic is fully exercised."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-COMM_PROTOCOL

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
#       path: artifacts/verification/coverage/comm_protocol.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for communication protocol source code.
---
