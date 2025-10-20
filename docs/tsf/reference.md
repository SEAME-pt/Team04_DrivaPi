# TSF Quick Reference Card

**Version:** 3.0
**Last Updated:** October 2025

---

## 🎯 Core Principle

**Trust = Evidence**

Every claim must be backed by verifiable artifacts.

---

## 📊 V-Model Structure

```
URD (User)      ← WHAT users need
  ↓ links
SRD (System)    ← HOW system provides
  ↓ links
SWD (Software)  ← HOW software implements
  ↓ links
LLTC (Tests)    ← HOW to verify
```

**Rule:** Child always links to parent via `links:` field

---

## 🛠️ Essential Commands

### Daily Validation
```bash
# Activate environment
source .venv/bin/activate

# Validate requirements
trudag manage lint

# Check links
doorstop

# Update structure
trudag manage migrate
```

### Create Requirements
```bash
# Interactive (RECOMMENDED)
doorstop add URD
doorstop edit URD-042

# Manual
cp reqs/templates/URD-template.yml reqs/urd/URD-042.yml
nano reqs/urd/URD-042.yml
```

### Link Requirements
```bash
# Link child → parent
doorstop link SWD-042 SRD-015

# Verify link
doorstop
```

### Review & Approve
```bash
# Validate first
trudag manage lint

# Mark as reviewed (updates 'reviewed:' field)
trudag manage set-item reqs/swd/SWD-042.yml

# Commit approval
git add reqs/swd/SWD-042.yml
git commit -m "review: Approve SWD-042"
```

### Generate Reports
```bash
# Traceability matrix
trudag report export --output artifacts/trace-$(date +%Y%m%d).zip

# HTML report
doorstop publish all docs/report/
```

### Baselines
```bash
# Create baseline tag
git tag -a BASELINE-V1.0 -m "Sprint 1 baseline"

# Export Trustable report
trudag report export --output artifacts/baselines/v1.0.zip

# Push tag
git push origin BASELINE-V1.0
```

---

## 📝 YAML Template

### Minimal Required Structure

```yaml
ID-042:                         # Top-level ID
  ref: ID-042                   # MUST match filename & top-level
  header: "Short title"         # One-line description
  text: |                       # Requirement text
    The system SHALL do X.

  ASIL: B                       # A/B/C/D/QM
  Verification Method: Unit Test

  links: [PARENT-ID]            # Traceability ([] if URD)

  reviewers:                    # At least 1 required
    - name: "Full Name"
      email: "user@example.com"

  reviewed: ''                  # Empty until approved

  active: true                  # Standard fields
  derived: false
  normative: true
  level: 1.0
```

### Optional (Recommended) Fields

```yaml
  # Acceptance criteria (HIGHLY RECOMMENDED)
  acceptance:
    - GIVEN: initial condition
      WHEN: trigger occurs
      THEN: expected result

  # Rationale
  rationale: "Why this requirement exists"

  # Assumptions
  assumptions:
    - "Hardware capability X"
    - "Operating environment Y"

  # Evidence links
  artifact:
    - type: test
      path: tests/test_feature.cpp
    - type: design
      path: docs/design.md
```

---

## 🏷️ ASIL Quick Guide

### ASIL Levels

| ASIL | Risk | Examples | Verification |
|------|------|----------|--------------|
| **QM** | None | Radio, themes | Basic review |
| **A** | Low | Rear lights | + Unit tests |
| **B** | Low-Med | Brake lights | + Integration tests + 2 reviewers |
| **C** | Medium | ABS, ESC | + System tests + coverage + independent review |
| **D** | High | Airbags | + HIL + formal sign-off |

### Determining ASIL

**Formula:** Severity × Exposure × Controllability

**Example: Speed Display Failure**
- Severity: S2 (minor injury possible)
- Exposure: E4 (high)
- Controllability: C2 (normally controllable)
- **Result: ASIL B**

### DrivaPi Typical Assignments

```
Display features      → ASIL A
Sensor processing     → ASIL B
Motor control         → ASIL B
Emergency stop        → ASIL C
Configuration/logs    → QM
```

---

## ✅ Requirement Quality Checklist

### DO:
- ✅ Use "SHALL" for mandatory requirements
- ✅ Be specific (include units, timing, ranges)
- ✅ Make testable (clear pass/fail)
- ✅ Link to parent requirement
- ✅ Include acceptance criteria
- ✅ Specify ASIL level

### DON'T:
- ❌ Use vague words ("quickly", "approximately", "fast")
- ❌ Combine multiple requirements
- ❌ Forget units (km/h, ms, °C, etc.)
- ❌ Use "should" or "may" (use "SHALL")
- ❌ Make untestable claims
- ❌ Leave `reviewed:` field as 'approved' (use git SHA)

### Examples

#### ❌ BAD
```yaml
text: "System shows speed fast"
```

**Problems:**
- No "SHALL"
- "fast" is vague
- No units
- Not testable

#### ✅ GOOD
```yaml
text: "The system SHALL display vehicle speed in km/h with accuracy ±1 km/h, updated every 100ms"

acceptance:
  - GIVEN: vehicle speed is 50 km/h
    WHEN: speed changes to 60 km/h
    THEN: display SHALL show 60 ±1 km/h within 100ms
```

**Why it's good:**
- Uses "SHALL"
- Specific units (km/h, ms)
- Testable accuracy (±1 km/h)
- Clear timing (100ms)
- Acceptance criteria

---

## 🔗 Traceability Rules

### Forward Traceability
```
URD-001 (User need)
  ↓ links
SRD-001 (System design)
  ↓ links
SWD-001 (Software implementation)
  ↓ links
LLTC-001 (Test case)
```

### Bidirectional (Automatic)
```yaml
# Child explicitly links parent
SWD-001:
  links: [SRD-001]

# Doorstop automatically maintains:
# SRD-001 knows SWD-001 is a child
```

### Verification

```bash
# Generate matrix
trudag report export --output artifacts/trace.zip

# Check for gaps:
# - Requirements with no children
# - Requirements with no tests
# - Broken links
```

---

## 🚨 Common Errors & Fixes

### Error: "ref does not match filename"
```
reqs/swd/SWD-042.yml: ref is 'SWD-041'
```

**Fix:**
```yaml
# Change both places:
SWD-042:           # Top-level ID
  ref: SWD-042     # ref field
```

### Error: "Missing required field: reviewers"
```yaml
# Add:
reviewers:
  - name: "Your Name"
    email: "you@example.com"
```

### Error: "Parent link not found: SRD-999"
```bash
# Option 1: Create parent first
doorstop add SRD
doorstop edit SRD-999

# Option 2: Remove invalid link
# Change: links: [SRD-999]
# To:     links: []
```

### Error: "reviewed field invalid"
```yaml
# WRONG:
reviewed: 'approved'
reviewed: 'yes'

# CORRECT:
reviewed: ''                    # Not reviewed yet
reviewed: 'abc123def456...'     # Git SHA (40 chars)
```

---

## 📂 File Locations

### Requirements
```
reqs/
├── urd/URD-*.yml       User Requirements
├── srd/SRD-*.yml       System Requirements
├── swd/SWD-*.yml       Software Requirements
└── lltc/LLTC-*.yml     Test Cases
```

### Templates
```
reqs/templates/
├── URD-template.yml
├── SRD-template.yml
├── SWD-template.yml
└── LLTC-template.yml
```

### Artifacts
```
artifacts/
├── traceability/       Auto-generated reports
├── baselines/          Git tags + archives
└── verification/       Test results, reviews
```

---

## 🔄 Git Workflow

### Feature Branch
```bash
# Create branch
git checkout -b feature/swd-042

# Create requirement
doorstop add SWD
doorstop edit SWD-042

# Validate
trudag manage lint

# Commit
git add reqs/swd/SWD-042.yml
git commit -m "feat(swd): Add SWD-042 temperature monitoring"

# Push
git push origin feature/swd-042

# Create PR (2 reviewers for ASIL B+)
```

### Review Branch
```bash
# Pull branch
git checkout feature/swd-042
git pull

# Validate
trudag manage lint
doorstop

# Approve
trudag manage set-item reqs/swd/SWD-042.yml

# Commit
git add reqs/swd/SWD-042.yml
git commit -m "review: Approve SWD-042"
git push
```

---

## 📋 Checklists

### Creating Requirement
- [ ] Filename matches ID (SWD-042.yml)
- [ ] `ref:` matches filename
- [ ] Header is descriptive
- [ ] Text uses "SHALL"
- [ ] ASIL level assigned
- [ ] Verification method specified
- [ ] Links to parent (if not URD)
- [ ] Reviewers added
- [ ] `reviewed:` is empty
- [ ] Acceptance criteria present
- [ ] `trudag manage lint` passes
- [ ] `doorstop` passes

### Reviewing Requirement
- [ ] Content is clear and unambiguous
- [ ] Requirement is testable
- [ ] ASIL level appropriate
- [ ] Parent link valid
- [ ] Units/timing specified
- [ ] No vague words
- [ ] Acceptance criteria complete
- [ ] `trudag manage lint` passes
- [ ] Approved with `trudag manage set-item`
- [ ] Commit message includes reviewer

### Creating Baseline
- [ ] All requirements reviewed
- [ ] No validation errors
- [ ] Complete traceability
- [ ] Git tag created
- [ ] Trustable report exported
- [ ] Artifacts archived
- [ ] Tag pushed to GitHub
- [ ] Release notes written

---

## 🆘 Help Resources

### Documentation

- **Trustable:** https://codethinklabs.gitlab.io/trustable/trustable/
- **Doorstop:** https://doorstop.readthedocs.io/
- **ISO 26262:** https://www.iso.org/standard/68383.html

---

## 🎯 One-Page Cheat Sheet

```bash
# SETUP
source .venv/bin/activate

# CREATE
doorstop add SWD
doorstop edit SWD-042
doorstop link SWD-042 SRD-015

# VALIDATE
trudag manage lint
doorstop

# APPROVE
trudag manage set-item reqs/swd/SWD-042.yml

# REPORT
trudag report export --output artifacts/report.zip

# BASELINE
git tag -a BASELINE-V1.0 -m "Baseline v1.0"
trudag report export --output artifacts/baselines/v1.0.zip
git push origin BASELINE-V1.0
```

**Requirement must have:**
- `ref:` = filename = top-level ID
- `header`, `text` (with SHALL)
- `ASIL`, `Verification Method`
- `links: [PARENT]`
- `reviewers:` (name + email)
- `reviewed: ''` (until approved)

**ASIL:**
- QM = no safety
- A = low risk (1 reviewer, unit tests)
- B = medium risk (2 reviewers, integration tests)
- C/D = high risk (independent review, system tests)

---

**Last Updated:** October 2025
**Version:** 3.0
