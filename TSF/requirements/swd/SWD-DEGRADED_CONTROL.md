---
id: SWD-DEGRADED_CONTROL
header: "Degraded Mode Control"
text: |
  "Implements reduced performance control during degraded communication."
ASIL: "A"
verification_method: "Unit Testing, Integration Testing"
parents:
  - id: SRD-SAFE-DEGRADED_OPS
children:
  - id: LLTC-DEGRADED_COV
  - id: LLTC-DEGRADED_UNIT
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
active: true
derived: false
normative: true
level: 3.0
---
The software shall implement a degraded control mode that limits the maximum speed or stops the vehicle when communication integrity cannot be guaranteed.
---
