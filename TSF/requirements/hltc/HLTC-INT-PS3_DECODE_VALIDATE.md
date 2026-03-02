---
id: HLTC-INT-PS3_DECODE_VALIDATE
header: "PS3 Controller Decode & Validation (Integration Test)"
text: |
  "Verifies that PS3 controller commands are correctly received, decoded, and validated by the Raspberry Pi, and that invalid/malformed signals are handled safely."
verification_method: "Integration Test (Input Decode + Safety Handling)"

parents:
  - id: URD-HMI_COMMUNICATION

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

references:
  - type: "file"
    path: "tests/integration/integration_tests_plan.md"
    note: "Phase A — PS3 Controller → Raspberry Pi input receive/decode/validate."
  - type: "file"
    path: "rust/controller/src/main.rs"
    note: "Phase A — controller decoding implementation."
  - type: "file"
    path: "tests/integration/joystick_integration.mp4"
    note: "Phase A — demonstration of correct decode and safe rejection of invalid input."

active: true
derived: false
normative: true
level: 2.0
---
All valid commands shall be decoded with correct speed/steering/mode values, and invalid/malformed commands shall be rejected without system crash.
---
