---
id: LLTC-DC_MOTOR_STATIC
header: "Static Analysis for DC Motor"
text: |
  "Ensures that the DC Motor source code is free from high-severity issues as identified by CodeQL static analysis."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Static Analysis (CodeQL)"

parents:
  - id: SWD-DC_MOTOR_DRIVER

reviewers:
  - name: "Miguel Cardoso"
    email: "miguel.cardoso@seame.pt"
reviewed: '2026-01-14 - Approved by Miguel Cardoso <miguel.cardoso@seame.pt>'

evidence:
  type: codeql_sarif_validator
  configuration:
    allowed_errors: 0
    references:
    - type: file
      path: artifacts/verification/static_analysis/codeql.sarif

active: true
derived: false
normative: true
level: 4.0
---
DC Motor source code shall pass CodeQL with zero high-severity findings.
---
