---
id: SRD-SENS-US_DISTANCE
header: "Ultrasonic Distance Measurement (Fallback)"
text: |
  "Fallback mechanism when vision confidence is low."
verification_method: "Integration Testing"
parents:
  - id: URD-OBSTACLE_AVOIDANCE
children:
  - id: SWD-ULTRASONIC_DRIVER
  - id: HLTC-US_DISTANCE_TEST
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
The system shall measure front distance using ultrasonic sensor as fallback, triggering avoidance if <100cm.
---
