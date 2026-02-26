---
id: HLTC-PLAUSIBILITY_TEST
header: "Safety Monitor Plausibility Check"
text: |
  "Verifies that the central safety monitor correctly identifies implausible sensor states (e.g., sudden jumps) and triggers safe state."
verification_method: "System Functional Test (Fault Injection + Logs)"

parents:
  - id: SRD-SAFE-MONITOR

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
When sensor inputs show implausible values (e.g., velocity jump > max acceleration) or conflicting data, the system shall trigger the safe state within 100ms.
---
