---
id: URD-RESOURCES_MONITOR
header: "System Resource Monitoring"
text: |
  "Monitors Raspberry Pi/STM32 resources and alerts on thresholds."
verification_method: "System Testing + Validation Evidence (Logs)"
children:
  - id: SRD-SYS-RES_MONITOR
  - id: HLTC-VAL-RESOURCE_ALERTS
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_overview.md
    description: "Mitigates General System Hazards (H-06, H-09)"
active: true
derived: false
normative: true
level: 1.0
---
The system shall monitor defined resource thresholds (CPU, memory, power, etc.) on both Raspberry Pi and STM32. If any threshold is exceeded, the system shall alert the operator or enter a safe/degraded state.
---
