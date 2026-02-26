---
id: HLTC-VAL-HMI_LINK
header: "HMI Communication Link Reliability"
text: |
  "Validates that the HMI maintains a persistent and reliable control link."

verification_method: "System Validation (Connection Stress)"

parents:
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
The HMI connection shall be stable during a full operational session, and control commands sent from the HMI shall be executed without perceived loss.
