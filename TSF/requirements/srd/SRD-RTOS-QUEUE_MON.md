---
id: SRD-RTOS-QUEUE_MON
header: "Queue Overrun Detection"
text: |
  "Detects and reports queue overrun events."
verification_method: "Integration Testing"
parents:
  - id: URD-DETERMINISTIC_SCHED
children:
  - id: SWD-QUEUE_MONITOR
  - id: HLTC-DEADLINE_MISS
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_rtos.md
    description: "Mitigates Hazard H-06 (Scheduling Overrun)"
active: true
derived: false
normative: true
level: 2.0
---
The system shall detect when message queues or buffers overflow and log the event.
---
