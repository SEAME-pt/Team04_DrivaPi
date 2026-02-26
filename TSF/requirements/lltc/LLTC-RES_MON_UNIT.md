---
id: LLTC-RES_MON_UNIT
header: "Unit Tests for Resource Monitor"
text: |
  "Verifies threshold comparison logic with mock inputs."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-RESOURCE_MONITOR

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
#       path: artifacts/verification/tests/resource_monitor.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify that the monitor triggers alerts when mock temperature or voltage inputs exceed defined thresholds.
