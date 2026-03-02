---
id: URD-HMI_COMMUNICATION
header: "Firmware ↔ HMI Communication"
text: |
  "Ensures reliable data exchange to prevent control loss."
verification_method: "Integration Testing"
children:
  - id: SRD-COMM-PROTOCOL
  - id: HLTC-INT-PS3_DECODE_VALIDATE
  - id: HLTC-COMM_NOMINAL
  - id: HLTC-VAL-HMI_LINK
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_comms.md
    description: "Mitigates Hazard H-08 (Comms Loss)"
active: true
derived: false
normative: true
level: 1.0
---
Reliable bidirectional communication between firmware (STM32) and Qt HMI (RPi5).
---
