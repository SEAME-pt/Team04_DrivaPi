---
id: SRD-COMM-PROTOCOL
header: "Bidirectional Control Protocol"
text: |
  "Maintains reliable link for control integrity."
verification_method: "Integration Testing"
parents:
  - id: URD-HMI_COMMUNICATION
children:
  - id: SWD-COMM_PROTOCOL
  - id: HLTC-COMM-NOMINAL
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
references:
  - type: "file"
    path: docs/standards/iso26262/hara_comms.md
    description: "Supports SG-08 (Reliable Communications)"
active: true
derived: false
normative: true
level: 2.0
---
System shall exchange CAN messages between STM32 firmware and RPi5 HMI via CAN Bus communication.
