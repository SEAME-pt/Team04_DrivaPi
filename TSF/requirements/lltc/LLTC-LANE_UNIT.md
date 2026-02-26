---
id: LLTC-LANE_UNIT
header: "Unit Tests for Lane Pipeline"
text: |
  "Verifies lane output computation, edge cases, and safe bounded outputs."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-LANE_PIPELINE

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# references:
#   - type: "file"
#     path: "tests/unit/lane/test/test_lane_pipeline.cpp"
#   - type: "file"
#     path: "tests/unit/lane/test/test_lane_pipeline_with_mocks.cpp"

# evidence:
#   type: junit_pass_rate_validator
#   configuration:
#     min_pass_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/tests/lane.xml

active: true
derived: false
normative: true
level: 4.0
---
All unit tests for the lane pipeline shall pass, validating lane offset calculation and output boundaries.
---
