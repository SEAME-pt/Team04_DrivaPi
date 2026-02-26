---
id: SRD-SAFE-DEGRADED_OPS
header: "Degraded Mode Operation"
text: |
  "Defines degraded mode behaviour when communication integrity is compromised."
verification_method: "Integration Testing"
parents:
  - id: URD-COMM_INTEGRITY
children:
  - id: SWD-DEGRADED_CONTROL
  - id: HLTC-DEGRADED_BEHAVIOR
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_comms.md
    description: "Mitigates Hazard H-08 (Communication Loss/Failure)"
active: true
derived: false
normative: true
level: 2.0
---
In case of communication loss, high latency or stale data, the system shall reduce the maximum speed to a safe level (e.g., 10 %–20 % of nominal) or stop the vehicle.
It shall log the event and signal the operator via the HMI.
---
