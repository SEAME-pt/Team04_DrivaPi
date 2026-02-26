---
id: HLTC-STALE_DATA
header: "Stale Data Detection & Reaction"
text: |
  "Explicit comm-integrity edge case proof: stale/timeout detection and controlled reaction."
verification_method: "Integration/System Test (Timeout + Logs)"

parents:
  - id: SRD-COMM-TIMEOUT_MGMT

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
If command/telemetry data becomes stale or times out, the system shall detect it and transition to safe/degraded behavior.
---
