---
id: SWD-QT_ALERTS
header: "Qt Critical Alert Logic"
text: |
  "Handles prominent warning display."
ASIL: "QM"
verification_method: "Unit Testing, System Testing"
parents:
  - id: SRD-HMI-ALERTS
children:
  - id: LLTC-QT_ALERT_UNIT
  - id: LLTC-QT_ALERT_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
# references:
#   - type: "file"
#     path: qt-app/src/alerts.cpp
#     description: "Production Implementation (placeholder)"
active: true
derived: false
normative: true
level: 3.0
---
Qt alerts shall display prominent warnings for collision, stall, comms loss.
