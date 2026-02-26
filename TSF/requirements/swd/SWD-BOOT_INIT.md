---
id: SWD-BOOT_INIT
header: "Boot Initialization Logic"
text: |
  "Handles startup tests and calibration."
ASIL: "QM"
verification_method: "Unit Testing, System Testing"
parents:
  - id: SRD-SYS-BOOT_CALIB
children:
  - id: LLTC-BOOT_UNIT
  - id: LLTC-BOOT_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
# references:
#   - type: "file"
#     path: firmware/Core/Src/boot_init.c
#     description: "Production Implementation (placeholder)"
active: true
derived: false
normative: true
level: 3.0
---
Boot logic shall perform self-tests and servo neutral calibration on power-up.
