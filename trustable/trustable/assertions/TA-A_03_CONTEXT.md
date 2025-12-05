---
active: true
derived: false
level: 1.3.1
links: []
normative: false
ref: ''
reviewed: 956fe1cca574ccfad3481cde10fcbee26d5c2e587331bc5e298c4ee401768d4e
---

**Guidance**

This assertion is satisfied to the extent that we have established bidirectional traceability for all DrivaPi requirements, from user needs (URD) through system design (SRD/SWD) to tests (LLTC), including tools and dependencies.

This ensures consistency in automotive safety chains, where breaks could miss AI or control system risks.

**Evidence**

- Traceability matrix listing all requirements including:
  - Links to parents/children (e.g., URD to SRD)
  - Date of tracing and reviewers
- Graph visualization (e.g., .dotstop.dot)

**Confidence scoring**

CS-A_03 is based on confidence that traceability covers all levels without gaps or orphans.

**Checklist**

- Could traceability be broken for some requirements (e.g., derived ones)?
- Could there be untraced dependencies (e.g., third-party tools)?
- Does tracing include all V-Model levels?
- Are traces bidirectional?
