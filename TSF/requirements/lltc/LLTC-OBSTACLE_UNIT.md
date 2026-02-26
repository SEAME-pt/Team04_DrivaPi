---
id: LLTC-OBSTACLE_UNIT
header: "Unit Tests for Obstacle Pipeline"
text: |
  "Verifies bounding box logic and classification confidence thresholds."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-OBSTACLE_PIPELINE

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

# evidence:
#   type: junit_pass_rate_validator
#   configuration:
#     min_pass_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/tests/obstacle.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify that the vision pipeline correctly filters objects and calculates distance correctly.
---
