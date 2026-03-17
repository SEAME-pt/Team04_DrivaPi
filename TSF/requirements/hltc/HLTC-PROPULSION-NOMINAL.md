---
id: HLTC-PROPULSION-NOMINAL
header: "Propulsion Control System Test"
text: |
  "Verifies that throttle commands translate to correct wheel rotation and direction."
verification_method: "System Test (Tachometer/Encoder + Logs)"

parents:
  - id: SRD-ACT-MOTOR_DRIVE
  - id: URD-PROPULSION_CONTROL

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: "tests/system/propulsion/propulsion_control_system_test.md"
    description: "System-level test record: throttle proportionality and direction control observation"
  - type: "file"
    path: "tests/integration/motors_integration.mp4"
    description: "Integration video evidence: I2C motor commands and actuation response"
  - type: "file"
    path: "tests/system/speed/speed_accuracy_system_test.md"
    description: "Cross-reference: confirms throttle -> physical forward motion at ~1.05 m/s"
  - type: "file"
    path: "docs/software/proportional-integral-derivative/motor_control.h"
    description: "Motor control implementation header"
  - type: "file"
    path: "docs/software/proportional-integral-derivative/motor_control.c"
    description: "Motor control implementation source"
  - type: "file"
    path: "docs/standards/iso26262/hara_motor_speed.md"
    description: "HARA motor speed hazard analysis"
score:
  MelanieReis: 1.0
active: true
derived: false
normative: true
level: 2.0
---
Throttle commands (0-100%) shall produce proportional wheel speeds, and direction commands shall correctly define motor rotation.
