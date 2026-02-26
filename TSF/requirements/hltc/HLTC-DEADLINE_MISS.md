---
id: HLTC-DEADLINE_MISS
header: "Deadline Miss / Queue Overrun Detection"
text: |
  "Explicit determinism proof: deadline misses/overruns are handled deterministically and safely."
verification_method: "Stress/Injection Test (Overrun + Logs)"

parents:
  - id: SRD-RTOS-QUEUE_MON

reviewers:
  - name: "Melanie Reis"
    email: "melanie.reis@seame.pt"
reviewed: ''

active: true
derived: false
normative: true
level: 2.0
---
If task deadlines are missed or queues overrun persistently, the system shall detect, log, and enter the specified safe/degraded behavior.
