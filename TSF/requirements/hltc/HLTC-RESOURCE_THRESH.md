---
id: HLTC-RESOURCE_THRESH
header: "Resource Threshold Protection (System Functional)"
text: |
  "Proves SRD-SYS-RES_MONITOR behavior with explicit threshold triggers and observed actions."
verification_method: "System Functional Test (Stress/Inject + Logs)"

parents:
  - id: SRD-SYS-RES_MONITOR

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
When resource thresholds are exceeded (temperature/voltage/storage), the system shall detect, log, and enter the specified safe/degraded state.
---
