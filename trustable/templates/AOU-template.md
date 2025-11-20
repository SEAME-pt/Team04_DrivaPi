---
# TSF Identity
id: AOU-000 # Placeholder ID (e.g., AOU-001)
active: true
derived: false
normative: true
level: 1.5 # Level 1.5 = Context & Assumptions (Sits "above" Requirements)

# Document Collection Metadata
doc:
  name: 'Assumption of Use (AOU)'
  ref: 'AOU'
  title: DrivaPi Operational & Environmental Assumption

# TRACEABILITY
# Assumptions are usually "Root Nodes" (they don't depend on software).
# However, they can link to Framework Tenets to explain "Why" we make this assumption.
links:
  - TT-EXPECTATIONS: placeholder # Optional: Links to the expectation tenet

# ISO 26262 / SOTIF Metadata
type: "Operational Design Domain (ODD)" # Options: ODD, Hardware Constraint, User Behavior
validation_owner: "Hardware Team"       # Who guarantees this is true?
safety_impact: "High"                   # What happens if this assumption fails?

# Review Status
reviewers:
  - name: "System Architect"
reviewed: ''

---

### Assumption Statement
The **[Component/Environment]** shall **[Behavior]** within **[Tolerance]**.
*(Example: The LIDAR sensor shall provide point clouds with a maximum latency of 50ms.)*

### Rationale & Context
The software path planner relies on fresh data. If latency exceeds 50ms, the Time-to-Collision (TTC) calculation will be invalid.

### Constraints / Limits
* **Valid Range:** [e.g., -10°C to +60°C]
* **Excluded Conditions:** [e.g., Heavy rain, Snow]

### Validation Strategy (How do we trust this?)
* [ ] Datasheet verification from Supplier.
* [ ] Hardware-in-the-loop (HIL) latency characterization test.
* [ ] Runtime monitor (software will raise an error if latency > 50ms).
