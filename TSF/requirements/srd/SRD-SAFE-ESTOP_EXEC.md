---
id: SRD-SAFE-ESTOP_EXEC
header: "Emergency Stop Execution"
text: |
  "Critical failsafe response to faults or obstacles."
verification_method: "System Testing"
parents:
  - id: URD-EMERGENCY_STOP
children:
  - id: SWD-ESTOP_EXEC
  - id: HLTC-ESTOP_TIME
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
references:
  - type: "file"
    path: docs/standards/iso26262/hara_actuation.md
    description: "Supports SG-02 (Safe Propulsion)"
active: true
derived: false
normative: true
level: 2.0
---
The control system shall zero motor PWM and center servo within 100ms on hazard trigger.
