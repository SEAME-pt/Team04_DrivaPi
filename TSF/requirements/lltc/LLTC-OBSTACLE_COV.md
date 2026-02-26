---
id: LLTC-OBSTACLE_COV
header: "Code Coverage for Obstacle Pipeline"
text: |
  "Ensures vision detection logic is covered by tests."
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-OBSTACLE_PIPELINE

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
#       path: artifacts/verification/coverage/obstacle.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for the obstacle detection source code.
---
