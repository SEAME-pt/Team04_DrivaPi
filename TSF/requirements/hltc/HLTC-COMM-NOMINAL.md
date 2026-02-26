---
id: HLTC-COMM_NOMINAL
header: "Bidirectional Communication Nominal Test"
text: |
  "Verifies reliable packet exchange under normal load conditions."
verification_method: "Integration Test (Packet Loss Analysis)"

parents:
  - id: SRD-COMM-PROTOCOL
  - id: URD-HMI_COMMUNICATION

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
Bidirectional communication between Firmware and HMI shall maintain <1% packet loss at nominal 10Hz data rates.
