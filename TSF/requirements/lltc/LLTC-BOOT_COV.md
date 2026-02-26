---
id: LLTC-BOOT_COV
header: "Code Coverage for Boot & Initialization"
text: |
  "Ensures the boot and calibration entry paths are sufficiently exercised by tests."

# TSF Type: Evidence/Premise (A Claim, but not a Request)
verification_method: "Code Coverage (LCOV)"

parents:
  - id: SWD-BOOT_INIT

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# evidence:
#   type: coverage_threshold_validator
#   configuration:
#     min_line_rate: 90
#     references:
#     - type: file
#       path: artifacts/verification/coverage/boot.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests must achieve >90% Line Coverage for the boot/initialization module.
---
