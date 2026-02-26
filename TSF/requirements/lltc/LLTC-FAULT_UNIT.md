---
id: LLTC-FAULT_UNIT
header: "Unit Tests for Fault Monitor"
text: |
  "Verifies that faults are detected deterministically and exported to the safety layer correctly."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-FAULT_MONITOR

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# references:
#   - type: "file"
#     path: "tests/unit/fault-monitor/test/test_fault_monitor.c"
#   - type: "file"
#     path: "tests/unit/fault-monitor/test/test_fault_monitor_with_mocks.c"

# evidence:
#   type: junit_pass_rate_validator
#   configuration:
#     min_pass_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/tests/fault.xml

active: true
derived: false
normative: true
level: 4.0
---
All unit tests for the fault monitor shall pass, validating fault detection, fault latching, and reporting behavior.
---
