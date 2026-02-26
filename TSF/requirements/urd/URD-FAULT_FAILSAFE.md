---
id: URD-FAULT_FAILSAFE
header: "Fault Detection & Failsafe"
text: |
  "Detects and responds to system faults for safety."
verification_method: "System Testing"
children:
  - id: SRD-SAFE-MONITOR
  - id: SRD-HMI-ALERTS
  - id: HLTC-FAULT_INJECTION
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_motor_speed.md
    description: "Mitigates Hazard H-01 (False Zero Speed)"
  - type: "file"
    path: docs/standards/iso26262/hara_actuation.md
    description: "Mitigates Hazard H-02 (Unintended Acceleration)"
active: true
derived: false
normative: true
level: 1.0
---
The system shall detect motor stalls, sensor failures, or loss of communication within 100 ms and transition to a safe state (e.g. halt or reduced speed) within 200 ms while alerting the operator.
---
