---
id: URD-OBSTACLE_AVOIDANCE
header: "Obstacle Detection"
text: |
  "Ensures vehicle safety by preventing collisions in autonomous mode."
verification_method: "Integration Testing"
children:
  - id: SRD-SENS-US_DISTANCE
  - id: SRD-SENS-OBJ_DET
  - id: HLTC-OBSTACLE_STOP
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_obstacle.md
    description: "Mitigates Hazard H-04 (Missed Obstacle)"
  - type: "file"
    path: docs/standards/iso26262/hara_vision.md
    description: "Mitigates Hazard H-05 (Incorrect Obstacle Detection)"
active: true
derived: false
normative: true
level: 1.0
---
The system shall detect obstacles within 1 m ahead of the vehicle and trigger collision-avoidance maneuvers within 100 ms of detection.
---
