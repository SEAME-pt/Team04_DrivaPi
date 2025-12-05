---
active: true
derived: false
level: 1.4.1
links: []
normative: false
ref: ''
reviewed: b292e5b29af8fa7ca0085e9c762e81952572ea84dbf0ce61413895f7bb8c5066
---

**Guidance**

To satisfy this assertion, changes to DrivaPi (e.g., AI model updates, ThreadX configs) need to be identified and assessed for safety impacts, including regression risks.

For changes, consider how they might affect expectations, identify bug/CVE sources, and define tests. For tools, assess misbehavior leading to undetected issues.

Where high-severity/low-detectability impacts exist, add analyses, tests, or expectations.

**Evidence**

- List of changes in releases
- Record of change assessment:
    - Version and date
    - Assessors and date
    - Role in DrivaPi
    - Risk sources (e.g., CVEs)
    - Identified misbehaviors
- Impact records for tools/changes:
    - Severity/detectability
- Qualification reviews for high-impact changes

**Confidence scoring**

CS-A_04 is based on assessed changes/tools, frequency, and risk data sources.

**Checklist**

- Are there unassessed changes?
- Assessments for current versions?
- Risk/vulnerability sources identified?
- Additional tests linked?
- Tests run on new versions?
- High-impact items qualified?
- Included in release prep?
