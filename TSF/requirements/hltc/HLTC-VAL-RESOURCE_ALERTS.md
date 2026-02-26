---
id: HLTC-VAL-RESOURCE_ALERTS
header: "Resource Alert Operator Notification"
text: |
  "Validates that system resource warnings are effectively communicated to the operator."

verification_method: "System Validation (Fault Injection + Observation)"

parents:
  - id: URD-RESOURCES_MONITOR

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
When a resource threshold (CPU temp or Battery voltage) is breached via stress/injection, the HMI shall trigger a visible warning popup or audible alert to the operator.
