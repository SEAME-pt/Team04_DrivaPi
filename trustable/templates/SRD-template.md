---
# TSF Identity
id: SRD-000 # Placeholder ID (e.g., SRD-0100)
active: true
derived: false
normative: true
level: 3.0 # Level 3.0 = System Requirements / Architecture

# Document Collection Metadata
doc:
  name: 'System Requirement Document (SRD)'
  ref: 'SRD'
  title: DrivaPi System Requirement

# TRACEABILITY
# Links UP to the Parent User Requirement (URD).
# This proves that this technical design implements a specific Safety Goal.
links:
  - URD-000: placeholder # Replace with the specific URD ID (e.g., URD-001)

# ISO 26262 Metadata
# The ASIL is usually inherited from the URD, or decomposed here.
asil: "ASIL D"           # If decomposed, note it (e.g., "ASIL B(D)")
allocation: "STM32_LowLevel" # Critical: Is this RPi5, STM32, or Both?
verification_method: "System Integration Test (HIL)"

# Review Status
reviewers:
  - name: "System Architect"
reviewed: ''

---

### System Requirement Statement
The **[Component: e.g., STM32 Controller]** shall [technical action] via **[Interface: e.g., CAN Bus]** with a latency of no more than [X ms].

### Architecture Allocation
* **Component:** [e.g., STM32F4 Discovery Board]
* **Interface:** [e.g., GPIO Pin PA0, CAN ID 0x123]

### Rationale & Traceability
Implements **URD-XXX** by defining the hardware/software interface required to achieve the safety goal.

### Acceptance Criteria
1.  [ ] Interface sends/receives correct signal format.
2.  [ ] Timing constraint (X ms) is met under load.
3.  [ ] Fault injection on the interface triggers error handling.
