---
id: LLTC-QT_ALERT_COV
header: "Code Coverage for Qt Alerts"
text: |
  "Ensures alert display logic is covered."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-QT_ALERTS

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

# evidence:
#   type: coverage_threshold_validator
#   configuration:
#     min_line_rate: 90
#     references:
#     - type: file
#       path: artifacts/verification/coverage/qt_alerts.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for Qt alert handling logic.
---
