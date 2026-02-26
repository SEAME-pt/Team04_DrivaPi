---
id: HLTC-HMI_FRESHNESS
header: "HMI Freshness / Latency System Test"
text: |
  "Demonstrates dashboard freshness performance and supports SRD-HMI-DASHBOARD evidence needs."

# TSF Type: Evidence/Premise
verification_method: "System Test (Latency Measurement + Logs)"

parents:
  - id: SRD-HMI-DASHBOARD

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

# references:
#   - type: "file"
#     path: "artifacts/verification/system/HLTC-HMI_FRESHNESS/hmi_latency.csv"

active: true
derived: false
normative: true
level: 2.0
---
The dashboard shall display telemetry with <1s latency under nominal and stressed conditions.
