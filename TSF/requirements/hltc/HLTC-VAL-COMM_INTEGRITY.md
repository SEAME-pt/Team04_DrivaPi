---
id: HLTC-VAL-COMM_INTEGRITY
header: "Command Integrity & Rejection Validation"
text: |
  "Ensures the system detects bus-level failures—including timeouts, stale data, and congestion—and transitions to a safe or degraded mode."

verification_method: "System Validation (Fault Injection)"

parents:
  - id: URD-COMM_INTEGRITY

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
The system shall be validated by simulating CAN and internal bus faults—specifically communication timeouts, stale data, and bus congestion—to verify that the system detects these conditions and enters the defined safe or degraded mode within the required latency.
---
