---
id: URD-DRIVER_DASHBOARD
header: "Driver Dashboard"
text: |
  "Provides real-time vehicle status to the operator."
verification_method: "System Testing"
children:
  - id: SRD-HMI-DASHBOARD
  - id: SRD-HMI-ALERTS
  - id: HLTC-VAL-DASHBOARD_CHECK
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)
references:
  - type: "file"
    path: docs/standards/iso26262/hara_hmi.md
    description: "Mitigates Hazard H-07 (Stale HMI Data)"
active: true
derived: false
normative: true
level: 1.0
---
Qt HMI shall display speed, battery level, system warnings and overall status with an update rate of at least 10 Hz (data refresh every 100 ms).
---
