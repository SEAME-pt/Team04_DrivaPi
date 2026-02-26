---
id: LLTC-QT_DASH_COV
header: "Code Coverage for Qt Dashboard"
text: |
  "Ensures the dashboard update logic is well covered by automated tests."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-QT_DASHBOARD

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# evidence:
#   type: coverage_threshold_validator
#   configuration:
#     min_line_rate: 90
#     references:
#     - type: file
#       path: artifacts/verification/coverage/qt_dashboard.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for Qt dashboard logic and bindings.
---
