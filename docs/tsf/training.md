# TSF Training Guide - DrivaPi

**Prerequisites:** Complete `docs/tsf/workflows.md` first
**Evidence-Based:** Hands-on lab with verifiable outputs

---

## 📋 Training Objectives

By the end of this training, you will:

✅ Understand TSF principles and evidence-based development
✅ Know ISO 26262 basics and ASIL levels
✅ Write requirements following V-Model
✅ Create and maintain traceability
✅ Use official tools (`trudag` + `doorstop`)
✅ Complete full requirement lifecycle

---

## 🎓 Training Modules

### Module 1: TSF Fundamentals (30 min)

#### What is TSF?

**TSF (Trustable Software Framework)** is an evidence-based approach to software development.

**Core Principle:** Trust in software must be based on evidence, not assumptions.

**Key Concepts:**

1. **Statements** - Requirements, claims, expectations
2. **Links** - Traceability between statements
3. **Evidence** - Artifacts proving statements are true
4. **Review** - SME validation of statements

**Example:**
```
Statement: "System SHALL display speed within 100ms"
Evidence:  Test log showing 95ms average response time
Review:    Approved by John Doe on 2025-10-20
```

#### TSF Graph Structure

```
URD-001: "User needs speed display"
   ↓ (links to)
SRD-001: "System shall show speed on HMI"
   ↓ (links to)
SWD-001: "Qt widget updates every 100ms"
   ↓ (links to)
LLTC-001: "Test: Widget refresh time < 100ms"
```

This is a **V-Model** - requirements flow down, verification flows up.

#### Evidence Types

1. **Requirements Evidence:**
   - YAML files with `reviewed:` field
   - Git commit SHA proving who/when approved
   - PR approval logs

2. **Design Evidence:**
   - Architecture diagrams
   - Interface specifications
   - Design review notes

3. **Implementation Evidence:**
   - Source code
   - Code review approvals
   - Static analysis reports

4. **Test Evidence:**
   - Test results (JUnit XML)
   - Coverage reports
   - Test execution logs

#### TSF vs Traditional Development

| Traditional | TSF |
|-------------|-----|
| "Requirement approved" | `reviewed: 'git-sha-abc123'` |
| "Tests passed" | JUnit XML + coverage report |
| "Code reviewed" | PR approval + checklist |
| "Requirements linked" | Doorstop graph + matrix CSV |

**Key Difference:** Everything is verifiable and traceable.

#### Official Tools Only

**Why?**
- Maintained by Eclipse Foundation
- Auditable and reproducible
- No custom code to maintain
- Community support

**Tools:**
- `trudag` - Trustable DAG (requirements graph)
- `doorstop` - Requirements backend

---

### Module 2: ISO 26262 Basics (20 min)

#### What is ISO 26262?

International standard for **functional safety** in automotive systems.

**Purpose:** Reduce risk of system failures that could cause harm.

#### V-Model Lifecycle

```
        Concept → Design → Implementation
          ↓         ↓          ↓
        URD  →  SRD  →  SWD  →  Code
          ↑         ↑          ↑
      UAT   ←  SIT  ←  UT   ←  Tests
```

**Left side:** Requirements (what to build)
**Right side:** Verification (prove it works)

#### ASIL Levels (Automotive Safety Integrity Level)

| ASIL | Risk | Examples | Verification Effort |
|------|------|----------|---------------------|
| QM | No safety impact | Entertainment | Basic testing |
| A | Low | Rear lights | Unit tests + review |
| B | Low-Medium | Brake lights | + Integration tests |
| C | Medium | ABS, ESC | + System tests + coverage |
| D | High | Airbags, steering | + Independent review + HIL |

#### ASIL Determination

**Formula:** Severity × Exposure × Controllability = ASIL

**Example: Speedometer failure**
- Severity: S2 (minor injury possible)
- Exposure: E4 (high probability)
- Controllability: C2 (easily controllable)
- **Result:** ASIL B

**For DrivaPi:**
- Most features: ASIL A or B
- Critical safety: ASIL C (e.g., emergency stop)
- Non-safety: QM (e.g., display themes)

#### Verification Requirements by ASIL

**ASIL A:**
- 1 peer review
- Unit tests (if software)
- Traceability to parent

**ASIL B:**
- 2 reviewers (domain + technical)
- Unit + integration tests
- Design review
- Static analysis

**ASIL C:**
- Independent reviewer (non-author)
- System tests
- Code coverage >80%
- Formal test reports

**ASIL D:**
- Formal sign-off
- HIL testing
- Full traceability audit
- Independent verification team

---

### Module 3: Requirements Engineering (30 min)

#### Good Requirement Characteristics

**SMART Requirements:**
- **S**pecific - Clear and unambiguous
- **M**easurable - Testable with pass/fail criteria
- **A**chievable - Technically feasible
- **R**elevant - Supports project goals
- **T**imebound - Has performance constraints

#### Writing Requirements

**Use "SHALL" for mandatory requirements:**
```yaml
# Good:
text: "The system SHALL display speed in km/h ±1 km/h"

# Bad:
text: "The system should show speed quickly"
```

**Be Specific:**
```yaml
# Good:
text: "The software SHALL sample sensor at 10 Hz with timeout of 100ms"

# Bad:
text: "The software will read sensor regularly"
```

**Include Units:**
```yaml
# Good:
text: "Temperature SHALL be displayed in °C with accuracy ±0.5°C"

# Bad:
text: "Temperature shown accurately"
```

#### V-Model Decomposition

**URD (User Requirement):**
```yaml
URD-001:
  header: "Display vehicle speed"
  text: "The user SHALL be able to view current vehicle speed on the dashboard"
  ASIL: B
```

**SRD (System Requirement):**
```yaml
SRD-001:
  header: "HMI speed display"
  text: "The system SHALL display vehicle speed on the HMI with accuracy ±1 km/h, updated every 100ms"
  links: [URD-001]  # Traces to parent
  ASIL: B
```

**SWD (Software Requirement):**
```yaml
SWD-001:
  header: "Qt speed widget"
  text: "The software SHALL implement a Qt widget that reads speed from CAN bus at 10 Hz and updates display within 100ms"
  links: [SRD-001]  # Traces to parent
  ASIL: B
```

**LLTC (Test Case):**
```yaml
LLTC-001:
  header: "Test speed display timing"
  text: "Test SHALL verify Qt widget updates within 100ms when CAN speed message received"
  links: [SWD-001]  # Traces to parent
  ASIL: B
```

#### Acceptance Criteria

**Format:** GIVEN / WHEN / THEN

```yaml
acceptance:
  - GIVEN: vehicle speed is 50 km/h
    WHEN: speed changes to 60 km/h
    THEN: display SHALL update within 100ms showing 60 ±1 km/h

  - GIVEN: CAN bus connection lost
    WHEN: timeout exceeds 500ms
    THEN: display SHALL show "---" and log error
```

---

### Module 4: Traceability (20 min)

#### Why Traceability Matters

**Benefits:**
1. **Coverage:** Ensure all user needs are met
2. **Impact Analysis:** Know what's affected by changes
3. **Verification:** Prove requirements are tested
4. **Audit:** Show compliance with standards

#### Bidirectional Traceability

**Forward:** User needs → Implementation
```
URD-001 → SRD-001 → SWD-001 → Code → LLTC-001
```

**Backward:** Tests → Requirements
```
LLTC-001 → SWD-001 → SRD-001 → URD-001
```

**Example:**
```yaml
# Child explicitly links to parent
SWD-001:
  links: [SRD-001]

# Doorstop automatically maintains reverse links
# SRD-001 knows SWD-001 is a child
```

#### Traceability Matrix

**Generated automatically:**
```bash
trudag report export --output artifacts/traceability.zip
```

**Contains:**
```csv
req_id,header,type,parent_links,child_links,verification,reviewed
URD-001,Display speed,URD,[],[SRD-001],UAT,abc123
SRD-001,HMI speed,SRD,[URD-001],[SWD-001],System Test,def456
SWD-001,Qt widget,SWD,[SRD-001],[LLTC-001],Unit Test,ghi789
LLTC-001,Test widget,LLTC,[SWD-001],[],Unit Test,jkl012
```

#### Coverage Gaps

**Example gap:**
```
URD-002: "Display battery voltage"
  ↓ (no SRD!)
  Missing system requirement
```

**Detection:**
```bash
trudag report export
# Check report for:
# - Requirements with no children
# - Requirements with no tests
# - Orphaned requirements
```

---

### Module 5: Verification & Validation (20 min)

#### V&V Strategy by ASIL

**ASIL A:**
```
Requirement → Unit Test → Review → Approve
```

**ASIL B:**
```
Requirement → Unit Test → Integration Test →
Design Review → Static Analysis → Approve
```

**ASIL C:**
```
Requirement → Unit Test → Integration Test →
System Test → Coverage Report → Independent Review → Approve
```

#### Test Levels

**Unit Tests:**
- Test individual functions/modules
- Mock dependencies
- Fast execution
- Example: Test Qt widget rendering

**Integration Tests:**
- Test component interactions
- Real or stubbed dependencies
- Medium execution time
- Example: Test HMI + CAN bus integration

**System Tests:**
- Test complete system
- Real hardware/environment
- Slow execution
- Example: Test speed display on actual vehicle

#### Evidence Collection

**Store in:** `artifacts/verification/`

**Structure:**
```
artifacts/verification/
├── tests/
│   ├── LLTC-001-junit.xml     # Unit test results
│   └── LLTC-002-integration.xml
├── reviews/
│   ├── SWD-001-review.md      # Review notes
│   └── SRD-005-signoff.pdf
└── coverage/
    └── coverage-report.html    # Code coverage
```

**Link from requirement:**
```yaml
SWD-001:
  artifact:
    - type: test
      path: artifacts/verification/tests/LLTC-001-junit.xml
    - type: review
      path: artifacts/verification/reviews/SWD-001-review.md
```

---

### Module 6: Documentation (10 min)

#### Required Documentation

**Per Requirement:**
- YAML file with mandatory fields
- Traceability links
- Acceptance criteria
- Review evidence

**Per Sprint:**
- Traceability matrix
- Coverage report
- Verification summary

**Per Baseline:**
- Trustable report (ZIP)
- All verification artifacts
- Release notes

#### Baseline Process

**When to Baseline:**
- End of sprint
- Before major changes
- Release preparation

**Steps:**
1. Validate all requirements
2. Generate traceability report
3. Create git tag
4. Archive artifacts
5. Document coverage

**Evidence:**
```
BASELINE-V1.0/
├── trustable-report.zip
├── traceability-matrix.csv
├── verification-artifacts.tar.gz
└── release-notes.md
```

---

### Module 7: Hands-On Lab (60 min)

#### Lab Objective

Create a complete V-Model requirement chain with evidence.

#### Lab Scenario

**Feature:** Display battery voltage on HMI

**Requirements:**
1. URD: User needs to see battery voltage
2. SRD: System displays voltage with accuracy
3. SWD: Software reads ADC and updates Qt widget
4. LLTC: Test voltage display accuracy and timing

#### Lab Steps

**Step 1: Create URD (10 min)**

```bash
# Create user requirement
doorstop add URD

# Edit URD-002
doorstop edit URD-002
```

```yaml
URD-002:
  ref: URD-002
  header: "Display battery voltage"
  text: "The user SHALL be able to view the current battery voltage on the main dashboard to monitor battery health"
  ASIL: A
  Verification Method: User Acceptance Test
  links: []
  reviewers:
    - name: "Your Name"
      email: "you@example.com"
  reviewed: ''
  acceptance:
    - GIVEN: battery connected and system powered
      WHEN: user views main dashboard
      THEN: battery voltage SHALL be visible with unit (V)
```

```bash
# Validate
trudag manage lint
doorstop
```

**Step 2: Create SRD (10 min)**

```bash
doorstop add SRD
doorstop edit SRD-002
doorstop link SRD-002 URD-002
```

```yaml
SRD-002:
  ref: SRD-002
  header: "HMI battery voltage display"
  text: "The system SHALL display battery voltage on the HMI with accuracy ±0.1V, sampled at 1 Hz"
  ASIL: A
  Verification Method: System Test
  links: [URD-002]
  reviewers:
    - name: "Your Name"
      email: "you@example.com"
  reviewed: ''
  acceptance:
    - GIVEN: battery voltage is 12.0V
      WHEN: system reads voltage
      THEN: display SHALL show 12.0V ±0.1V within 1 second
```

**Step 3: Create SWD (10 min)**

```bash
doorstop add SWD
doorstop edit SWD-002
doorstop link SWD-002 SRD-002
```

```yaml
SWD-002:
  ref: SWD-002
  header: "Battery voltage ADC reader"
  text: "The software SHALL read battery voltage via ADC channel 0 with 12-bit resolution at 1 Hz and update Qt BatteryWidget"
  ASIL: A
  Verification Method: Unit Test
  links: [SRD-002]
  reviewers:
    - name: "Your Name"
      email: "you@example.com"
  reviewed: ''
  acceptance:
    - GIVEN: ADC configured for channel 0
      WHEN: readVoltage() called
      THEN: SHALL return voltage as float within 100ms
```

**Step 4: Create LLTC (10 min)**

```bash
doorstop add LLTC
doorstop edit LLTC-002
doorstop link LLTC-002 SWD-002
```

```yaml
LLTC-002:
  ref: LLTC-002
  header: "Test battery voltage reader"
  text: "Test SHALL verify battery voltage reader accuracy and timing"
  ASIL: A
  Verification Method: Unit Test
  links: [SWD-002]
  reviewers:
    - name: "Your Name"
      email: "you@example.com"
  reviewed: ''
  test_procedure:
    setup:
      - Mock ADC with known voltage (12.0V)
      - Initialize BatteryVoltageReader
    test_steps:
      - step: 1
        action: Call readVoltage()
        expected: Returns 12.0 ±0.1V
      - step: 2
        action: Measure execution time
        expected: Completes in <100ms
```

**Step 5: Validate Chain (5 min)**

```bash
# Validate all requirements
trudag manage lint
doorstop

# Should show:
# URD-002 → SRD-002 → SWD-002 → LLTC-002 (complete chain)
```

**Step 6: Generate Traceability (5 min)**

```bash
# Update structure
trudag manage migrate

# Export report
trudag report export --output artifacts/lab-report.zip

# Extract and view
cd artifacts/
unzip lab-report.zip -d lab-report/
cd lab-report/
cat matrix.csv
```

**Step 7: Mark Reviewed (5 min)**

```bash
# Get current SHA
git rev-parse HEAD

# Approve URD-002
trudag manage set-item reqs/urd/URD-002.yml

# Repeat for others
trudag manage set-item reqs/srd/SRD-002.yml
trudag manage set-item reqs/swd/SWD-002.yml
trudag manage set-item reqs/lltc/LLTC-002.yml
```

**Step 8: Commit Lab Work (5 min)**

```bash
git add reqs/
git commit -m "lab: Complete TSF training lab

Created full V-Model chain:
- URD-002: User requirement (battery voltage)
- SRD-002: System requirement (HMI display)
- SWD-002: Software requirement (ADC reader)
- LLTC-002: Test case (verify accuracy)

Traceability: 100%
Validation: Passed"

git push
```

#### Lab Success Criteria

- [ ] All 4 requirements created (URD, SRD, SWD, LLTC)
- [ ] All links valid (child → parent)
- [ ] `trudag manage lint` passes
- [ ] `doorstop` passes
- [ ] Traceability matrix shows complete chain
- [ ] All requirements marked reviewed
- [ ] Work committed to git

---

## 📊 Training Assessment

### Quiz (20 questions)

See `docs/archive/TSF-quiz.md` for full quiz.

**Key Questions:**
1. What are the 3 components of a Trustable Graph?
2. What does ASIL stand for?
3. How do you link a child requirement to parent?
4. What command validates requirements?
5. What field proves a requirement is reviewed?

**Passing Score:** 16/20 (80%)

### Practical Assessment

**Task:** Create a new feature requirement chain

1. URD: "Display engine temperature"
2. SRD: "HMI shows temperature ±1°C"
3. SWD: "Read CAN message ID 0x101"
4. LLTC: "Test temperature display"

**Time Limit:** 30 minutes

**Must:**
- Pass validation
- Complete traceability
- Mark reviewed
- Generate report

---

## 📚 Additional Resources

### Official Documentation
- Trustable: https://codethinklabs.gitlab.io/trustable/trustable/
- Doorstop: https://doorstop.readthedocs.io/
- ISO 26262: https://www.iso.org/standard/68383.html

### Team Resources
- Quick Reference: `docs/tsf/reference.md`
- Workflows: `docs/tsf/workflow.md`
- Evidence Guide: `docs/tsf/evidence.md`

---

## ✅ Training Completion

After completing this training, you should be able to:

- [x] Explain TSF principles
- [x] Determine appropriate ASIL levels
- [x] Write SMART requirements
- [x] Create V-Model traceability
- [x] Use trudag and doorstop
- [x] Generate evidence
- [x] Create baselines


---

**Next Steps:**
1. Review `docs/tsf/workflow.md` for daily tasks
2. Start contributing to real requirements
3. Participate in weekly traceability reviews
4. Mentor new team members

**Questions?** Ask in team standup or review documentation.

---

**Last Updated:** October 2025
**Maintained By:** DrivaPi Team
