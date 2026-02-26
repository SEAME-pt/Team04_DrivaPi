---
id: SWD-COMM_MONITOR
header: "Communication Monitoring Logic"
text: |
  "Monitors communication health for timeouts and congestion."
ASIL: "A"
verification_method: "Unit Testing, Integration Testing"
parents:
  - id: SRD-COMM-TIMEOUT_MGMT
children:
  - id: LLTC-COMM_MON_COV
  - id: LLTC-COMM_MON_UNIT
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
active: true
derived: false
normative: true
level: 3.0
---
The software shall monitor CAN and internal bus communication for timeouts, stale data and congestion.
---
