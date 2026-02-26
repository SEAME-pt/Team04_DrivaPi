---
id: SWD-QT_DASHBOARD
header: "Qt Dashboard Display Logic"
text: |
  "Manages real-time status rendering."
ASIL: "QM"
verification_method: "Unit Testing, System Testing"
parents:
  - id: SRD-HMI-DASHBOARD
children:
  - id: LLTC-QT_DASH_UNIT
  - id: LLTC-QT_DASH_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
# references:
#   - type: "file"
#     path: qt-app/src/dashboard.cpp
#     description: "Production Implementation (placeholder)"
active: true
derived: false
normative: true
level: 3.0
---
Qt dashboard shall refresh speed, battery, and status with <1s latency.
