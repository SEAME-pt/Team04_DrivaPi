---
id: URD-SPEED_MEASUREMENT
header: "Vehicle Speed Measurement"
text: |
  "Operators need accurate speed for monitoring and control during autonomous operation."
verification_method: "System Testing"
children:
  - id: SRD-SENS-ENCODER_SPD
  - id: HLTC-SPEED-ACCURACY
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_motor_speed.md
    description: "Mitigates Hazard H-01 (False Zero Speed)"
active: true
derived: false
normative: true
level: 1.0
---
The system shall compute and report the current vehicle speed at least every 100 ms (≥10 Hz).
---
