---
id: SWD-COMM_PROTOCOL
header: "Bidirectional Communication Protocol"
text: |
  "Implements reliable data exchange with timeout handling."
ASIL: "A"
verification_method: "Unit Testing, Integration Testing"
parents:
  - id: SRD-COMM-PROTOCOL
children:
  - id: LLTC-COMM_UNIT
  - id: LLTC-COMM_COV
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval
references:
  - type: "file"
    path: docs/standards/iso26262/asil_justification_SWD-COMM_PROTOCOL.md
    description: "ASIL A Justification"
active: true
derived: false
normative: true
level: 3.0
---
Communication module shall handle bidirectional packets.
