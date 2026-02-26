---
id: HLTC-FAULT_INJECTION
header: "Fault Injection & Failsafe Reaction (System Functional)"
text: |
  "Validates URD-FAULT_FAILSAFE and degraded-mode transitions under realistic injected faults."

verification_method: "System Functional Test (Fault Injection + Logs)"

parents:
  - id: URD-FAULT_FAILSAFE

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
Injected faults (sensor disconnect, comms loss, actuator stall) shall be detected and shall trigger safe/degraded behavior as specified.
