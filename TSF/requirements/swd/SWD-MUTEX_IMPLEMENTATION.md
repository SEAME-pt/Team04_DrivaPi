---
id: SWD-MUTEX_IMPLEMENTATION
header: "Safe Concurrency Implementation"
text: |
  "Ensures exclusive access to shared data using RTOS primitives."
ASIL: "A"
verification_method: "Unit Testing, Integration Testing"
parents:
  - id: SRD-RTOS-MUTEX_DATA
children:
  - id: LLTC-MUTEX_COV
  - id: LLTC-MUTEX_UNIT
reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''
active: true
derived: false
normative: true
level: 3.0
---
The software shall use deterministic synchronization primitives, such as mutexes or message queues, to protect shared speed buffers and other shared data structures.
---
