---
id: SWD-OBSTACLE_PIPELINE
header: "Primary Obstacle Recognition Pipeline"
text: |
  "Primary vision-based obstacle detection."
ASIL: "A"
verification_method: "Unit Testing, System Testing"
parents:
  - id: SRD-SENS-OBJ_DET
children:
  - id: LLTC-OBSTACLE_UNIT
  - id: LLTC-OBSTACLE_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
# references:
#   - type: "file"
#     path: firmware/Core/Src/vision_obstacle.c
#     description: "Production Implementation (placeholder)"
active: true
derived: false
normative: true
level: 3.0
---
The vision pipeline shall classify obstacles and trigger avoidance signal.
