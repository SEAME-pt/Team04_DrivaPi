---
id: SWD-LANE_PIPELINE
header: "Lane Detection Pipeline"
text: |
  "Processes frames for lane keeping."
ASIL: "QM"
verification_method: "Unit Testing, System Testing"
parents:
  - id: SRD-SENS-LANE_DET
children:
  - id: LLTC-LANE_UNIT
  - id: LLTC-LANE_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
# references:
#   - type: "file"
#     path: firmware/Core/Src/vision_lane.c
#     description: "Production Implementation (placeholder)"
active: true
derived: false
normative: true
level: 3.0
---
The vision pipeline shall detect lane markings and output center offset for steering correction.
