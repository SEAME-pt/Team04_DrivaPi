---
id: SRD-SAFE-MONITOR
header: "Fault Monitoring & Response"
text: |
  "Central safety monitor for multiple hazards."
verification_method: "System Testing"
parents:
  - id: URD-FAULT_FAILSAFE
children:
  - id: SWD-FAULT_MONITOR
  - id: HLTC-PLAUSIBILITY_TEST
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_motor_speed.md
    description: "Supports SG-01"
  - type: "file"
    path: docs/standards/iso26262/hara_actuation.md
    description: "Supports SG-02"
active: true
derived: false
normative: true
level: 2.0
---
System shall monitor for stall, sensor error, communications loss and trigger safe state.
---
