---
id: URD-DETERMINISTIC_SCHED
header: "Deterministic Scheduling & Concurrency"
text: |
  "Guarantees deterministic scheduling and safe concurrency."
verification_method: "System Testing"
children:
  - id: SRD-RTOS-MUTEX_DATA
  - id: SRD-RTOS-QUEUE_MON
  - id: HLTC-VAL-SYSTEM_STABILITY
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: '' # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)
references:
  - type: "file"
    path: docs/standards/iso26262/hara_rtos.md
    description: "Mitigates Hazard H-06 (Scheduling Overrun/Delay)"
active: true
derived: false
normative: true
level: 1.0
---
Access to shared data shall use deterministic synchronization (mutexes/queues) to prevent race conditions. The system shall detect and report queue overruns or lost messages and enter a safe or degraded mode if they occur.
---
