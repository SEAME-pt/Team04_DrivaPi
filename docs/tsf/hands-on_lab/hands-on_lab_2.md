# TSF Hands-on Lab 2: Complete SWD-998 and Safety Documentation

**Objective:** Complete Software Design requirement (SWD-998), create HARA and ASIL justification documents, link evidence artifacts, add manual SME scores at URD level, validate requirements, and publish the trustable report.

**Prerequisites:**
- Completion of Lab 1 (understanding TSF workflow)
- URD-998 and SRD-998 already exist and are linked
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

✅ **Requirements:** URD-998, SRD-998, SWD-998 (incomplete), LLTC-998
✅ **Implementation:** `src/sensors/motor_speed.cpp`, `motor_speed.h`
✅ **Tests:** `tests/unit/test_motor_speed.cpp` (5 test cases)
✅ **Artifacts:** junit.xml (5/5 pass), cppcheck.xml (0 errors), coverage.xml (87%)
❌ **Safety Docs:** hara-motor-speed.md (EMPTY), asil-justification-SWD-998.md (EMPTY)
✅ **Design Docs:** architecture.md, gpio_sensor_interface.md, sensor_selection.md
❌ **Missing:** SWD-998 content, HARA, ASIL justification, SME scores at URD

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
- Where do scores go: URD or SWD?
- Do scores propagate up or down?
- What evidence is needed for ASIL A?

---

### Task 2: Author Creates Branch & Reviews (15 min)

```bash
git checkout master && git pull
git checkout -b feat/complete-SWD-998
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

Note: For this exercise it is not important to understand the code in detail—focus on how it meets requirements. Neither it is necessary to be 100% accurate. Those are examples. The goal is to write SWD-998 based on this implementation and link the artifacts.

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
- **Hint:** Occasional → E2

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

---

### Task 4: Author Writes ASIL Justification (30 min)

Edit `docs/standards/iso26262/asil-justification-SWD-998.md`:

**a. Summary (5 min):** Link to HARA, SG-001

**b. ASIL Assignment (10 min):** Why appropriate for DrivaPi?

**c. Risk Table (5 min):** S, E, C values with reasoning

**d. Verification (10 min):** Check evidence.md Section 7 for ASIL A requirements

---

### Task 5: Author Completes SWD-998 (30 min)

Edit `reqs/swd/SWD-998.md`:

**TRY NOT TO COPY:**

1. **Header (5 min):** Descriptive title
2. **Text (15 min):** Use SHALL, describe GPIO pin, algorithm (pulses×60), range (0-10000), error handling, methods
3. **Fields (5 min):** ASIL (from Task 4), verification_method, reviewers (partner)
4. **References (10 min):** Link 10 artifacts:
   ```yaml
   references:
     - type: "file"
       path: "src/sensors/motor_speed.cpp"
       description: "Implementation - TODO: fill details"
     - type: "file"
       path: "src/sensors/motor_speed.h"
       description: "Header - TODO"
     - type: "file"
       path: "tests/unit/test_motor_speed.cpp"
       description: "TODO: How many tests?"
     - type: "file"
       path: "artifacts/verification/tests/LLTC-998-junit.xml"
       description: "TODO: Pass/fail?"
     - type: "file"
       path: "artifacts/verification/static-analysis/cppcheck-SWD-998.xml"
       description: "TODO: Errors?"
     - type: "file"
       path: "artifacts/verification/coverage/coverage-SWD-998.xml"
       description: "TODO: %?"
     - type: "file"
       path: "docs/design/architecture/motor_system_architecture.md"
       description: "TODO"
     - type: "file"
       path: "docs/design/interfaces/gpio_sensor_interface.md"
       description: "TODO"
     - type: "file"
       path: "docs/standards/iso26262/hara-motor-speed.md"
       description: "TODO: ASIL?"
     - type: "file"
       path: "docs/standards/iso26262/asil-justification-SWD-998.md"
       description: "TODO"
   ```
   **Replace ALL TODOs!**

---

### Task 6: Author Validates & Commits (10 min)

```bash
trudag manage lint
git add reqs/swd/SWD-998.md docs/standards/iso26262/*.md .dotstop.dot
git commit -m "feat(swd): Complete SWD-998 with HARA and ASIL"
git push -u origin feat/complete-SWD-998
```


**⚠️ IMPORTANT: SINCE YOU ARE TWO GROUP WORKING ON THE SAME REQUIREMENT, AFTER PUSHING, CREATE A BRANCH FROM MASTER AND DO A PULL REQUEST TO THIS BRANCH TO AVOID CONFLICTS.**

---

### Task 7: Reviewer Reviews ENTIRE Chain (30 min)

```bash
git fetch origin && git checkout feat/complete-SWD-998
source .venv/bin/activate
```

**Review URD-998:** User need clear?

**Review SRD-998:** System spec complete?

**Review SWD-998:** Header, text, ASIL, all 10 artifacts linked?

**Review Evidence:** Tests pass? Static analysis clean? Coverage adequate?

**Review HARA:** S, E, C justified? ASIL calculated correctly?

**Review ASIL Justification:** Links to HARA? Requirements listed?

---

### Task 8: Reviewer Adds Score to URD-998 (20 min)

**CRITICAL: Score goes on URD, not SWD!**

**Assess ENTIRE chain:**
- URD-998: User need clear?
- SRD-998: System spec complete?
- SWD-998: Implementation + evidence?
- LLTC-998: Tests pass?

**Add to URD-998:**
```bash
nano reqs/urd/URD-998.md
```

After `references:`, before `active:`:
```yaml
# Manual SME Score (entire chain reviewed)
score:
  <YOUR_NAME>: 0.92
```

**Rationale:** Complete chain, all tests pass, clean analysis, good coverage, complete HARA/ASIL, minor gap (no integration tests, OK for ASIL A).

**Update reviewed fields:**
```bash
nano reqs/urd/URD-998.md
# Add: reviewed: "2025-11-03 - Approved by <Name> <email>"
nano reqs/srd/SRD-998.md
# Add: reviewed: "2025-11-03 - Approved by <Name> <email>"
nano reqs/swd/SWD-998.md
# Add: reviewed: "2025-11-03 - Approved by <Name> <email>"
```

```bash
trudag manage set-item URD-998
trudag manage set-item SRD-998
trudag manage set-item SWD-998
trudag manage lint
git add reqs/urd/URD-998.md reqs/srd/SRD-998.md reqs/swd/SWD-998.md .dotstop.dot
git commit -m "review: Approve URD-998 chain with SME score 0.92"
git push
```

---

### Task 9: Reviewer Calculates Scores (10 min)

**Score propagates DOWNWARD from URD:**

```
URD-998: 0.92 (manual)
   ↓
SRD-998: 0.92 (inherited)
   ↓
SWD-998: 0.92 (inherited)
   ↓
LLTC-998: 0.92 (inherited)
```

```bash
trudag score
```

Expected: All -998 requirements show 0.92.

```bash
git add .dotstop.dot
git commit -m "score: Propagate 0.92 from URD-998 to chain"
git push
```

---

### Task 10: Reviewer Generates Report (10 min)

```bash
trudag publish --output-dir artifacts/trustable-report
cat artifacts/trustable-report/dashboard.md
```

Verify: All requirements with scores, traceability chain, evidence links, HARA/ASIL docs.

```bash
git add artifacts/trustable-report/
git commit -m "docs(tsf): Publish report for URD-998 chain"
git push
```

---

### Task 11: Final Approval & Merge (5 min)

**On GitHub:**

> ✅ **APPROVED - URD-998 Motor Speed Monitoring Chain**
>
> - URD-998: User need clear
> - SRD-998: System spec complete
> - SWD-998: Implementation complete
> - LLTC-998: Tests pass (5/5)
> - HARA/ASIL reviewed (ASIL A)
> - Analysis clean (0 errors, 87% coverage)
> - SME score: 0.92 at URD
> - Scores propagated to children
>
> **Traceability:**
> ```
> URD-998 → 0.92 (SME)
>   ↓
> SRD-998 → 0.92 (inherited)
>   ↓
> SWD-998 → 0.92 (inherited)
>   ↓
> LLTC-998 → 0.92 (inherited)
> ```

Merge PR.



---

## Completion Checklist

### HARA & ASIL
- [ ] HARA: Item definition
- [ ] HARA: Hazard H-001 identified
- [ ] HARA: S, E, C assessed
- [ ] HARA: ASIL calculated (ISO 26262 table)
- [ ] HARA: Safety goals
- [ ] ASIL: Links to HARA
- [ ] ASIL: Assignment explained
- [ ] ASIL: Verification requirements

### SWD-998
- [ ] Header: Descriptive
- [ ] Text: Complete (GPIO, algorithm, range, errors, methods)
- [ ] ASIL: Matches HARA
- [ ] Parents: SRD-998
- [ ] Children: LLTC-998
- [ ] Reviewers: Partner info

### Evidence (10)
- [ ] motor_speed.cpp
- [ ] motor_speed.h
- [ ] test_motor_speed.cpp
- [ ] LLTC-998-junit.xml
- [ ] cppcheck-SWD-998.xml
- [ ] coverage-SWD-998.xml
- [ ] motor_system_architecture.md
- [ ] gpio_sensor_interface.md
- [ ] hara-motor-speed.md (compliance)
- [ ] asil-justification-SWD-998.md (compliance)

### Review & Scoring
- [ ] Reviewed URD, SRD, SWD, LLTC
- [ ] Score added to **URD-998** (0.90-0.95)
- [ ] Reviewed fields filled
- [ ] Set-item executed
- [ ] Lint passes

### Trustable
- [ ] Score executed
- [ ] Scores propagated down
- [ ] Publish generated report
- [ ] Dashboard shows all
- [ ] Traceability visible
- [ ] Evidence listed

---

## Key Learning Outcomes

✅ **HARA:** Perform hazard analysis, calculate ASIL

✅ **ASIL Justification:** Create with evidence

✅ **SWD:** Write complete requirements with SHALL

✅ **Evidence:** Link 10 artifacts (use `type: "compliance"` for safety docs)

✅ **ASIL A:** Unit tests, coverage ≥80%, static analysis 0 errors, code review

✅ **SME Scoring:** Review ENTIRE chain, score at **URD**

✅ **Propagation:** Scores go **DOWNWARD** from URD

✅ **V-Model:** URD→SRD→SWD→LLTC→Evidence→Score(URD)→Propagate Down

---

## Understanding Scores

### Where?
✅ **URD** (after reviewing entire chain)
❌ SRD/SWD/LLTC (inherit from URD)

### How?
```
URD-998: 0.92 (manual - chain assessed)
   ↓
SRD-998: 0.92 (inherited)
   ↓
SWD-998: 0.92 (inherited)
   ↓
LLTC-998: 0.92 (inherited)
```

### Workflow
```bash
1. Review URD→SRD→SWD→LLTC→evidence
2. Add score: to URD-998
3. trudag score (propagates down)
4. trudag publish (generates report)
```

---

## Troubleshooting

**Score doesn't propagate:**
```bash
# Verify in URD (not SWD!)
cat reqs/urd/URD-998.md | grep -A 2 "score:"
trudag score
trudag manage lint --verbose
```

**ASIL wrong:**
- Check asil_hara_guide.md Section 2.4
- S1 + E2 + C1 = ASIL A

**.dotstop.dot modified:**
- Expected! Always commit it.

---

## Congratulations! 🎉

**Skills Mastered:**
- ✅ HARA (Hazard Analysis)
- ✅ ASIL calculation (ISO 26262)
- ✅ ASIL justification
- ✅ Complete SWD requirements
- ✅ Evidence linking (10 types)
- ✅ ASIL A compliance
- ✅ SME scoring at URD
- ✅ Downward score propagation
- ✅ Trustable reports

**Next:** Apply to other features, practice higher ASIL levels (B, C), learn automated evidence validators.

**References:**
- [reference.md](../reference.md)
- [workflow.md](../workflow.md)
- [evidence.md](../evidence.md)
- [asil_hara_guide.md](../asil_hara_guide.md)
- [training.md](../training.md)
