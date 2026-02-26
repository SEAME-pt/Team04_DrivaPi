---
id: SRD-SENS-ENCODER_SPD
header: "Wheel Encoder Speed Calculation"
text: |
  "Provides accurate speed feedback for monitoring and control loops."
verification_method: "Integration Testing"
parents:
  - id: URD-SPEED_MEASUREMENT
children:
  - id: SWD-SPEED_CALC
  - id: HLTC-SPEED-ACCURACY
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
references:
  - type: "file"
    path: docs/standards/iso26262/hara_motor_speed.md
    description: "Supports SG-01 (Prevent False Zero Speed)"
active: true
derived: false
normative: true
level: 2.0
---
The wheel encoder interface shall convert raw encoder pulses into linear speed (0–4 m/s) using the known wheel circumference and pulses-per-rev (30 pulses/rev, 0.212 m perimeter), handling timer overflows and timeouts.
