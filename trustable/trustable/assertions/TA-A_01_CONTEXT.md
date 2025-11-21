---
active: true
derived: false
level: 1.1.1
links: []
normative: false
ref: ''
reviewed: 168b10c96f7554296a5a4ac2f9ec8ce7d628d234015d299cfe68cc0c029eef0b
---

**Guidance**

This assertion is satisfied to the extent that we have traced and captured all hazards for DrivaPi components (including AI perception, ThreadX control, and CAN interfaces) and ensured they map to safety requirements in the V-Model (URD to LLTC).

Clearly this requires comprehensive Hazard Analysis and Risk Assessment (HARA) for automotive systems, where gaps could lead to unmitigated risks like AI misdetection.

**Evidence**

- HARA manifest listing all hazards including:
  - Indication of ASIL level (e.g., QM to D)
  - Trace to requirements (e.g., URD-XXX)
  - Date of assessment and assessors
- Traceability matrix (e.g., .dotstop.dot or reqs/ links)

**Confidence scoring**

CS-A_01 is based on confidence that the hazard-requirement mappings are complete, with no orphans in traceability reports.

**Checklist**

- Could the hazard identification be incomplete for some components (e.g., third-party AI models)?
- Could there be other hazards missed from the HARA?
- Does the HARA include all system interfaces (e.g., RPi5-HAILO integration)?
- Are requirements bidirectional traceable?
