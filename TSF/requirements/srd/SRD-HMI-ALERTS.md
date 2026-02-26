---
id: SRD-HMI-ALERTS
header: "Critical Alert Presentation"
text: |
  "Ensures immediate operator awareness of hazards."
verification_method: "System Testing"
parents:
  - id: URD-DRIVER_DASHBOARD
  - id: URD-FAULT_FAILSAFE
children:
  - id: SWD-QT_ALERTS
  - id: HLTC-ALERT_DISPLAY
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_hmi.md
    description: "Supports SG-07 (Fresh Display)"
active: true
derived: false
normative: true
level: 2.0
---
HMI shall display prominent alerts for collision, stall, communications loss.
---
