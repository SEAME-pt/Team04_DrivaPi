---
id: LLTC-QT_DASH_UNIT
header: "Unit Tests for Qt Dashboard"
text: |
  "Verifies that HMI widgets correctly reflect telemetry updates and expected UI refresh behavior."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-QT_DASHBOARD

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# references:
#   - type: "file"
#     path: "tests/unit/qt-dashboard/test/test_qt_dashboard_bindings.cpp"
#   - type: "file"
#     path: "tests/unit/qt-dashboard/test/test_qt_dashboard_refresh.cpp"

# evidence:
#   type: junit_pass_rate_validator
#   configuration:
#     min_pass_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/tests/qt_dashboard.xml

active: true
derived: false
normative: true
level: 4.0
---
All unit tests for the Qt dashboard shall pass, validating telemetry bindings, formatting, and refresh behavior.
---
