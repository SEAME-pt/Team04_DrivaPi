---
id: SRD-HMI-DASHBOARD
header: "Real-Time Dashboard Display"
text: |
  "Provides operator with current vehicle state."
verification_method: "System Testing"
parents:
  - id: URD-DRIVER_DASHBOARD
children:
  - id: SWD-QT_DASHBOARD
  - id: HLTC-HMI_FRESHNESS
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
Qt HMI shall refresh speed, battery, status with <1s latency.
---
