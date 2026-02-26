---
id: URD-STARTUP_CALIBRATION
header: "System Startup & Calibration"
text: |
  "Ensures safe and reliable system initialization."
verification_method: "System Testing"
children:
  - id: SRD-SYS-BOOT_CALIB
  - id: HLTC-BOOT_SELFTEST
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_startup.md
    description: "Mitigates Hazard H-09 (Calibration Error)"
active: true
derived: false
normative: true
level: 1.0
---
On power-up, the system shall calibrate the steering servo and perform self-tests on all critical subsystems.
---
