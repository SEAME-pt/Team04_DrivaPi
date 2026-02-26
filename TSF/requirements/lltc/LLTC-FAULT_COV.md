---
id: LLTC-FAULT_COV
header: "Code Coverage for Fault Monitor"
text: |
  "Ensures critical fault states and transitions are covered by tests."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-FAULT_MONITOR

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# evidence:
#   type: coverage_threshold_validator
#   configuration:
#     min_line_rate: 90
#     references:
#     - type: file
#       path: artifacts/verification/coverage/fault.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests for fault monitoring code must achieve >90% Line Coverage.
---
