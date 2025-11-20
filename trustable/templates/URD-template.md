---
# TSF Identity
id: URD-000 # Placeholder ID
active: true
derived: false
normative: true
level: 2.0 # Level 2 = User Requirements / Safety Goals

# Document Collection Metadata
doc:
  name: 'User Requirement Document (URD)'
  ref: 'URD'
  title: DrivaPi User Requirement Document

# TRACEABILITY (The "Trust" Chain)
# We link UP to the Framework Assertions.
# This proves we are following the framework rules.
links:
  # Primary Parent: TA-A_01 "Hazards traced to requirements"
  # (SHA taken from your printout of trustable/trustable/assertions/TA-A_01.md)
  - TA-A_01: 28e8fe638ae342fcc88f9f9525f913afc0a0ffb6a330a5c3a1ef8eb3941aa527

  # Secondary Parent: TA-A_03 "Requirements are fully traceable"
  # (SHA taken from your printout of trustable/trustable/assertions/TA-A_03.md)
  - TA-A_03: a2f5cfbef5cdd8079e8b30588f9ff4de1af1235c95bf69b877220bb5648b5b6f

# ISO 26262 Metadata (Mandatory for TA-A_01 compliance)
asil: "ASIL D"           # A, B, C, D, or QM
hara_ref: "HARA-XXX"     # The Hazard this mitigates (Required by TA-A_01)
verification_method: "Vehicle Level Validation"

# Review Status
reviewers:
  - name: "Safety Manager"
reviewed: '' # Filled by CI

---

### Safety Goal Statement
The vehicle shall [perform action] to prevent [hazard] within [time/tolerance].

### Operational Design Domain (ODD)
* **Context:** [e.g., Highway, Daylight]
* **Limits:** [e.g., Max speed 50km/h]

### Rationale
Derived from Hazard **HARA-XXX**. This requirement satisfies Framework Assertion **TA-A_01** by providing a concrete safety requirement for an identified hazard.
