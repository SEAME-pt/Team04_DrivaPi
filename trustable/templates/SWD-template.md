---
# TSF Identity
id: SWD-000 # Placeholder ID (e.g., SWD-1000)
active: true
derived: false
normative: true
level: 3.1 # Level 3.1 = Software Design / Detailed Requirement

# Document Collection Metadata
doc:
  name: 'Software Design (SWD)'
  ref: 'SWD'
  title: DrivaPi Software Design

# TRACEABILITY
# Links UP to the Parent System Requirement (SRD).
# This proves that this piece of software logic exists to fulfill a system function.
links:
  - SRD-000: placeholder # Replace with specific SRD ID (e.g., SRD-0100)

# ISO 26262 Metadata
asil: "ASIL D"           # Inherited from SRD
verification_method: "Unit Test & Static Analysis"
safety_mechanism: false  # Set 'true' if this software IS a safety mechanism (e.g., Watchdog)

# Review Status
reviewers:
  - name: "Software Lead"
reviewed: ''

---

### Software Design Statement
The **[Unit/Class Name]** shall implement [specific logic/algorithm] to [achieve result] when [condition met].

### Interface Definition
* **Input:** [e.g., `uint16_t pulse_count`]
* **Output:** [e.g., `float rpm_value`]
* **Function:** [e.g., `calculate_rpm(pulses, time)`]

### Error Handling & Constraints
* **Range Check:** Logic shall reject values > [X].
* **Failure Behavior:** If input is invalid, the function shall return [Error Code] and set [Safety Flag].

### Rationale
Implements **SRD-XXX** by defining the software logic required to process the signal within the specified latency.

### Acceptance Criteria
1.  [ ] Logic correctly calculates output for nominal inputs.
2.  [ ] Logic handles boundary values (Min/Max) correctly.
3.  [ ] Invalid inputs trigger the defined error handling path.
