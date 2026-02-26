---
id: SWD-FAULT_MONITOR
header: "Fault Monitoring Logic"
text: |
  "Central monitor for multiple fault conditions."
ASIL: "A"
verification_method: "Unit Testing, System Testing"
parents:
  - id: SRD-SAFE-MONITOR
children:
  - id: LLTC-FAULT_UNIT
  - id: LLTC-FAULT_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
# references:
#   - type: "file"
#     path: firmware/Core/Src/fault_monitor.c
#     description: "Production Implementation (placeholder)"
active: true
derived: false
normative: true
level: 3.0
---
Fault monitor shall detect stall, sensor error, comms loss and trigger safe state transition.
