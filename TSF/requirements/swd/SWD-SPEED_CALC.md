---
id: SWD-SPEED_CALC
header: "Speed Sensor Calculation"
text: |
  "Implements accurate speed logic with safety checks."
ASIL: "A"
verification_method: "Unit Testing, Code Coverage, Static Analysis"
parents:
  - id: SRD-SENS-ENCODER_SPD
children:
  - id: LLTC-SPEED_SENSOR_UNIT
  - id: LLTC-SPEED_SENSOR_COV
  - id: LLTC-SPEED_SENSOR_STATIC
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
references:
  - type: "file"
    path: firmware/Core/Src/speed_sensor.c
    description: "Production Implementation"
  - type: "file"
    path: docs/standards/iso26262/asil_justification_SWD-SPEED_SENSOR.md
    description: "ASIL A Justification"
active: true
derived: false
normative: true
level: 3.0
---
The ‘speed_sensor’ component shall calculate speed in m/s as (pulse_count/30) * 0.212 / Δt. It shall handle 16-bit timer overflow by accounting for wraparound, detect zero speed by timing out appropriately, and avoid division by zero or other undefined math operations.
----
