# TSF Hands-on Lab 2: Complete SWD-998 and Safety Documentation

**Objective:** Complete Software Design requirement (SWD-998), create HARA and ASIL justification documents, link evidence artifacts, add manual SME scores at **LLTC level**, validate requirements, and publish the trustable report.

**Prerequisites:**
- Completion of Lab 1 (understanding TSF workflow)
- URD-998, SRD-998, LLTC-998, LLTC-997, LLTC-996 already exist and are linked
- HARA and ASIL documents exist but are **EMPTY** (you will fill them)
- Implementation, tests, and artifacts already exist

**Format:** Work in pairs. Decide who will be the "Author" and who will be the "Reviewer".

**⚠️ IMPORTANT: Read These Documents First!**

Before starting the lab, both team members must read:
1. **[evidence.md](../evidence.md)** - How to link artifacts, configure scoring, and understand evidence types
2. **[asil_hara_guide.md](../asil_hara_guide.md)** - ASIL calculation methodology and HARA process
3. **[artifacts_convention.md](../artifacts_convention.md)** - Artifact naming conventions and organization

**Time Budget:** 3-4 hours total

---

## Context: What Already Exists

✅ **Requirements:** URD-998, SRD-998, SWD-998 (incomplete), LLTC-998, LLTC-997, LLTC-996
✅ **Implementation:** `src/sensors/motor_speed.cpp`, `motor_speed.h`
✅ **Tests:** `tests/unit/test_motor_speed.cpp` (5 test cases)
✅ **Artifacts:** junit.xml (5/5 pass), cppcheck.xml (0 errors), coverage.xml (87%)
❌ **Safety Docs:** hara-motor-speed.md (EMPTY), asil-justification-SWD-998.md (EMPTY)
✅ **Design Docs:** architecture.md, gpio_sensor_interface.md, sensor_selection.md
❌ **Missing:** SWD-998 content, HARA, ASIL justification, SME scores at LLTC

---

## Lab Tasks

### Task 1: Both Read Documentation (30 min)

**CRITICAL: Do not skip!**

```bash
cat docs/tsf/evidence.md
cat docs/tsf/asil_hara_guide.md
cat docs/tsf/artifacts_convention.md
```

**Discussion Questions:**
- Where do scores go: **LLTC or URD**?
- Do scores propagate **up or down**?
- What evidence is needed for ASIL A?

**Answer:** Scores go at **LLTC** (test level) and propagate **UPWARD** to parents.

---

### Task 2: Author Creates Branch & Reviews (15 min)

```bash
git checkout docs/63-create-and-run-hands-on-lab---part-2-linking-tsf-evidence
git fetch origin && git pull
git checkout -b docs/tsf_hands-on_lab_2
source .venv/bin/activate

# Study implementation
cat src/sensors/motor_speed.h
cat src/sensors/motor_speed.cpp
cat tests/unit/test_motor_speed.cpp

# Check artifacts
cat artifacts/verification/tests/LLTC-998-junit.xml
cat artifacts/verification/static-analysis/cppcheck-SWD-998.xml
cat artifacts/verification/coverage/coverage-SWD-998.xml

trudag manage lint
```

Note: For this exercise it is not important to understand the code in detail—focus on how it meets requirements. The goal is to write SWD-998 based on this implementation and link the artifacts.

---

### Task 3: Author Writes HARA (45 min)

Edit `docs/standards/iso26262/hara-motor-speed.md`:

**Guidance:**

**a. Item Definition (5 min):**
- What: Motor speed sensor system
- Boundaries: Motor rotation → RPM value
- Context: Lab, trained operators, emergency stop

**b. Identify Hazards (10 min):**
- H-001: "Sensor fails silently during test"

**c. Assess Severity (10 min):**
- Worst outcome: Motor overheats → minor burns
- Choose: S0, S1, S2, S3?
- **Hint:** Lab environment → S1

**d. Assess Exposure (10 min):**
- How often: Extended tests?
- Choose: E1 (<1%), E2 (1-5%), E3, E4?
- **Hint:** Regular tests → E2

**e. Assess Controllability (5 min):**
- Can operator stop: Emergency button?
- Choose: C0, C1, C2, C3?
- **Hint:** Operator present → C1

**f. Calculate ASIL (5 min):**
- Use table in asil_hara_guide.md Section 2.4
- S1 + E2 + C1 = ?

**g. Safety Goals (5 min):**
- "SG-001: Motor speed sensor shall function reliably..."

**Checkpoint:** Review with partner.

**If too difficult, see template below:**

```markdown
# HARA: Motor Speed Sensor

**Date:** 2025-11-03 | **Authors/Reviewers:** Team 04 | **ASIL Target:** A

## 1. Item Definition & Assumptions

**Description/Boundaries/Interfaces:** Motor speed monitoring system for DrivaPi lab testing.

**Assumptions:** Trained operators only; controlled lab environment.

## 2. Hazards & Operational Situations

| ID | Hazard Description | Operational Situation | Exposure (E) / Justification |
|----|-------|-------|--------|
| H-01 | Sensor fails silently | Extended motor test | E2 (~2-5% of tests; historical data) |

## 3. Risk Assessment & ASIL

- **Severity (S):** S1 - Motor overheats, minor burn risk if touched
- **Controllability (C):** C1 - Operator observes smoke/noise, presses emergency stop
- **ASIL Calculation:** S1 + E2 + C1 = **ASIL A** (from ISO 26262-3:2018 Table 4)

## 4. Safety Goals

| Goal ID | ASIL | Description | Safe State |
|---------|------|-------|-------|
| SG-01 | A | Motor speed sensor shall function reliably | Operator can monitor and stop motor |

## 5. Dependencies & Review Notes

**Dependencies:** Emergency stop button, GPIO hardware driver

**Review:** Team approval 2025-11-03 (Git commit: abc123def)

**References:** ISO 26262-3:2018
```

---

### Task 4: Author Writes ASIL Justification (30 min)

Edit `docs/standards/iso26262/asil-justification-SWD-998.md`:

**a. Summary (5 min):** Link to HARA, SG-001

**b. ASIL Assignment (10 min):** Why appropriate for DrivaPi?

**c. Risk Table (5 min):** S, E, C values with reasoning

**d. Verification (10 min):** Check evidence.md Section 7 for ASIL A requirements

**If too difficult, see template below:**

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
|--------|-------|-------|
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

---

### Task 5: Author Completes SWD-998 (30 min)

Edit `reqs/swd/SWD-998.md`:

**DO NOT COPY - Write your own!**

1. **Header (5 min):** Descriptive title
2. **Text (15 min):** Use SHALL, describe GPIO pin, algorithm (pulses×60), range (0-10000), error handling, methods
3. **Fields (5 min):** ASIL (from Task 4), verification_method, reviewers (partner)
4. **References (10 min):** Link 10 artifacts:

```yaml
references:
  - type: "file"
    path: "src/sensors/motor_speed.cpp"
    description: "Implementation (90 LOC, GPIO read, RPM conversion)"
  - type: "file"
    path: "src/sensors/motor_speed.h"
    description: "Header file with function declarations"
  - type: "file"
    path: "tests/unit/test_motor_speed.cpp"
    description: "5 unit tests (normal, boundaries, errors)"
  - type: "file"
    path: "artifacts/verification/tests/LLTC-998-junit.xml"
    description: "Test results: 5/5 PASS"
  - type: "file"
    path: "artifacts/verification/static-analysis/cppcheck-SWD-998.xml"
    description: "Static analysis: 0 errors"
  - type: "file"
    path: "artifacts/verification/coverage/coverage-SWD-998.xml"
    description: "Code coverage: 87%"
  - type: "file"
    path: "docs/design/architecture/motor_system_architecture.md"
    description: "System architecture and data flow"
  - type: "file"
    path: "docs/design/interfaces/gpio_sensor_interface.md"
    description: "GPIO pin specification"
  - type: "file"
    path: "docs/standards/iso26262/hara-motor-speed.md"
    description: "HARA: ASIL A determination"
  - type: "file"
    path: "docs/standards/iso26262/asil-justification-SWD-998.md"
    description: "ASIL A justification with evidence"
```

**IMPORTANT:** Do NOT add `evidence:` blocks. Use only `references:` for manual SME review.

---

### Task 6: Author Validates & Commits (10 min)

```bash
trudag manage lint
git add reqs/swd/SWD-998.md docs/standards/iso26262/*.md .dotstop.dot
git commit -m "feat(swd): Complete SWD-998 with HARA and ASIL"
git push -u origin feat/complete-SWD-998
```

**⚠️ IMPORTANT:** Since you are two groups working on the same requirement, create a branch from master and do a pull request to avoid conflicts.

---

### Task 7: Reviewer Reviews ENTIRE Chain (30 min)

```bash
git fetch origin && git checkout feat/complete-SWD-998
source .venv/bin/activate
```

**Checklist:**

- ✅ URD-998: User need clear?
- ✅ SRD-998: System spec complete?
- ✅ SWD-998: Header, text, ASIL, all 10 artifacts linked?
- ✅ Evidence: Tests pass? Static analysis clean? Coverage adequate?
- ✅ HARA: S, E, C justified? ASIL calculated correctly?
- ✅ ASIL Justification: Links to HARA? Requirements listed?
- ✅ LLTC-998, LLTC-996, LLTC-997: All test requirements complete?

---

### Task 8: Reviewer Adds Scores to LLTC (20 min)

**CRITICAL: Score goes on LLTC (test level), not URD!**

**Assess evidence at test level:**
- LLTC-998: 5/5 tests pass?
- LLTC-996: 87% coverage (meets 80% target)?
- LLTC-997: 0 static analysis errors?

#### Add Score to LLTC-998

```bash
nano reqs/lltc/LLTC-998.md
```

After `references:`, before `active:`:

```yaml
score:
  <YOUR_NAME>: 0.95
```

**Rationale:** 5/5 tests pass, comprehensive test cases, all scenarios covered.

#### Add Score to LLTC-996

```bash
nano reqs/lltc/LLTC-996.md
```

After `references:`, before `active:`:

```yaml
score:
  <YOUR_NAME>: 0.87
```

**Rationale:** 87% coverage meets 80% ASIL A target, good but not perfect.

#### Add Score to LLTC-997

```bash
nano reqs/lltc/LLTC-997.md
```

After `references:`, before `active:`:

```yaml
score:
  <YOUR_NAME>: 1.0
```

**Rationale:** 0 errors in static analysis, perfect result.

**Update reviewed fields:**

```bash
nano reqs/urd/URD-998.md
# Add: reviewed: "2025-11-05 - Approved by <Name>"

nano reqs/srd/SRD-998.md
# Add: reviewed: "2025-11-05 - Approved by <Name>"

nano reqs/swd/SWD-998.md
# Add: reviewed: "2025-11-05 - Approved by <Name>"

nano reqs/lltc/LLTC-998.md
# Update: reviewed: "2025-11-05 - Approved by <Name>"

nano reqs/lltc/LLTC-996.md
# Update: reviewed: "2025-11-05 - Approved by <Name>"

nano reqs/lltc/LLTC-997.md
# Update: reviewed: "2025-11-05 - Approved by <Name>"
```

**Commit changes:**

```bash
trudag manage set-item URD-998
trudag manage set-item SRD-998
trudag manage set-item SWD-998
trudag manage set-item LLTC-998
trudag manage set-item LLTC-996
trudag manage set-item LLTC-997
trudag manage lint
git add reqs/urd/URD-998.md reqs/srd/SRD-998.md reqs/swd/SWD-998.md reqs/lltc/*.md .dotstop.dot
git commit -m "review: Approve chain with SME scores at LLTC"
git push
```

---

### Task 9: Reviewer Calculates Scores (10 min)

**Score propagates UPWARD from LLTC:**

```
URD-998: 0.94 (inherited)
   ↑ (propagates up)
SRD-998: 0.94 (inherited)
   ↑ (propagates up)
SWD-998: 0.94 (inherited - average of children)
   ↑ (propagates up)
LLTC-998: 0.95 (manual - test results)
LLTC-996: 0.87 (manual - coverage)
LLTC-997: 1.0 (manual - static analysis)
```

**Run score calculation:**

```bash
trudag score
```

**Expected results:**
- LLTC-998: 0.95
- LLTC-996: 0.87
- LLTC-997: 1.0
- SWD-998: ~0.94 (average of 3 children)
- SRD-998: 0.94
- URD-998: 0.94

**Commit:**

```bash
git add .dotstop.dot
git commit -m "score: Propagate scores upward from LLTC to URD"
git push
```

---

### Task 10: Reviewer Generates Report (10 min)

```bash
trudag publish --output-dir artifacts/trustable-report
cat artifacts/trustable-report/dashboard.md
```

**Verify:** All requirements with scores, traceability chain, evidence links, HARA/ASIL docs.

**Commit:**

```bash
git add artifacts/trustable-report/
git commit -m "docs(tsf): Publish report for URD-998 chain"
git push
```

---

### Task 11: Final Approval & Merge (5 min)

**On GitHub, add approval comment:**

```
✅ APPROVED - URD-998 Motor Speed Monitoring Chain

- URD-998: User need clear
- SRD-998: System spec complete
- SWD-998: Implementation complete with evidence links
- LLTC-998: Tests pass (5/5) → Score: 0.95
- LLTC-996: Coverage adequate (87%) → Score: 0.87
- LLTC-997: Static analysis clean (0 errors) → Score: 1.0
- HARA/ASIL reviewed (ASIL A)
- SME scores at LLTC level
- Scores propagated upward
```
Merge PR.

---

## References

- [evidence.md](../evidence.md)
- [asil_hara_guide.md](../asil_hara_guide.md)
- [artifacts_convention.md](../artifacts_convention.md)
- ISO 26262-3:2018
- ISO 26262-6:2018

---

**Congratulations! 🎉 You've mastered TSF manual evidence linking and ASIL justification!**
