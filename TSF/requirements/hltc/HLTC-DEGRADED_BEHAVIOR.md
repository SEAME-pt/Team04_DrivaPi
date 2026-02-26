---
id: HLTC-DEGRADED_BEHAVIOR
header: "Degraded Mode Speed Limit Test"
text: |
  "Verifies that the vehicle adheres to reduced speed limits when in degraded mode."
verification_method: "System Functional Test (Track + Telemetry)"

parents:
  - id: SRD-SAFE-DEGRADED_OPS

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
When the degraded mode flag is active (due to comms loss or latency), the vehicle speed shall not exceed the defined safe limit (e.g., 0.8 m/s).
---
