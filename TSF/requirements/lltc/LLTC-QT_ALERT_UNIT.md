---
id: LLTC-QT_ALERT_UNIT
header: "Unit Tests for Qt Alerts"
text: |
  "Verifies that alert signals trigger the correct UI elements."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-QT_ALERTS

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

# evidence:
#   type: junit_pass_rate_validator
#   configuration:
#     min_pass_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/tests/qt_alerts.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify that the Qt Alert controller emits the correct signal when a fault status is received.
---
