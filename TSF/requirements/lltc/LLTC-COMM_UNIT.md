---
id: LLTC-COMM_UNIT
header: "Unit Tests for Comm Protocol"
text: |
  "Verifies packet serialization, deserialization, and CRC checks."
verification_method: "Automated Unit Testing"

parents:
  - id: SWD-COMM_PROTOCOL

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

# evidence:
#   type: junit_pass_rate_validator
#   configuration:
#     min_pass_rate: 100
#     references:
#     - type: file
#       path: artifacts/verification/tests/comm_protocol.xml

active: true
derived: false
normative: true
level: 4.0
---
Unit tests shall verify that valid packets are parsed correctly and invalid CRCs are rejected.
---
