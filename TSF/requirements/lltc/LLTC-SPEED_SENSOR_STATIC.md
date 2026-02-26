---
id: LLTC-SPEED_SENSOR_STATIC
header: "Static Code Analysis (CodeQL)"
text: |
  "Enforces strict compliance via `codeql_sarif_validator`."

# TSF Type: Evidence
verification_method: "Static Analysis (GitHub CodeQL)"

parents:
  - id: SWD-SPEED_CALC

reviewers:
  - name: "Hugo Lopes"
    email: "hugo.lopes@seame.pt"

reviewed: '2026-01-09 - Approved by Hugo Lopes <hugo.lopes@seame.pt>'

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
Source code must pass CodeQL queries with zero high-severity errors
---
