---
id: HLTC-MUTEX_LOCKING
header: "Shared Data Integrity Test"
text: |
  "Verifies that shared data remains consistent under high-load concurrency."
verification_method: "Integration Test (Stress Test + Data Log Analysis)"

parents:
  - id: SRD-RTOS-MUTEX_DATA

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
Under high task load, shared data structures (speed buffer, steering state) shall not exhibit corruption or race conditions.
---
