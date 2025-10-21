# TSF Quick Reference Card

**Version:** 4.0 (trudag-only)
**Last Updated:** October 2025

---

## 🎯 Core Principle

**Trust = Evidence**

Every claim must be backed by verifiable artifacts stored in git.

---

## 📊 V-Model Structure

```
URD (User)      ← WHAT users need (Expectations)
  ↑ links
SRD (System)    ← HOW system provides (Assertions)
  ↑ links
SWD (Software)  ← HOW software implements (Assertions)
  ↑ links
LLTC (Tests)    ← HOW to verify (Premises)
```

**Rule:** Child always links UP to parent via `trudag manage create-link`

---

## 🛠️ Essential Commands

### Setup & Initialization

```bash
# Activate environment (ALWAYS FIRST)
source .venv/bin/activate

# Initialize new TSF project (only once)
trudag --init

# Install/update trudag
cd /tmp/trustable
git checkout 2025.9.16
pip install .
```

### Daily Validation

```bash
# Validate all requirements
trudag manage lint

# Calculate trust scores
trudag score

# Both should run clean before commits!
```

### Create Requirements

```bash
# Create new requirement
trudag manage create-item <TYPE> <NUMBER> reqs/<type>

# Examples:
trudag manage create-item URD 042 reqs/urd   # Creates reqs/urd/URD-042.md
trudag manage create-item SRD 015 reqs/srd   # Creates reqs/srd/SRD-015.md
trudag manage create-item SWD 123 reqs/swd   # Creates reqs/swd/SWD-123.md
trudag manage create-item LLTC 001 reqs/lltc # Creates reqs/lltc/LLTC-001.md

# This command:
# - Creates markdown file with frontmatter
# - Updates .dotstop.dot
# - Uses next available number if exists
```

### Link Requirements (Traceability)

```bash
# Link child → parent
trudag manage create-link <CHILD-ID> <PARENT-ID>

# Examples:
trudag manage create-link SRD-015 URD-042   # SRD implements URD
trudag manage create-link SWD-123 SRD-015   # SWD implements SRD
trudag manage create-link LLTC-001 SWD-123  # Test verifies SWD

# Always flows UPWARD in V-Model
```

### Review & Approve

```bash
# Mark requirement as reviewed
trudag manage set-item <ID>

# Examples:
trudag manage set-item URD-042
trudag manage set-item SRD-015

# This updates 'reviewed:' field with:
# - Current date
# - Reviewer name (from git config)
# - Git commit SHA (immutable proof)
```

### Generate Reports

```bash
# Calculate scores
trudag score

# Generate HTML/Markdown report
trudag publish --output-dir artifacts/trustable-report

# With validation (if custom validators configured)
trudag publish --validate --output-dir artifacts/trustable-report

# View report
open artifacts/trustable-report/dashboard.md
```

### Baselines

```bash
# Create baseline tag
git tag -a BASELINE-V1.0 -m "Sprint 1 baseline"

# Archive report
tar -czf artifacts/baselines/v1.0.tar.gz artifacts/trustable-report/

# Push tag
git push origin BASELINE-V1.0
```

---

## 📝 Markdown File Format

### Minimal Required Structure

```markdown
---
normative: true
level: 1.0
ASIL: B
verification_method: "Unit Test"
reviewers:
  - name: "Your Name"
    email: "you@example.com"
reviewed: ''  # Empty until approved
active: true
derived: false
---
The system SHALL do something specific and testable with clear
acceptance criteria and measurable outcomes.
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `normative` | bool | ✅ Yes | True for requirements, false for notes |
| `level` | float | ✅ Yes | V-Model level (1.0=URD, 2.0=SRD, 3.0=SWD, 4.0=LLTC) |
| `ASIL` | string | ✅ Yes | A/B/C/D/QM (safety level) |
| `verification_method` | string | ✅ Yes | How to verify (e.g., "Unit Test") |
| `reviewers` | list | ✅ Yes | At least one reviewer |
| `reviewed` | string | ✅ Yes | Empty '' until approved |
| `active` | bool | ✅ Yes | True unless deprecated |
| `derived` | bool | ✅ Yes | False unless derived from external source |

### Optional (Recommended) Fields

```markdown
---
# ... required fields ...

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
    description: Unit test implementation
  - type: design
    path: docs/design/architecture.md
    description: Architecture diagram
---
```

---

## 🏷️ ASIL Quick Guide

### ASIL Levels (ISO 26262)

| ASIL | Risk | Examples | Verification Required |
|------|------|----------|----------------------|
| **QM** | None | Radio, themes | Basic review |
| **A** | Low | Rear lights | + Unit tests |
| **B** | Low-Med | Brake lights | + Integration tests + 2 reviewers |
| **C** | Medium | ABS, ESC | + System tests + coverage + independent review |
| **D** | High | Airbags | + HIL + formal sign-off |

### Determining ASIL

**Formula:** Severity × Exposure × Controllability

**Example: Speed Display Failure**
- Severity: S2 (minor injury possible)
- Exposure: E4 (high frequency)
- Controllability: C2 (normally controllable)
- **Result: ASIL B** ✅

### DrivaPi Typical Assignments

```
Display UI features    → ASIL A (QM if non-critical)
Sensor processing      → ASIL B
Motor control          → ASIL B
Emergency stop         → ASIL C
Logs/configuration     → QM
```

---

## ✅ Requirement Quality Checklist

### DO:
- ✅ Use "SHALL" for mandatory requirements
- ✅ Be specific (include units, timing, ranges)
- ✅ Make testable (clear pass/fail criteria)
- ✅ Link to parent requirement
- ✅ Include acceptance criteria
- ✅ One requirement = one testable thing

### DON'T:
- ❌ Use "should", "may", "might" (ambiguous)
- ❌ Use "etc.", "and/or" (incomplete)
- ❌ Combine multiple requirements
- ❌ Use negative statements ("shall not fail")
- ❌ Leave units unspecified ("fast", "soon")
- ❌ Forget to link to parent

### Good Example:

```markdown
---
normative: true
level: 3.0
ASIL: B
verification_method: "Unit Test"
# ... other fields ...
---
The software SHALL convert raw CAN speed data (received in 0.1 km/h units)
to integer km/h format and update the HMI display module within 50
milliseconds of CAN message receipt.

acceptance:
  - GIVEN: CAN message with speed value 1234 (123.4 km/h)
    WHEN: Message received by speed processing module
    THEN: Display updated to show "123 km/h" within 50ms
```

### Bad Example:

```markdown
The system should display speed nicely and update it quickly.
```

**Why it's bad:**
- "should" instead of "SHALL"
- "nicely" is not measurable
- "quickly" has no timing constraint
- No acceptance criteria
- Not testable

---

## 🔗 Traceability Rules

### Valid Links

```
✅ LLTC-001 links to SWD-042    (Test → Design)
✅ SWD-042 links to SRD-015     (Design → System)
✅ SRD-015 links to URD-001     (System → User)
```

### Invalid Links

```
❌ URD-001 links to SRD-015     (Parent → Child = backwards!)
❌ SWD-042 links to SWD-043     (Sibling = no V-Model flow)
❌ LLTC-001 links to URD-001    (Skips levels = breaks chain)
```

### Multiple Parents

```
✅ SWD-042 can link to SRD-015 AND SRD-016
   (One design can satisfy multiple system requirements)
```

---

## 🐛 Common Errors & Fixes

### "YAML syntax error"

```bash
# Check frontmatter
head -20 reqs/swd/SWD-042.md

# Ensure:
# - Opening --- exists
# - Closing --- exists
# - Proper indentation (2 spaces)
# - Quoted strings with special chars
```

### "Missing required field"

```bash
# Add to frontmatter:
---
normative: true    # Required
level: 3.0         # Required
---
```

### "Requirement not in .dotstop.dot"

```bash
# Re-create using trudag
trudag manage create-item SWD 042 reqs/swd
```

### "Broken link: parent not found"

```bash
# Create parent first
trudag manage create-item SRD 015 reqs/srd

# Then link
trudag manage create-link SWD-042 SRD-015
```

---

## 📦 File Structure

```
Team04_DrivaPi/
├── .dotstop.dot              # Graph structure (managed by trudag)
├── .dotstop_extensions/      # Custom validators
├── reqs/
│   ├── urd/
│   │   ├── URD-001.md
│   │   └── URD-042.md
│   ├── srd/
│   │   ├── SRD-001.md
│   │   └── SRD-015.md
│   ├── swd/
│   │   ├── SWD-001.md
│   │   └── SWD-042.md
│   ├── lltc/
│   │   └── LLTC-001.md
│   └── templates/
│       ├── URD-template.yml
│       ├── SRD-template.yml
│       ├── SWD-template.yml
│       └── LLTC-template.yml
├── artifacts/
│   ├── trustable-report/     # Generated reports
│   └── baselines/            # Archived baselines
└── docs/
    └── tsf/                  # This documentation
```

---

## 🔄 Typical Workflow

```bash
# 1. Create requirement
trudag manage create-item SWD 042 reqs/swd

# 2. Edit file
nano reqs/swd/SWD-042.md

# 3. Link to parent
trudag manage create-link SWD-042 SRD-015

# 4. Validate
trudag manage lint

# 5. Commit
git add reqs/swd/SWD-042.md .dotstop.dot
git commit -m "feat(swd): Add SWD-042"

# 6. Create PR & get reviews

# 7. Approve
trudag manage set-item SWD-042

# 8. Merge PR

# 9. Generate report
trudag publish --output-dir artifacts/trustable-report
```

---

## 💡 Pro Tips

1. **Always activate venv first:** `source .venv/bin/activate`
2. **Run `trudag manage lint` before commits** - catch errors early
3. **Use templates** from `reqs/templates/` as starting point
4. **Link as you create** - don't wait until the end
5. **Review in small batches** - easier than bulk review later
6. **Tag baselines frequently** - creates audit trail
7. **Keep .dotstop.dot in git** - tracks traceability history

---

## 📞 Getting Help

- **Validation errors:** Run `trudag manage lint` and read error message
- **Workflows:** See `docs/tsf/workflow.md`
- **Training:** See `docs/tsf/training.md`
- **Evidence:** See `docs/tsf/evidence.md`

---

**Remember:** TSF is about building trust through evidence. Every requirement, link, and review is tracked in git for complete traceability.
