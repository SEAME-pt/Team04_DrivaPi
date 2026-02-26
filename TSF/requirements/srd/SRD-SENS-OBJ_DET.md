---
id: SRD-SENS-OBJ_DET
header: "Primary Obstacle Recognition Pipeline"
text: |
  "Primary obstacle detection with ultrasonic fallback."
verification_method: "System Testing"
parents:
  - id: URD-OBSTACLE_AVOIDANCE
children:
  - id: SWD-OBSTACLE_PIPELINE
  - id: HLTC-OBSTACLE_CONF
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_obstacle.md
    description: "Supports SG-04 (Reliable Detection)"
active: true
derived: false
normative: true
level: 2.0
---
The vision system shall detect and classify obstacles as primary mechanism, triggering avoidance.
---
