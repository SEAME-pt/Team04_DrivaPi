---
id: LLTC-QUEUE_MON_UNIT
header: "Unit Tests for Queue Monitor"
text: |
  "Verifies queue usage calculation and overflow logic."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-QUEUE_MONITOR

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
#       path: artifacts/verification/tests/queue_monitor.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify that the monitor accurately reports queue usage statistics and flags overflows.
