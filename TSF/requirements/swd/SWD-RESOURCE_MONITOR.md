---
id: SWD-RESOURCE_MONITOR
header: "System Resource Monitoring"
text: |
  "Monitors CPU temperature, voltage and storage."
ASIL: "QM"
verification_method: "Unit Testing, Integration Testing"
parents:
  - id: SRD-SYS-RES_MONITOR
children:
  - id: LLTC-RES_MON_COV
  - id: LLTC-RES_MON_UNIT
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
active: true
derived: false
normative: true
level: 3.0
---
At defined intervals, the software shall read system temperature, supply voltage, and free storage.
---
