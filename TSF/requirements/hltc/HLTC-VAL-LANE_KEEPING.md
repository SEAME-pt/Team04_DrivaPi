---
id: HLTC-VAL-LANE_KEEPING
header: "Autonomous Lane Keeping Validation"
text: |
  "Validates that the vehicle autonomously follows lane markings on a physical track."

verification_method: "System Validation (Track Test)"

parents:
  - id: URD-LANE_DETECTION

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
The vehicle shall complete a full lap of the test track in autonomous mode without crossing lane boundaries, utilizing the lane detection system.
