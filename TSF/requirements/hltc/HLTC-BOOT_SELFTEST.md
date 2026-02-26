---
id: HLTC-BOOT_SELFTEST
header: "Startup Calibration & Self-Test (System Functional)"
text: |
  "Demonstrates safe boot behavior, self-test execution, and repeatable calibration on power cycles."
verification_method: "System Functional Test (Power Cycling + Logs/Video)"

parents:
  - id: URD-STARTUP_CALIBRATION

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
On power cycle, the system shall initialize safely, execute defined self-tests, and perform calibration (including servo neutral) as specified.
---
