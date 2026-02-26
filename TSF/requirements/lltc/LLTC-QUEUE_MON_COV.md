---
id: LLTC-QUEUE_MON_COV
header: "Code Coverage for Queue Monitor"
text: |
  "Ensures queue usage tracking and overflow detection logic are covered."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-QUEUE_MONITOR

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
#       path: artifacts/verification/coverage/queue_monitor.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for the implementation of SWD-QUEUE_MONITOR.
---
