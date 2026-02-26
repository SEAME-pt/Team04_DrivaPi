---
id: LLTC-COMM_MON_COV
header: "Code Coverage for Comm Monitor"
text: |
  "Ensures communication timeout and congestion monitoring logic is covered."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-COMM_MONITOR

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
#       path: artifacts/verification/coverage/comm_monitor.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for the implementation of SWD-COMM_MONITOR.
---
