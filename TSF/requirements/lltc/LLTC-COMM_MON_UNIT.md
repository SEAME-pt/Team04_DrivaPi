---
id: LLTC-COMM_MON_UNIT
header: "Unit Tests for Comm Monitor"
text: |
  "Verifies timeout counters and congestion flag logic."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-COMM_MONITOR

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
#       path: artifacts/verification/tests/comm_monitor.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify that the monitor correctly increments timeout counters and sets the congestion flag upon buffer saturation.
