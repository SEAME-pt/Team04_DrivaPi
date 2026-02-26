---
id: LLTC-MUTEX_COV
header: "Code Coverage for Mutex Logic"
text: |
  "Ensures synchronization primitives and mutex locking logic are fully covered."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-MUTEX_IMPLEMENTATION

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
#       path: artifacts/verification/coverage/mutex.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for the implementation of SWD-MUTEX_IMPLEMENTATION.
---
