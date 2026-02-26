---
id: SWD-ESTOP_EXEC
header: "Emergency Stop Handler"
text: |
  "Critical safety response execution."
ASIL: "A"
verification_method: "Unit Testing, System Testing"
parents:
  - id: SRD-SAFE-ESTOP_EXEC
children:
  - id: LLTC-ESTOP_UNIT
  - id: LLTC-ESTOP_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
# references:
#   - type: "file"
#     path: firmware/Core/Src/estop_handler.c
#     description: "Production Implementation (placeholder)"
active: true
derived: false
normative: true
level: 3.0
---
The emergency handler shall zero motor PWM and center servo within 100ms on hazard trigger.
