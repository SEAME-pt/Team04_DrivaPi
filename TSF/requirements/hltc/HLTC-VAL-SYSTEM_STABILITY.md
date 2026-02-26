---
id: HLTC-VAL-SYSTEM_STABILITY
header: "System Control Loop Stability"
text: |
  "Validates that the vehicle control remains smooth and jitter-free during sustained operation."

verification_method: "System Validation (Long-run Test)"

parents:
  - id: URD-DETERMINISTIC_SCHED

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
During a 10-minute continuous autonomous run, the vehicle motion shall remain smooth without observable stuttering or control lag indicative of scheduling misses.
