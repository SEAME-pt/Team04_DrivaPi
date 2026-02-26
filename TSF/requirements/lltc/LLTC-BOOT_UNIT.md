---
id: LLTC-BOOT_UNIT
header: "Unit Tests for Boot & Initialization"
text: |
  "Verifies correctness of startup logic, default safety states, and initialization sequencing."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-BOOT_INIT

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# references:
#   - type: "file"
#     path: "tests/unit/boot/test/test_boot_init.c"
#   - type: "file"
#     path: "tests/unit/boot/test/test_boot_init_with_mocks.c"

# evidence:
#   type: junit_pass_rate_validator
#   configuration:
#     min_pass_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/tests/boot.xml

active: true
derived: false
normative: true
level: 4.0
---
All unit tests for the boot/initialization module shall pass, validating startup flow, default states, and calibration triggers.
---
