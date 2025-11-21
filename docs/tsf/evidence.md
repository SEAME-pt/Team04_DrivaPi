# TSF Evidence Guide - DrivaPi

**Goal:** How to link artifacts as references for human review and understand scoring using the `trudag` tool.

**Principle:** Each claim (Statement) needs verifiable proof linked in `references:`. Confidence (Score) is derived from manual SME assessment **ONLY at URD level**. No `evidence:` blocks - all ASIL evaluation requires human expert review.

> **Commands:** See [reference.md](reference.md)
> **Workflows:** See [workflow.md](workflow.md)
> **Theory:** See [training.md](training.md)

---

## 📝 Spike Summary: Clarifying Linking Syntax

**Date:** October 28, 2025 | **Updated:** November 5, 2025

Based on analysis and `trudag` CLI documentation, the team clarifies syntax usage:

1. **`references:` Block:** Standard method for linking passive artifacts (files, URLs). Provides context for human SME review and traceability links in reports. **Used at ALL levels.**
2. **`evidence:` Block:** ~~Exclusively for configuring custom automated validators~~ **NOT USED in DrivaPi.**
   - **Reason 1:** Implementation complexity (requires custom validator development)
   - **Reason 2:** ASIL evaluation (A and above) always requires human expert review per ISO 26262
   - **Reason 3:** Cannot delegate safety judgment to automation
3. **`score:` Block:** Used for recording manual Subject Matter Expert (SME) scores. **ONLY at URD level.**
4. **Deprecated `artifact:` Block:** Not standard for `trudag` - use `references:` instead.

**Implementation:** This document details usage for `references:` and `score:` only. **ZERO `evidence:` blocks. Score ONLY in URD.**

---

## 💯 How Scores Are Determined

The **"Trustable Score"** (0.0 to 1.0) for each requirement reflects the team's confidence in its truth.

### Score Assignment (Manual SME Assessment) - URD Level ONLY

**Process:** One or more Subject Matter Experts (SMEs) review the URD Statement and linked references. They assign a score in the URD `score:` block. This score **automatically propagates down** to all descendants (SRD → SWD → LLTC).

**Syntax - URD :**
```yaml
---
id: URD-998
header: "Motor speed monitoring for test operations"
text: |
  "Operators need to monitor motor speed during extended test runs
  to ensure test validity and detect anomalies."

references:
  - type: "file"
    path: docs/user_needs_analysis.md
    description: "User needs analysis"
  - type: "file"
    path: docs/standards/iso26262/hara-motor-speed.md
    description: "HARA analysis"

# ✓ ONLY score: block at URD level
score:
  ProductOwner: 0.95      # "Yes, operators definitely need this"
  LabManager: 0.92        # "Confirmed by 2 years of lab history"

children:
  - id: SRD-998

# ... other fields ...
---
```

**Syntax - SRD :**
```yaml
---
id: SRD-998
header: "Motor speed sensor GPIO interface"
text: |
  "System shall interface with a tachometer-style speed sensor via GPIO
  Pin 17 to read motor RPM with a sampling rate of at least 1 Hz."

# ✓ references at SRD level
references:
  - type: "file"
    path: docs/design/motor_system_architecture.md
    description: "System architecture"
  - type: "file"
    path: docs/design/gpio_sensor_interface.md
    description: "GPIO interface specification"


parents:
  - id: URD-998

children:
  - id: SWD-998

# ... other fields ...
---
```

**Syntax - SWD :**
```yaml
---
id: SWD-998
header: "Motor speed sensor driver implementation"
text: |
  "Implement GPIO-based motor speed sensor driver that reads pulse count
  over 1-second windows, converts to RPM with ±1% accuracy, validates
  range (0-10000 RPM), and detects/reports errors."

ASIL: "A"  # ← ASIL ONLY at SWD

# ✓ references at SWD level
references:
  - type: "file"
    path: src/sensors/motor_speed.cpp
    description: "Implementation (90 LOC)"
  - type: "file"
    path: tests/unit/test_motor_speed.cpp
    description: "Unit tests (5 test cases)"
  - type: "file"
    path: artifacts/verification/tests/LLTC-998-junit.xml
    description: "Test results (5/5 pass)"
  - type: "file"
    path: artifacts/verification/static-analysis/cppcheck-SWD-998.xml
    description: "Static analysis (0 errors)"
  - type: "file"
    path: artifacts/verification/coverage/motor-coverage.txt
    description: "Code coverage (87%)"
  - type: "file"
    path: docs/standards/iso26262/asil-justification-swd-998.md
    description: "ASIL A justification"

parents:
  - id: SRD-998

children:
  - id: LLTC-998

reviewers:
  - name: "Carol Dev"
    email: "carol@example.com"

reviewed: "2025-11-03 - Approved by Carol Dev"

# ... other fields ...
---
```

**Syntax - LLTC :**
```yaml
---
id: LLTC-998
header: "Motor speed sensor unit tests"
text: |
  "Verify motor speed sensor driver through 5 unit tests covering normal
  operation, boundary conditions, and error handling."

# ✓ references at LLTC level
references:
  - type: "file"
    path: tests/unit/test_motor_speed.cpp
    description: "Unit test implementation"
  - type: "file"
    path: artifacts/verification/tests/LLTC-998-junit.xml
    description: "Test results (5/5 pass)"

parents:
  - id: SWD-998

# ... other fields ...
---
```

### Score Propagation (How trudag Calculates Everything)

```
URD-998: score: { ProductOwner: 0.95, LabManager: 0.92 }
   Average: 0.935
   ↓ (trudag automatically propagates)
SRD-998: (NO score field) → inherits 0.935 from URD-998
   ↓
SWD-998: (NO score field) → inherits 0.935 from SRD-998
   ↓
LLTC-998: (NO score field) → inherits 0.935 from SWD-998

Result: Entire chain has 0.935 confidence!
```

**Why?** Traceability links (parents/children) define the chain. One URD score flows down automatically via trudag.

### Interpretation (Probability)

The URD score represents confidence that the user need is real and necessary:
- **1.0** = Certain the user need is true/necessary
- **0.75-0.9** = Very confident, minor doubts
- **0.5** = Completely uncertain
- **0.25-0.5** = Low confidence
- **0.0** = Certain the user need is false/not necessary

---

## 🎯 WHERE and WHY We Justify ASIL

### Location: SWD Level ONLY

ASIL field appears in SWD only:
```yaml
---
id: SWD-998
ASIL: "A"  # ← ASIL field ONLY at SWD level
```

### Why SWD Level Only?

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

## 📋 SME Scoring Guidance (for URD score: block ONLY)

When assigning a score to URD (0.0 - 1.0), consider:

### Evidence Completeness
- Does the linked evidence fully cover the user need?
- Are all aspects of the need addressed?
- **Guide:** 1.0 = Fully covered; 0.7-0.9 = Minor gaps; <0.5 = Mostly missing

### Evidence Correctness & Quality
- Is the evidence clear and well-documented?
- Does it clearly demonstrate the need is real?
- **Guide:** 1.0 = Excellent; 0.7-0.9 = Minor issues; <0.5 = Poor quality

### Personal Confidence & Expertise
- Reflect honestly on certainty
- Are you within your area of expertise?
- Avoid overconfidence bias

**Team Action:** Define specific scoring rubric.

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

## Evidence Types & Artifacts

All levels use `references:` to link artifacts. SMEs manually review these references.

### 1. Code (Implementation)

**Linked In:** SWD requirements
**Organization:** `src/sensors/motor_speed.cpp`

```yaml
references:
  - type: "file"
    path: src/sensors/motor_speed.cpp
    description: "Motor speed sensor implementation"
```

---

### 2. Tests (Verification)

**Linked In:** LLTC requirements
**Organization:** `tests/unit/`, `artifacts/verification/tests/`

```yaml
references:
  - type: "file"
    path: tests/unit/test_motor_speed.cpp
  - type: "file"
    path: artifacts/verification/tests/LLTC-998-junit.xml
    description: "Test results (5/5 pass)"
```

---

### 3. Design (Architecture)

**Linked In:** SRD requirements
**Organization:** `docs/design/`

```yaml
references:
  - type: "file"
    path: docs/design/motor_system_architecture.md
  - type: "file"
    path: docs/design/gpio_sensor_interface.md
```

---

### 4. Analysis (Quality Checks)

**Linked In:** SWD requirements
**Organization:** `artifacts/verification/static-analysis/`, `artifacts/verification/coverage/`

```yaml
references:
  - type: "file"
    path: artifacts/verification/static-analysis/cppcheck-SWD-998.xml
  - type: "file"
    path: artifacts/verification/coverage/motor-coverage.txt
```

---

### 5. Review (Human Validation)

**Linked In:** Any requirement (documented in `reviewed:` field)

```yaml
reviewers:
  - name: "Carol Dev"
    email: "carol@example.com"

reviewed: "2025-11-03 - Approved by Carol Dev"
```

---

### 6. Compliance (Standards)

**Linked In:** SWD requirements
**Organization:** `docs/standards/iso26262/`

```yaml
ASIL: "A"

references:
  - type: "file"
    path: docs/standards/iso26262/hara-motor-speed.md
  - type: "file"
    path: docs/standards/iso26262/asil-justification-swd-998.md
```

---

## 🔗 How to Link Artifacts (references: at ALL levels)

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

## Naming Conventions

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
artifacts/verification/coverage/<module>-coverage.<ext>
Examples: motor-coverage.txt
```

---

## ✅ ASIL Requirements (Human Review Always)

### ASIL A
- [ ] 1+ SME review of ASIL justification
- [ ] Code implemented, unit tests, coverage >60%
- [ ] Static analysis: 0 errors
- [ ] SWD has ASIL: "A" field
- [ ] ASIL justification document exists

### ASIL B
- [ ] 2+ independent SME reviews
- [ ] Code, unit tests + integration tests, coverage >80%
- [ ] Static analysis: 0 errors
- [ ] PR with 2+ approvals
- [ ] SWD has ASIL: "B" field
- [ ] ASIL justification document

### ASIL C
- [ ] 2+ independent SME reviews
- [ ] System tests, coverage >90%
- [ ] FMEA documented
- [ ] SWD has ASIL: "C" field
- [ ] ASIL justification document

### ASIL D
- [ ] 3+ independent SME reviews
- [ ] Formal methods evidence
- [ ] Tool qualification
- [ ] SWD has ASIL: "D" field
- [ ] ASIL justification document

---

## 💡 Key Summary

| Field | URD | SRD | SWD | LLTC |
|-------|-----|-----|-----|------|
| **`score:`** | ✓ YES | ❌ NO | ❌ NO | ❌ NO |
| **`ASIL:`** | ❌ NO | ❌ NO | ✓ YES | ❌ NO |
| **`references:`** | ✓ YES | ✓ YES | ✓ YES | ✓ YES |
| Score from | Manual SME | Inherit URD | Inherit URD | Inherit URD |

