# ASIL Determination & HARA Documentation Guide - DrivaPi

**Date:** October 30, 2025 | **Updated:** November 3, 2025

-----

## Table of Contents

1.  Executive Summary
2.  Understanding ASIL
3.  ASIL Calculation Methodology
4.  HARA Process
5.  Templates
6.  Standard Locations
7.  Linking to TSF Requirements
8.  Best Practices
9.  Citations
10. Next Steps

-----

## Executive Summary

This guide provides the team with:

1.  Understanding of ASIL calculation methodology (Severity × Exposure × Controllability)
2.  Templates for HARA and ASIL justification documentation
3.  Standard location and linking process for compliance evidence in TSF
4.  **DrivaPi-specific approach:** ASIL justification linked in SWD requirements only, score propagates from URD

**Research Scope:** Review of ISO 26262:2018 Parts 2, 3, 6, and 9, with practical examples from automotive industry sources. All information sourced from ISO 26262 standard documentation and verified automotive industry sources.

-----

## 1\. Understanding ASIL

### What is ASIL?

**ASIL (Automotive Safety Integrity Level)** is a risk classification system defined by ISO 26262[59]. It determines the safety requirements necessary for electrical/electronic systems in vehicles[53].

**ASIL Levels** (from ISO 26262)[53][59]:

  * **QM (Quality Management):** No automotive hazard, no special safety requirements
  * **ASIL A:** Lowest risk level
  * **ASIL B:** Medium-low risk
  * **ASIL C:** Medium-high risk
  * **ASIL D:** Highest risk level (most stringent requirements)

### DrivaPi ASIL Context

DrivaPi is a prototype vehicle control system for testing and education. ASIL assignments depend on deployment context:

| Feature | ASIL | Rationale |
| :--- | :--- | :--- |
| Display widgets (speed, temperature) | QM | Non-safety-critical |
| Sensor monitoring (temperature, speed) | B | Typical for prototype sensors |
| Motor control loops | B | Control with operator present |
| Emergency stop system | C | Safety-critical function |

**Note:** Actual DrivaPi assessments must account for deployment context and intended use.

-----

## 2\. ASIL Calculation Methodology

ASIL is determined through **HARA (Hazard Analysis and Risk Assessment)** using three factors as defined in ISO 26262 Part 3[51][63][76].

### Formula:

```
ASIL = f(Severity, Exposure, Controllability)
```

### 2.1 Severity (S)

**Definition:** Potential harm to people if the hazard occurs[56][76]

**Classifications (from ISO 26262-3:2018, Annex B.2)**[56][76]:

| Class | Description | Injury Level |
| :--- | :--- | :--- |
| **S0** | No injuries | Minor property damage only |
| **S1** | Light to moderate injuries | Bruises, sprains |
| **S2** | Severe to life-threatening injuries (survival probable) | Broken bones, concussions |
| **S3** | Life-threatening (survival uncertain) to fatal injuries | Critical trauma, death |

-----

### 2.2 Exposure (E)

**Definition:** Frequency of conditions in which the hazard could occur[56][76]

**Classifications (from ISO 26262-3:2018, Annex B.3)**[56][76]:

| Class | Description | Operating Time (Qualitative) | Example |
| :--- | :--- | :--- | :--- |
| **E0** | Incredibly unlikely | \< 0.001% | Once per 1000+ years |
| **E1** | Very low probability | \< 1% | Less than once per year |
| **E2** | Low probability | 1-10% | A few times in lifetime |
| **E3** | Medium probability | \~10% | Approximately monthly |
| **E4** | High probability | \> 10% | During almost every operation |

**Note:** Percentages are approximate and qualitative. Assessments should be based on operational data and realistic use cases, per ISO 26262-3:2018 Annex B.3.

-----

### 2.3 Controllability (C)

**Definition:** Ability of driver/operator to control the situation and prevent harm[56][76]

**Classifications (from ISO 26262-3:2018, Annex B.4)**[56][76]:

| Class | Description |
| :--- | :--- |
| **C0** | Controllable in general - Controllable by nearly all operators. (For C0, ASIL = QM per ISO 26262-3:2018) |
| **C1** | Simply controllable - 99%+ of operators can avoid harm with sufficient warning and easy recovery |
| **C2** | Normally controllable - 90%+ of operators can avoid harm with reasonable warning and actions |
| **C3** | Difficult to control - Less than 90% of operators can avoid harm due to limited reaction time |

-----

### 2.4 ASIL Determination Table

**Source:** ISO 26262-3:2018, Clause 6.4.3.10, Table 4[71]

**Note:** For C0, ASIL is always QM (not in this table). For S3 E1 C3 = A, see ISO 26262-3:2018 Clause 6.4.3.11.

| Severity | Exposure | **C1** | **C2** | **C3** |
| :--- | :--- | :--- | :--- | :--- |
| **S1** | E1 | QM | QM | QM |
| | E2 | QM | QM | QM |
| | E3 | QM | QM | A |
| | E4 | QM | A | B |
| **S2** | E1 | QM | QM | QM |
| | E2 | QM | QM | A |
| | E3 | QM | A | B |
| | E4 | A | B | C |
| **S3** | E1 | QM | QM | A |
| | E2 | QM | A | B |
| | E3 | A | B | C |
| | E4 | B | C | D |

**Example:** S3 / E3 / C3 = **ASIL C** (from table above)

-----

## 3\. HARA Process

According to ISO 26262 Part 3[51][63], HARA follows these key phases:

1.  **Phase 1: Setup & Context**

      * **Item Definition:** Define the system, boundaries, and interfaces[63][74].
      * **Identify Operational Situations:** Define relevant scenarios (e.g., city driving, highway, parking)[63][74].

2.  **Phase 2: Analysis**

      * **Hazard Identification:** Identify potential hazards using methods like HAZOP or STPA[63].
      * **Define Hazardous Events:** Combine a hazard with an operational situation (e.g., `Hazard: Loss of speed control` + `Situation: Extended motor test`)[63].
      * **Assess S, E, & C:** Classify each hazardous event using the tables from Section 2[56][76].

3.  **Phase 3: Results**

      * **Determine ASIL:** Use the S, E, and C ratings with the ASIL Determination Table (Section 2.4)[71].
      * **Derive Safety Goals:** Create top-level safety requirements based on the identified hazards and ASIL[63].

-----

## 4\. Templates

### 4.1 HARA Template

**Based on:** ISO 26262-3:2018[63][72]
**File Location:** `docs/standards/iso26262/hara-<feature>.md`

```markdown
# HARA: <Feature Name>

**Date:** YYYY-MM-DD | **Authors/Reviewers:** <Names> | **ASIL Target:** <QM/A/B/C/D>

## 1. Item Definition & Assumptions
- **Description/Boundaries/Interfaces:** Motor speed monitoring system for DrivaPi lab testing.
- **Assumptions:** Trained operators only; controlled lab environment.

## 2. Hazards & Operational Situations
| ID | Hazard Description | Operational Situation | Exposure (E) / Justification |
|:---|:---|:---|:---|
| H-01 | Sensor fails silently | Extended motor test | E2 (~2-5% of tests; historical data) |

## 3. Risk Assessment & ASIL
- **Severity (S):** S1 - Motor overheats, minor burn risk if touched
- **Controllability (C):** C1 - Operator observes smoke/noise, presses emergency stop
- **ASIL Calculation:** S1 + E2 + C1 = **ASIL A** (from ISO 26262-3:2018 Table 4)

## 4. Safety Goals
| Goal ID | ASIL | Description | Safe State |
|:---|:---|:---|:---|
| SG-01 | A | Motor speed sensor shall function reliably | Operator can monitor and stop motor |

## 5. Dependencies & Review Notes
- **Dependencies:** Emergency stop button, GPIO hardware driver
- **Review:** Team approval 2025-11-03 (Git commit: abc123def)

**References:** ISO 26262-3:2018.
```

-----

### 4.2 ASIL Justification Template

**Based on:** ISO 26262 Part 9[53][61]
**File Location:** `docs/standards/iso26262/asil-justification-<REQ-ID>.md`

```markdown
# ASIL Justification: SWD-010

**Date:** YYYY-MM-DD | **Author/Reviewer:** Carol Dev | **ASIL:** A

## 1. Requirement Summary
- **ID/Description:** SWD-010 - Motor speed sensor driver shall read GPIO pulses and convert to RPM.
- **Related HARA/Safety Goal:** hara-motor-speed.md; SG-01 (ASIL A)

## 2. ASIL Assignment & Decomposition
- **Assigned ASIL:** A - Derived from HARA (S1 + E2 + C1 = ASIL A)
- **Justification:** This requirement implements motor speed monitoring addressing hazard H-01.

## 3. Risk Assessment Summary
| Factor | Classification | Justification/Evidence |
|:---|:---|:---|
| Severity (S) | S1 | Motor overheats - minor burn risk |
| Exposure (E) | E2 | Extended tests ~2-5% of operation |
| Controllability (C) | C1 | Operator observes and stops immediately |

## 4. Verification Requirements (ASIL A)
- **Unit/Integration Testing:** 5 unit tests (Target: ≥80% coverage)
- **Static Analysis:** cppcheck: 0 errors
- **Code Review:** 1 independent reviewer (Carol Dev)

## 5. Review Notes & Dependencies
- **Dependencies:** GPIO driver, emergency stop system
- **Review:** Carol Dev approved 2025-11-03 (PR #142)

**References:** ISO 26262-9:2018
```

-----

## 5\. Standard Locations

### Directory Structure

```
docs/
└── standards/
    └── iso26262/
        ├── README.md                          # Index of HARA/ASIL docs
        ├── hara-motor-speed.md                # HARA for motor speed
        ├── hara-temperature-monitoring.md     # HARA for temperature
        ├── hara-emergency-stop.md             # HARA for emergency stop
        ├── asil-justification-swd-010.md      # ASIL A for motor speed driver
        ├── asil-justification-swd-011.md      # ASIL B for emergency stop
        └── asil-decomposition-analysis.md     # Decomposition (if needed)
```

-----

## 6\. Linking to TSF Requirements

**Important:** ASIL field and justification ONLY appear in SWD level requirements. SRD, URD, LLTC do NOT have ASIL.

**Why?** ASIL applies to implementation safety (SWD), not user needs (URD) or system design (SRD).

### Linking Method: Use `references:` in SWD

```yaml
---
id: SWD-010
header: "Motor speed sensor driver implementation"
text: |
  "Implement GPIO-based motor speed sensor driver that reads pulse count
  over 1-second windows, converts to RPM with ±1% accuracy, validates
  range (0-10000 RPM), and detects/reports errors."

ASIL: "A"  # ← ASIL field ONLY in SWD

# Links to all supporting artifacts
references:
  - type: "file"
    path: src/sensors/motor_speed.cpp
    description: "Implementation (90 LOC)"

  - type: "file"
    path: tests/unit/test_motor_speed.cpp
    description: "Unit tests (5 test cases)"

  - type: "file"
    path: artifacts/verification/tests/LLTC-010-junit.xml
    description: "Test results (5/5 pass)"

  - type: "file"
    path: artifacts/verification/static-analysis/cppcheck-SWD-010.xml
    description: "Static analysis (0 errors)"

  - type: "file"
    path: artifacts/verification/coverage/motor-coverage.txt
    description: "Code coverage (87%)"

  - type: "file"
    path: docs/standards/iso26262/hara-motor-speed.md
    description: "HARA analysis for motor speed system"

  - type: "file"
    path: docs/standards/iso26262/asil-justification-swd-010.md
    description: "ASIL A justification with SME assessment"

parents:
  - id: SRD-010

children:
  - id: LLTC-010

reviewers:
  - name: "Carol Dev"
    email: "carol@example.com"

reviewed: "2025-11-03 - Approved by Carol Dev"

active: true
derived: false
normative: true
level: 3.0
---
```

-----

## 7\. Best Practices

### 7.1 ASIL Assignment

1.  **Start with HARA** - Always derive ASIL from systematic hazard analysis[51][63].
2.  **Document assumptions** - Clearly state operational scenarios and deployment context[74].
3.  **Be conservative** - When in doubt, choose higher severity/exposure for safety-critical functions[59].
4.  **Use data-driven justification** - Base E and C assessments on operational data or human factors studies[76].
5.  **Reassess if context changes** - If operational context changes, re-perform HARA.
6.  **Independent review** - ISO 26262 requires independent review for ASIL C/D[53][59].

### 7.2 Documentation

1.  **Link early** - Create HARA during concept phase[63].
2.  **Version control** - Keep HARA/ASIL docs in Git.
3.  **Cross-reference** - Link requirements ↔ HARA ↔ ASIL justifications.
4.  **Timestamp reviews** - Record review dates and signatures.
5.  **Change history** - Maintain version history for audit trail.

### 7.3 Verification (Tailored to ASIL)

**Coverage targets per ISO 26262-6:2018, Tables 7-12**[59]:

| ASIL | Code Coverage | Testing | Static Analysis | Review |
| :--- | :--- | :--- | :--- | :--- |
| A | ≥60% | Unit tests | Basic | 1 SME |
| B | ≥80% | Unit + Integration | 0 critical errors | 2+ SMEs |
| C | ≥90% | System tests | Comprehensive | 2+ independent |
| D | ≥95% | Fault injection | All rules | 2+ + formal |

**Note:** Targets are recommendations per ISO 26262-6:2018; tailor per project needs.

-----

## 8\. Citations

[51] Innodare Platform. "HARA (Hazard Analysis and Risk Assessment)."
Retrieved from [https://www.innodareplatform.com/](https://www.innodareplatform.com/)

[53] Spyro-Soft. (2024). "ISO 26262: The Complete Guide."
Retrieved from [https://spyro-soft.com/blog/automotive/iso-26262](https://spyro-soft.com/blog/automotive/iso-26262)

[56] Wikipedia. "ISO 26262."
Retrieved from [https://en.wikipedia.org/wiki/ISO\_26262](https://en.wikipedia.org/wiki/ISO_26262)

[59] LHPES. (2020). "Understanding an ASIL in the Functional Safety Standard ISO 26262."
Retrieved from [https://www.lhpes.com/](https://www.lhpes.com/)

[61] Infineon Community. (2025). "ASIL decomposition: ISO 26262."
Retrieved from [https://community.infineon.com/](https://community.infineon.com/)

[63] HermesSol. (2024). "Automotive safety standard ISO 26262: Hazard analysis and risk assessment (HARA)."
Retrieved from [https://www.hermessol.com/](https://www.hermessol.com/)

[71] Infocentre. "INTERNATIONAL STANDARD ISO 26262-3:2018."
Retrieved from [https://files.infocentre.io/](https://files.infocentre.io/)

[72] Visure Solutions. (2023). "Best ISO-26262 Compliance Tools, Checklists & Templates."
Retrieved from [https://visuresolutions.com/iso-26262-guide/](https://visuresolutions.com/iso-26262-guide/)

[74] LinkedIn. (2024). "Article 2: Applying ISO 26262 – A Practical Example of Functional Safety."
Retrieved from [https://www.linkedin.com/](https://www.linkedin.com/)

[76] Jama Software. (2024). "A Guide to Automotive Safety Integrity Levels (ASIL)."
Retrieved from [https://www.jamasoftware.com/](https://www.jamasoftware.com/)
