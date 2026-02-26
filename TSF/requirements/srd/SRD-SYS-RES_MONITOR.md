---
id: SRD-SYS-RES_MONITOR
header: "Resource Monitoring Logic"
text: |
  "Implements threshold checks and alerts."
verification_method: "Integration + System Testing"
parents:
  - id: URD-RESOURCES_MONITOR
children:
  - id: SWD-RESOURCE_MONITOR
  - id: HLTC-RESOURCE_THRESH
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_overview.md
    description: "General Resource Hazard"
active: true
derived: false
normative: true
level: 2.0
---
The resource monitor shall check temperature (>80°C), voltage (<4.8V), storage (<10% free) every 1s and trigger alert or safe state.
---
