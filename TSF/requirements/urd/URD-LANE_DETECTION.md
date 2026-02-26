---
id: URD-LANE_DETECTION
header: "Lane Detection"
text: |
  "Enables autonomous lane keeping for safe navigation."
verification_method: "System Testing"
children:
  - id: SRD-SENS-LANE_DET
  - id: HLTC-VAL-LANE_KEEPING
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)
references:
  - type: "file"
    path: docs/standards/iso26262/hara_vision.md
    description: "Mitigates Hazard H-05 (Lane Drift)"
active: true
derived: false
normative: true
level: 1.0
---
The computer vision system shall detect lane markings for autonomous driving.
---
