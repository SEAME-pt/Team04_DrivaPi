---
id: SRD-COMM-TIMEOUT_MGMT
header: "Communication Timeout & Congestion Handling"
text: |
  "Detects and handles communication timeouts and congestion."
verification_method: "Integration Testing"
parents:
  - id: URD-COMM_INTEGRITY
children:
  - id: SWD-COMM_MONITOR
  - id: HLTC-STALE_DATA
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_comms.md
    description: "Mitigates Hazard H-08 (Stale Data)"
active: true
derived: false
normative: true
level: 2.0
---
The system shall detect communication timeouts, stale data and bus congestion on the CAN or internal bus.
---
