---
id: LLTC-997
header: Static Analysis Verification (Cppcheck)
text:  |
  "The software SHALL pass static analysis (Cppcheck) with zero ''error'' severity
  findings."

# TSF Type: A Premise

verification_method: Static Analysis
parents:
- id: SWD-998
reviewers:
- name: Gaspar
  email: joao.gaspar@seame.pt
reviewed: '2025-11-12 - Approved by Gaspar joao.gaspar@seame.pt'
references:
- type: file
  path: artifacts/verification/static-analysis/cppcheck-SWD-998.xml
  description: Static analysis report (0 errors)

score:
  Gaspar: 1.0
active: true
derived: false
normative: true
level: 4.0
score:
  Hugo Lopes: 0.95
---
Verifies SWD-998 implementation against static analysis rules.
