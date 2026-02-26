---
id: SRD-SYS-BOOT_CALIB
header: "Boot Sequence & Calibration"
text: |
  "Ensures system starts in known safe state."
verification_method: "System Testing"
parents:
  - id: URD-STARTUP_CALIBRATION
children:
  - id: SWD-BOOT_INIT
  - id: HLTC-BOOT_SELFTEST
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
references:
  - type: "file"
    path: docs/standards/iso26262/hara_startup.md
    description: "Supports SG-09 (Safe Startup)"
active: true
derived: false
normative: true
level: 2.0
---
On startup, system shall perform self-tests and servo neutral calibration.
