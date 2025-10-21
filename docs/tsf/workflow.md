# TSF Workflow Guide

**Version:** 3.0
**Last Updated:** October 2025

---

## 🎯 Core Principle

**Use trudag commands only**

**File Format:** Requirements are `.md` files with YAML frontmatter

---

## 📂 Repository Structure (Current)

```
Team04_DrivaPi/
├── reqs/
│   ├── urd/                    # User Requirements
│   │   └── URD-001.md
│   ├── srd/                    # System Requirements
│   │   └── SRD-001.md
│   ├── swd/                    # Software Requirements
│   │   └── SWD-001.md
│   ├── lltc/                   # Test Cases
│   │   └── LLTC-001.md
│   └── templates/              # Templates
│       ├── URD-template.yml
│       ├── SRD-template.yml
│       ├── SWD-template.yml
│       └── LLTC-template.yml
│
├── artifacts/
│   ├── trudag-lint.json        # Validation output
│   ├── trudag-lint.txt
│   └── trustable-report/       # Generated reports
│       ├── URD.md
│       ├── SRD.md
│       ├── SWD.md
│       ├── LLTC.md
│       └── trustable_report_for_Software.md
│
└── docs/
    └── tsf/                    # TSF documentation
```

---

## ✅ Correct Workflow

### Workflow 1: Initialize Project (One Time)

```bash
# Initialize trudag in your repo
cd Team04_DrivaPi
trudag --init -n "DrivaPi Requirements"

# This creates the necessary structure
```

---

### Workflow 2: Create a New Requirement

#### Step 1: Create the requirement file

```bash
# Create URD requirement
trudag manage create-item URD 001 reqs/urd

# Create SRD requirement
trudag manage create-item SRD 001 reqs/srd

# Create SWD requirement
trudag manage create-item SWD 001 reqs/swd

# Create LLTC test case
trudag manage create-item LLTC 001 reqs/lltc
```

**This creates:** `reqs/urd/URD-001.md` (and similar for others)

#### Step 2: Edit the requirement file

**File format:** Markdown with YAML frontmatter

```bash
# Edit with your favorite editor
nano reqs/urd/URD-001.md
# or
code reqs/urd/URD-001.md
```

**Correct file structure:**

```markdown
---
ref: URD-001
header: "Display vehicle speed"
text: |
  The user SHALL be able to view current vehicle speed on the dashboard

ASIL: B
Verification Method: User Acceptance Test

links: []

reviewers:
  - name: "Your Name"
    email: "you@example.com"

reviewed: ''

active: true
derived: false
normative: true
level: 1.0
---

# URD-001: Display vehicle speed

## Description

The user needs to see the current vehicle speed while driving.

## Rationale

Speed awareness is critical for safe driving and legal compliance.

## Acceptance Criteria

- GIVEN: vehicle is moving
- WHEN: user views dashboard
- THEN: current speed SHALL be displayed in km/h ±1 km/h

## Assumptions

- Dashboard display is functional
- Speed sensor provides accurate data
```

---

### Workflow 3: Create Links (Traceability)

```bash
# Link SWD-001 to its parent SRD-001
trudag manage create-link SWD-001 SRD-001

# Link LLTC-001 to its parent SWD-001
trudag manage create-link LLTC-001 SWD-001

# Link SRD-001 to its parent URD-001
trudag manage create-link SRD-001 URD-001
```

**What this does:**
- Updates the `links:` field in the YAML frontmatter
- Creates the DAG structure
- Enables traceability

**Example result in SWD-001.md:**

```markdown
---
ref: SWD-001
header: "Qt speed widget implementation"
text: |
  The software SHALL implement a Qt widget...

links:
  - SRD-001    # ← Added by trudag manage create-link

# ... rest of fields
---
```

---

### Workflow 4: Validate Requirements

```bash
# Validate all requirements (most important command!)
trudag manage lint

# Check for errors
# Expected output: No errors, or list of issues to fix
```

**Common errors:**
- Missing `ref:` field
- `ref:` doesn't match filename
- Invalid YAML syntax
- Broken links (parent doesn't exist)

**Fix and re-run** until `trudag manage lint` passes cleanly.

---

### Workflow 5: Mark as Reviewed (Approve)

```bash
# After review, mark items as reviewed
trudag manage set-item URD-001
trudag manage set-item SRD-001
trudag manage set-item SWD-001
trudag manage set-item LLTC-001
```

**What this does:**
- Updates `reviewed:` field with git commit SHA
- Marks the requirement as approved
- Records who approved and when

**Result in file:**

```markdown
---
ref: URD-001
# ... other fields ...
reviewed: 'abc123def456...'  # ← Git SHA added
---
```

---

### Workflow 6: Generate Reports

```bash
# Score the requirements (calculate confidence)
trudag score

# Publish HTML reports
trudag publish --output-dir artifacts/trustable-report

# Or just validate
trudag manage lint
```

**Generated files:**
```
artifacts/trustable-report/
├── URD.md                           # All URD requirements
├── SRD.md                           # All SRD requirements
├── SWD.md                           # All SWD requirements
├── LLTC.md                          # All test cases
├── dashboard.md                     # Summary dashboard
├── trustable_report_for_Software.md # Full report
└── figs/                            # Graphs and charts
    ├── all_hist.svg
    ├── evidence_hist.svg
    └── expectations_hist.svg
```

---

## 🔄 Complete Example: Battery Voltage Feature

### Step 1: Create all requirement files

```bash
# Create URD
trudag manage create-item URD 002 reqs/urd

# Create SRD
trudag manage create-item SRD 002 reqs/srd

# Create SWD
trudag manage create-item SWD 002 reqs/swd

# Create LLTC
trudag manage create-item LLTC 002 reqs/lltc
```

### Step 2: Edit URD-002.md

```bash
nano reqs/urd/URD-002.md
```

```markdown
---
ref: URD-002
header: "Display battery voltage"
text: |
  The user SHALL be able to view current battery voltage on the main dashboard
  to monitor battery health

ASIL: A
Verification Method: User Acceptance Test

links: []

reviewers:
  - name: "Your Name"
    email: "you@example.com"

reviewed: ''

active: true
derived: false
normative: true
level: 1.0
---

# URD-002: Display Battery Voltage

## Description

Users need to monitor battery voltage to ensure sufficient power and prevent
unexpected shutdowns.

## Acceptance Criteria

- GIVEN: battery connected and system powered
- WHEN: user views main dashboard
- THEN: battery voltage SHALL be visible with unit (V)

## Assumptions

- Battery voltage sensor is available
- Display has sufficient resolution
```

### Step 3: Edit SRD-002.md

```bash
nano reqs/srd/SRD-002.md
```

```markdown
---
ref: SRD-002
header: "HMI battery voltage display"
text: |
  The system SHALL display battery voltage on HMI with accuracy ±0.1V,
  sampled at 1 Hz

ASIL: A
Verification Method: System Test

links: []  # Will be updated by trudag manage create-link

reviewers:
  - name: "Your Name"
    email: "you@example.com"

reviewed: ''

active: true
derived: false
normative: true
level: 1.0
---

# SRD-002: HMI Battery Voltage Display

## Description

System-level requirement for displaying battery voltage on the HMI.

## Acceptance Criteria

- GIVEN: battery voltage is 12.0V
- WHEN: system reads voltage
- THEN: display SHALL show 12.0V ±0.1V within 1 second
```

### Step 4: Edit SWD-002.md

```bash
nano reqs/swd/SWD-002.md
```

```markdown
---
ref: SWD-002
header: "Battery voltage ADC reader"
text: |
  The software SHALL read battery voltage via ADC channel 0 with 12-bit
  resolution at 1 Hz and update Qt BatteryWidget

ASIL: A
Verification Method: Unit Test

links: []  # Will be updated

reviewers:
  - name: "Your Name"
    email: "you@example.com"

reviewed: ''

active: true
derived: false
normative: true
level: 1.0
---

# SWD-002: Battery Voltage ADC Reader

## Implementation

Software reads ADC channel 0, converts to voltage, updates widget.

## Acceptance Criteria

- GIVEN: ADC configured for channel 0
- WHEN: readVoltage() called
- THEN: SHALL return voltage as float within 100ms
```

### Step 5: Edit LLTC-002.md

```bash
nano reqs/lltc/LLTC-002.md
```

```markdown
---
ref: LLTC-002
header: "Test battery voltage reader"
text: |
  Test SHALL verify battery voltage reader accuracy and timing

ASIL: A
Verification Method: Unit Test

links: []  # Will be updated

reviewers:
  - name: "Your Name"
    email: "you@example.com"

reviewed: ''

active: true
derived: false
normative: true
level: 1.0
---

# LLTC-002: Test Battery Voltage Reader

## Test Procedure

1. Mock ADC with known voltage (12.0V)
2. Call readVoltage()
3. Verify returns 12.0V ±0.1V
4. Verify completes in <100ms

## Test Implementation

```cpp
TEST(BatteryReader, ReadAccuracy) {
    MockADC adc;
    adc.setVoltage(12.0);

    BatteryReader reader(&adc);
    float voltage = reader.readVoltage();

    EXPECT_NEAR(voltage, 12.0, 0.1);
}
```

## Evidence

- Test code: `tests/unit/test_battery_reader.cpp`
- Test results: `artifacts/verification/tests/LLTC-002-junit.xml`
```

### Step 6: Create all links

```bash
# Build the traceability chain
trudag manage create-link SRD-002 URD-002
trudag manage create-link SWD-002 SRD-002
trudag manage create-link LLTC-002 SWD-002
```

**Result:** Creates full V-Model chain:
```
URD-002 (Expectation)
   ↓
SRD-002 (Assertion)
   ↓
SWD-002 (Assertion)
   ↓
LLTC-002 (Premise/Evidence)
```

### Step 7: Validate

```bash
# Must pass before committing!
trudag manage lint
```

**Expected output:**
```
Validating requirements...
✓ URD-002: OK
✓ SRD-002: OK (links to URD-002)
✓ SWD-002: OK (links to SRD-002)
✓ LLTC-002: OK (links to SWD-002)

All validations passed!
```

### Step 8: Mark as reviewed

```bash
# After team review
trudag manage set-item URD-002
trudag manage set-item SRD-002
trudag manage set-item SWD-002
trudag manage set-item LLTC-002
```

### Step 9: Generate report

```bash
# Score requirements
trudag score

# Generate HTML report
trudag publish --output-dir artifacts/trustable-report

# View report
open artifacts/trustable-report/dashboard.md
```

### Step 10: Commit

```bash
git add reqs/
git commit -m "feat: Add URD/SRD/SWD/LLTC-002 battery voltage display

Complete V-Model chain:
- URD-002: User needs to see battery voltage
- SRD-002: System displays voltage ±0.1V at 1Hz
- SWD-002: Software reads ADC channel 0
- LLTC-002: Test verifies accuracy and timing

Traceability: 100%
Validation: trudag manage lint passed
Reviewed: All requirements approved"

git push
```

---

## 🛠️ Essential Commands Summary

```bash
# === INITIALIZATION (once) ===
trudag --init -n "Project Name"

# === DAILY WORKFLOW ===

# 1. Create requirements
trudag manage create-item URD 001 reqs/urd
trudag manage create-item SRD 001 reqs/srd
trudag manage create-item SWD 001 reqs/swd
trudag manage create-item LLTC 001 reqs/lltc

# 2. Edit files (use any editor)
nano reqs/urd/URD-001.md
code reqs/srd/SRD-001.md

# 3. Create links
trudag manage create-link SWD-001 SRD-001
trudag manage create-link LLTC-001 SWD-001
trudag manage create-link SRD-001 URD-001

# 4. Validate (DO THIS OFTEN!)
trudag manage lint

# 5. Mark reviewed (after approval)
trudag manage set-item URD-001
trudag manage set-item SRD-001
trudag manage set-item SWD-001
trudag manage set-item LLTC-001

# 6. Generate reports
trudag score
trudag publish --output-dir artifacts/trustable-report

# 7. Commit
git add reqs/
git commit -m "feat: Add requirements..."
git push
```

---

## ❌ Common Mistakes to Avoid

### 1. Don't mix doorstop commands

```bash
# ❌ WRONG - Don't use these!
doorstop add URD
doorstop edit URD-001
doorstop link SWD-001 SRD-001

# ✅ CORRECT - Use trudag
trudag manage create-item URD 001 reqs/urd
# Edit manually: nano reqs/urd/URD-001.md
trudag manage create-link SWD-001 SRD-001
```

### 2. Don't forget to validate

```bash
# Always run before committing
trudag manage lint
```

### 3. Don't skip the frontmatter

Every `.md` file MUST have YAML frontmatter:

```markdown
---
ref: URD-001
header: "Title"
text: |
  Description...
# ... other mandatory fields
---

# Rest of markdown content
```

### 4. Don't manually edit links

```bash
# ❌ WRONG - Don't edit links: [] manually
# ✅ CORRECT - Use trudag command
trudag manage create-link CHILD PARENT
```

---

## 🆘 Troubleshooting

### Issue: "trudag: command not found"

```bash
# Activate venv
source .venv/bin/activate

# Verify installation
trudag --version
```

### Issue: "Invalid YAML frontmatter"

**Check:**
- Starts with `---`
- Ends with `---`
- Valid YAML syntax
- All mandatory fields present

### Issue: "Reference URD-001 not found"

**Problem:** Parent doesn't exist

**Solution:**
```bash
# Create parent first
trudag manage create-item URD 001 reqs/urd

# Then create link
trudag manage create-link SRD-001 URD-001
```

### Issue: "reviewed field invalid"

```yaml
# ❌ WRONG
reviewed: 'approved'
reviewed: 'yes'

# ✅ CORRECT
reviewed: ''                    # Not reviewed yet
reviewed: 'abc123def456...'     # Git SHA (set by trudag manage set-item)
```

---

## 📊 File Format Reference

### Mandatory YAML Frontmatter Fields

```yaml
---
ref: <ID>                        # Must match filename
header: "<Title>"
text: |
  <Description with SHALL>

ASIL: <A|B|C|D|QM>
Verification Method: <Method>

links: []                        # Or list of parents

reviewers:
  - name: "<Name>"
    email: "<email>"

reviewed: ''                     # Empty until approved

active: true
derived: false
normative: true
level: 1.0
---
```

### Optional Markdown Content

After the frontmatter, add:
- Detailed description
- Rationale
- Acceptance criteria
- Assumptions
- Implementation notes
- Test procedures

---

## ✅ Success Checklist

Before committing:

- [ ] All files created with `trudag manage create-item`
- [ ] All files edited with proper YAML frontmatter
- [ ] All links created with `trudag manage create-link`
- [ ] `trudag manage lint` passes without errors
- [ ] Requirements reviewed and marked with `trudag manage set-item`
- [ ] Reports generated with `trudag publish`

---

**Last Updated:** October 2025
**Version:** 3.0 (trudag native workflow)
**Format:** Markdown + YAML frontmatter

---

**Next:** See `docs/tsf/reference.md` for quick command reference
