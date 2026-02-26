---
id: SWD-ULTRASONIC_DRIVER
header: "Ultrasonic Distance Driver (Fallback)"
text: |
  "Implements fallback distance measurement for safety."
ASIL: "A"
verification_method: "Unit Testing, Integration Testing"
parents:
  - id: SRD-SENS-US_DISTANCE
children:
  - id: LLTC-ULTRASONIC_UNIT
  - id: LLTC-ULTRASONIC_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
# references:
#   - type: "file"
#     path: firmware/Core/Src/ultrasonic_driver.c
#     description: "Production Implementation (placeholder)"
active: true
derived: false
normative: true
level: 3.0
---
The ultrasonic driver shall measure front distance, filter noise, and signal <50cm threshold to control loop as vision fallback.
---
