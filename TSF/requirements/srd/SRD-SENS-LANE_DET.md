---
id: SRD-SENS-LANE_DET
header: "Lane Marking Detection Pipeline"
text: |
  "Primary lane guidance for autonomous navigation."
verification_method: "System Testing"
parents:
  - id: URD-LANE_DETECTION
children:
  - id: SWD-LANE_PIPELINE
  - id: HLTC-LANE_TRACK
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_vision.md
    description: "Supports SG-05 (Accurate Lane Detection)"
active: true
derived: false
normative: true
level: 2.0
---
The vision system shall process camera frames to detect lane center for autonomous keeping.
---
