---
id: SWD-QUEUE_MONITOR
header: "Queue Overrun Monitor"
text: |
  "Detects and handles message queue overflows."
ASIL: "QM"
verification_method: "Unit Testing, Integration Testing"
parents:
  - id: SRD-RTOS-QUEUE_MON
children:
  - id: LLTC-QUEUE_MON_COV
  - id: LLTC-QUEUE_MON_UNIT
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
active: true
derived: false
normative: true
level: 3.0
---
The software shall detect when message queues or buffers overflow.
---
