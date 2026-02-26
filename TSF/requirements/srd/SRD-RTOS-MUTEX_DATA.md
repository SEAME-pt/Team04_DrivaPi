---
id: SRD-RTOS-MUTEX_DATA
header: "Exclusive Access to Shared Data"
text: |
  "Ensures deterministic access to shared data."
verification_method: "Integration Testing"
parents:
  - id: URD-DETERMINISTIC_SCHED
children:
  - id: SWD-MUTEX_IMPLEMENTATION
  - id: HLTC-MUTEX_LOCKING
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
references:
  - type: "file"
    path: docs/standards/iso26262/hara_rtos.md
    description: "Mitigates Hazard H-06 (Race Conditions)"
active: true
derived: false
normative: true
level: 2.0
---
All shared data structures (e.g., speed buffers) shall be protected by deterministic synchronization primitives (e.g., mutexes or message queues).
The RTOS configuration shall prevent unbounded priority inversion for safety-critical tasks.
---
