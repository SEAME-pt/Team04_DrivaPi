# TSF Evidence Guide - DrivaPi

**Goal:** How to link artifacts as references for human review and understand scoring using the `trudag` tool.

**Principle:** Each claim (Statement) needs verifiable proof linked in `references:`. Confidence (Score) is derived from manual SME assessment **at LLTC level** (evidence level).

> **Commands:** See [reference.md](reference.md)
> **Workflows:** See [workflow.md](workflow.md)
> **Theory:** See [training.md](training.md)

---

## 📝 Spike Summary: Clarifying Linking Syntax

**Date:** October 28, 2025 | **Updated:** November 5, 2025

Based on analysis and `trudag` CLI documentation, the team clarifies syntax usage:

1. **`references:` Block:** Standard method for linking passive artifacts (files, URLs). Provides context for human SME review and traceability links in reports. **Used at ALL levels.**
2. **`evidence:` Block:** ~~Exclusively for configuring custom automated validators~~ **NOT USED in DrivaPi for now.**
   - **Reason 1:** Implementation complexity (requires custom validator development)
   - **Reason 2:** ASIL evaluation (A and above) always requires human expert review per ISO 26262
   - **Reason 3:** Cannot delegate safety judgment to automation
3. **`score:` Block:** Used for recording manual Subject Matter Expert (SME) scores. (evidence level, where tests/analysis/coverage live).
4. **Deprecated `artifact:` Block:** Not standard for `trudag` - use `references:` instead.

**Implementation:** This document details usage for `references:` and `score:` only. **ZERO `evidence:` blocks. Score ONLY in LLTC, propagate UPWARD.**

---

## 💯 How Scores Are Determined

The **"Trustable Score"** (0.0 to 1.0) for each requirement reflects the team's confidence in its truth.

### Score Assignment (Manual SME Assessment)

**Process:** Subject Matter Expert (SME) reviews evidence at LLTC level (tests, analysis, coverage). They assign a score in the LLTC `score:` block. This score **automatically propagates UPWARD** to all parents (SWD → SRD → URD).

**Why LLTC?** Because:
- Evidence lives at LLTC level (test results, analysis artifacts, coverage reports)
- SME scores the evidence directly (test pass/fail, coverage %, error count)
- Confidence flows upward: if tests pass (0.95), then implementation works (0.95), then design is sound (0.95), then user need is satisfied (0.95)

**Syntax - LLTC-998 (Tests):**

```yaml
---
id: LLTC-998
header: "Low-Level Test Cases for Motor Speed"
text: |
  "Test cases shall verify RPM calculation, error handling, and range validation."

verification_method: Unit Testing

parents:
  - id: SWD-998

reviewers:
  - name: "Test Engineer"
    email: "test@team.com"

reviewed: '2025-11-05 - Approved by Test Engineer'

# ✓ References at LLTC level
references:
  - type: "file"
    path: "tests/unit/test_motor_speed.cpp"
    description: "Test code (5 test cases)"
  - type: "file"
    path: "artifacts/verification/tests/LLTC-998-junit.xml"
    description: "Test results: 5/5 PASS ✅"

# ⭐ SCORE at LLTC level (evidence assessed)
score:
  TestEngineer: 0.95

# Rationale: 5/5 tests pass, comprehensive coverage,
# all boundary conditions tested, normal+error cases

active: true
derived: false
normative: true
level: 4.0
---

Verifies SWD-998 implementation through unit tests for motor speed functionality.
```

**Syntax - LLTC-996 (Coverage):**

```yaml
---
id: LLTC-996
header: "Code Coverage Verification"
text: |
  "Unit test coverage for motor speed driver meets project threshold."

verification_method: Coverage analysis

parents:
  - id: SWD-998

reviewers:
  - name: "Test Engineer"
    email: "test@team.com"

reviewed: '2025-11-05 - Approved by Test Engineer'

# ✓ References at LLTC level
references:
  - type: "file"
    path: "artifacts/verification/coverage/coverage-SWD-998.xml"
    description: "Coverage report: 87%"

# ⭐ SCORE at LLTC level
score:
  TestEngineer: 0.87

# Rationale: 87% coverage exceeds 80% ASIL A target,
# but 13% untested code remains (minor gap)

active: true
derived: false
normative: true
level: 4.0
---

Verifies that unit test coverage for the motor speed driver meets the defined project threshold of 80%.
```

**Syntax - LLTC-997 (Static Analysis):**

```yaml
---
id: LLTC-997
header: "Static Analysis Verification (Cppcheck)"
text: |
  "The software SHALL pass static analysis (Cppcheck) with zero 'error' severity findings."

verification_method: Static Analysis

parents:
  - id: SWD-998

reviewers:
  - name: "QA Engineer"
    email: "qa@team.com"

reviewed: '2025-11-05 - Approved by QA Engineer'

# ✓ References at LLTC level
references:
  - type: "file"
    path: "artifacts/verification/static-analysis/cppcheck-SWD-998.xml"
    description: "Static analysis report: 0 errors ✅"

# ⭐ SCORE at LLTC level
score:
  QAEngineer: 1.0

# Rationale: Perfect result - zero errors, zero warnings

active: true
derived: false
normative: true
level: 4.0
---

Verifies SWD-998 implementation against static analysis rules.
```

**Syntax - SWD-998 (Implementation):**

```yaml
---
id: SWD-998
header: "Motor speed sensor driver implementation"
text: |
  "Implement GPIO-based motor speed sensor driver that reads pulse count
  over 1-second windows, converts to RPM with ±1% accuracy, validates
  range (0-10000 RPM), and detects/reports errors."

ASIL: "A"  # ← ASIL ONLY at SWD

# ✓ References at SWD level (NO score here)
references:
  - type: "file"
    path: "src/sensors/motor_speed.cpp"
    description: "Implementation (90 LOC)"
  - type: "file"
    path: "src/sensors/motor_speed.h"
    description: "Header declarations"
  - type: "file"
    path: "tests/unit/test_motor_speed.cpp"
    description: "Unit tests"
  - type: "file"
    path: "artifacts/verification/tests/LLTC-998-junit.xml"
    description: "Test results (5/5 pass)"
  - type: "file"
    path: "artifacts/verification/static-analysis/cppcheck-SWD-998.xml"
    description: "Static analysis (0 errors)"
  - type: "file"
    path: "artifacts/verification/coverage/coverage-SWD-998.xml"
    description: "Code coverage (87%)"
  - type: "file"
    path: "docs/design/architecture/motor_system_architecture.md"
    description: "System architecture"
  - type: "file"
    path: "docs/design/interfaces/gpio_sensor_interface.md"
    description: "GPIO interface spec"
  - type: "file"
    path: "docs/standards/iso26262/hara-motor-speed.md"
    description: "HARA: ASIL A determination"
  - type: "file"
    path: "docs/standards/iso26262/asil-justification-SWD-998.md"
    description: "ASIL A justification"

# ✓ NO score: block at SWD level
# Score will be inherited from children (LLTC)

parents:
  - id: SRD-998

children:
  - id: LLTC-998  # Tests → Score 0.95
  - id: LLTC-996  # Coverage → Score 0.87
  - id: LLTC-997  # Analysis → Score 1.0

reviewers:
  - name: "Carol Dev"
    email: "carol@example.com"

reviewed: "2025-11-05 - Approved by Carol Dev"

active: true
derived: false
normative: true
level: 3.0
---

Motor speed sensor driver implementation with GPIO pulse reading, RPM conversion, range validation, and error handling.
```

**Syntax - SRD-998 (System Design):**

```yaml
---
id: SRD-998
header: "Motor speed sensor GPIO interface"
text: |
  "System shall interface with a tachometer-style speed sensor via GPIO
  Pin 17 to read motor RPM with a sampling rate of at least 1 Hz."

# ✓ References at SRD level (NO score here)
references:
  - type: "file"
    path: "docs/design/motor_system_architecture.md"
    description: "System architecture"
  - type: "file"
    path: "docs/design/gpio_sensor_interface.md"
    description: "GPIO interface specification"
  - type: "file"
    path: "docs/hardware/sensor_selection.md"
    description: "Sensor selection analysis"

# ✓ NO score: block at SRD level
# Score will be inherited from child (SWD-998)

parents:
  - id: URD-998

children:
  - id: SWD-998

reviewers:
  - name: "System Architect"
    email: "architect@example.com"

reviewed: "2025-11-05 - Approved by System Architect"

active: true
derived: false
normative: true
level: 2.0
---

The motor speed sensing subsystem shall provide real-time RPM measurements using a GPIO-connected tachometer sensor.
```

**Syntax - URD-998 (User Requirement):**

```yaml
---
id: URD-998
header: "Motor speed monitoring system"
text: |
  "The DrivaPi system shall provide motor speed monitoring and display
  to enable operators to monitor motor performance during test operations."

# ✓ References at URD level (NO score here)
references:
  - type: "file"
    path: "docs/requirements/user_needs_analysis.md"
    description: "User requirements analysis"
  - type: "file"
    path: "docs/standards/iso26262/hara-motor-speed.md"
    description: "HARA analysis"

# ✓ NO score: block at URD level
# Score will be inherited from child (SRD-998)

children:
  - id: SRD-998

reviewers:
  - name: "Product Owner"
    email: "po@example.com"

reviewed: "2025-11-05 - Approved by PO"

active: true
derived: false
normative: true
level: 1.0
---

Operators need to monitor motor speed during test operations to ensure tests run within acceptable performance ranges.
```

### Score Propagation (How trudag Calculates Everything)

```
LLTC-998: score: { TestEngineer: 0.95 }
LLTC-996: score: { TestEngineer: 0.87 }
LLTC-997: score: { QAEngineer: 1.0 }
   ↓      Average: (0.95 + 0.87 + 1.0) / 3 = 0.94
    (trudag automatically propagates DOWNWARD)
SWD-998: (NO score field) → inherits 0.94 from children average
   ↓
SRD-998: (NO score field) → inherits 0.94 from SWD-998
   ↓
URD-998: (NO score field) → inherits 0.94 from SRD-998

Result: Entire chain has 0.94 confidence!
```

**Why?** Evidence lives at LLTC level. One SME scores the evidence. That confidence reflects upward showing what we've proven works.

### Interpretation (Probability)

The LLTC score represents confidence that the evidence proves the requirement works:
- **1.0** = Perfect evidence (0 errors, 100% coverage, all tests pass)
- **0.95** = Excellent evidence (minor gaps acceptable)
- **0.87** = Good evidence (meets minimum targets)
- **0.75-0.9** = Adequate evidence, some concerns
- **0.5-0.75** = Weak evidence, significant gaps
- **<0.5** = Poor evidence, cannot trust
- **0.0** = No evidence, requirement unproven

---

## 🎯 WHERE and WHY We Justify ASIL

### Location: SWD Level

ASIL field appears in SWD:

```yaml
---
id: SWD-998
ASIL: "A"  # ← ASIL field ONLY at SWD level
---
```

### Why SWD Level?

ASIL is about **implementation safety**, not user need or system design:

| Level | What | ASIL? | Why? |
|-------|------|-------|------|
| **URD** | "Need motor speed" | ❌ NO | User need ≠ implementation safety |
| **SRD** | "Interface via GPIO" | ❌ NO | Design ≠ implementation safety |
| **SWD** | "Driver validates range, detects errors" | ✓ YES | Implementation = safety concern |
| **LLTC** | "5 unit tests verify driver" | ❌ NO | Tests prove SWD, inherit ASIL from parent |

### What Gets Justified

**File:** `docs/standards/iso26262/asil-justification-swd-998.md` (separate document)

**Contents:**
1. **ASIL Level** - What is it? (A/B/C/D)
2. **From HARA** - How was ASIL calculated? (S + E + C = ASIL)
3. **Evidence** - What proves this requirement meets ASIL?
   - Tests: 5/5 pass, 87% coverage
   - Code review: Approved by Carol Dev, Bob Smith
   - Static analysis: 0 errors from cppcheck
4. **SME Assessment** - Who reviewed? What's their confidence?
   - Carol Dev: Code quality excellent
   - Bob Smith: Agrees with Carol
5. **Risk Control** - How does this control the hazard?

---

## 📋 SME Scoring Guidance

When assigning a score to LLTC (0.0 - 1.0), consider:

### Evidence Completeness

- Did all tests run? All scenarios covered?
- Is the analysis complete? All code analyzed?
- Is coverage adequate? Meets ASIL target?
- **Guide:** 1.0 = All aspects covered; 0.87 = Meets target; 0.7-0.9 = Minor gaps; <0.5 = Significant gaps

### Evidence Correctness & Quality

- Are the test results reliable? (5/5 pass)
- Is the analysis output correct? (0 errors from cppcheck)
- Is the coverage accurately measured? (87% statement)
- **Guide:** 1.0 = Excellent; 0.87-0.9 = Good; <0.75 = Concerns

### Personal Confidence & Expertise

- Reflect honestly on certainty
- Are you within your area of expertise?
- Avoid overconfidence bias

**Team Action:** Define specific scoring rubric for LLTC evidence.

---

## 📊 Evidence Types & Artifacts

All levels use `references:` to link artifacts. SMEs manually review these references.

### 1. Code (Implementation)

**Linked In:** SWD requirements
**Organization:** `src/sensors/motor_speed.cpp`

```yaml
references:
  - type: "file"
    path: "src/sensors/motor_speed.cpp"
    description: "Motor speed sensor implementation (90 LOC)"
```

---

### 2. Tests (Verification)

**Linked In:** LLTC requirements
**Organization:** `tests/unit/`, `artifacts/verification/tests/`

```yaml
references:
  - type: "file"
    path: "tests/unit/test_motor_speed.cpp"
    description: "Test code (5 test cases)"
  - type: "file"
    path: "artifacts/verification/tests/LLTC-998-junit.xml"
    description: "Test results (5/5 pass)"
```

---

### 3. Design (Architecture)

**Linked In:** SRD requirements
**Organization:** `docs/design/`

```yaml
references:
  - type: "file"
    path: "docs/design/motor_system_architecture.md"
    description: "System architecture diagram"
  - type: "file"
    path: "docs/design/gpio_sensor_interface.md"
    description: "GPIO interface specification"
```

---

### 4. Analysis (Quality Checks)

**Linked In:** LLTC requirements
**Organization:** `artifacts/verification/static-analysis/`, `artifacts/verification/coverage/`

```yaml
references:
  - type: "file"
    path: "artifacts/verification/static-analysis/cppcheck-SWD-998.xml"
    description: "Static analysis (0 errors)"
  - type: "file"
    path: "artifacts/verification/coverage/coverage-SWD-998.xml"
    description: "Code coverage (87%)"
```

---

### 5. Review (Human Validation)

**Linked In:** Any requirement (documented in `reviewed:` field)

```yaml
reviewers:
  - name: "Carol Dev"
    email: "carol@example.com"

reviewed: "2025-11-05 - Approved by Carol Dev"
```

---

### 6. Compliance (Standards)

**Linked In:** SWD requirements
**Organization:** `docs/standards/iso26262/`

```yaml
ASIL: "A"

references:
  - type: "file"
    path: "docs/standards/iso26262/hara-motor-speed.md"
    description: "HARA analysis"
  - type: "file"
    path: "docs/standards/iso26262/asil-justification-swd-998.md"
    description: "ASIL A justification"
```

---

## 🔗 How to Link Artifacts (references:)

```yaml
---
id: <REQ-ID>
# ... other fields ...

references:
  - type: "file"
    path: <relative/path/to/artifact>
    description: "<What is this artifact?>"
  - type: "file"
    path: <another/path>
    description: "<Another artifact>"
---
```

**Best Practices:**
- Use `type: "file"` only
- Use paths relative to repo root
- Add specific descriptions
- Include all relevant artifacts
- Keep paths up-to-date

---

## 📁 Naming Conventions

### Test Results

```
artifacts/verification/tests/<REQ-ID>-<type>.<ext>
Examples: LLTC-998-junit.xml
```

### Static Analysis

```
artifacts/verification/static-analysis/<tool>-<REQ-ID>.<ext>
Examples: cppcheck-SWD-998.xml
```

### Coverage

```
artifacts/verification/coverage/coverage-<REQ-ID>.<ext>
Examples: coverage-SWD-998.xml
```

---

## ✅ ASIL Requirements (Human Review Always)

### ASIL A

- [ ] LLTC-998: Tests scored (0.90+)
- [ ] LLTC-997: Analysis scored (0.95+)
- [ ] LLTC-996: Coverage scored (0.80+)
- [ ] 1+ SME review of SWD
- [ ] Code implemented, unit tests, coverage >60%
- [ ] Static analysis: 0 errors
- [ ] SWD has ASIL: "A" field
- [ ] ASIL justification document exists

### ASIL B

- [ ] LLTC requirements all scored (0.87+)
- [ ] 2+ independent SME reviews of SWD
- [ ] Code, unit tests + integration tests, coverage >80%
- [ ] Static analysis: 0 errors
- [ ] PR with 2+ approvals
- [ ] SWD has ASIL: "B" field
- [ ] ASIL justification document

### ASIL C

- [ ] LLTC requirements all scored (0.90+)
- [ ] 2+ independent SME reviews of SWD
- [ ] System tests, coverage >90%
- [ ] FMEA documented
- [ ] SWD has ASIL: "C" field
- [ ] ASIL justification document

### ASIL D

- [ ] LLTC requirements all scored (0.95+)
- [ ] 3+ independent SME reviews of SWD
- [ ] Formal methods evidence
- [ ] Tool qualification
- [ ] SWD has ASIL: "D" field
- [ ] ASIL justification document

---

## 💡 Key Summary

| Field | URD | SRD | SWD | LLTC |
|-------|-----|-----|-----|------|
| **`score:`** | ❌ NO | ❌ NO | ❌ NO | ✓ YES |
| **`ASIL:`** | ❌ NO | ❌ NO | ✓ YES | ❌ NO |
| **`references:`** | ✓ YES | ✓ YES | ✓ YES | ✓ YES |
| Score from | — | Inherit LLTC | Inherit LLTC | Manual SME |
| Propagation | ← From SRD | ← From SWD | ← From LLTC | ← Manual |

---

## Related Documentation

- **Reference Commands:** See [reference.md](reference.md)
- **Workflows:** See [workflow.md](workflow.md)
- **Theory:** See [training.md](training.md)
- **Lab 2 Hands-On:** See [hands-on_lab_2.md](hands-on_lab_2.md)
- **ASIL Guidance:** See [asil_hara_guide.md](asil_hara_guide.md)
- **Artifact Conventions:** See [artifacts_convention.md](artifacts_convention.md)

---
