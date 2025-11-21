# TSF Quick Reference (Cheat Sheet) - DrivaPi

**One page with all essential commands**

---

## 🛠️ Essential Commands

```bash
# ALWAYS activate environment first
source .venv/bin/activate

# Validate requirements
trudag manage lint

# Calculate scores (propagates from URD down)
trudag score

# Generate report
trudag publish --output-dir artifacts/trustable-report
```

---

## 📝 Create Requirements

```bash
# Create new requirement
trudag manage create-item <TYPE> <NUM> reqs/<type>

# Examples:
trudag manage create-item URD 010 reqs/urd
trudag manage create-item SRD 010 reqs/srd
trudag manage create-item SWD 010 reqs/swd
trudag manage create-item LLTC 010 reqs/lltc
```

---

## 🔗 Link Requirements (Traceability)

```bash
# Link parent → child (ALWAYS upward in V-Model)
trudag manage create-link <PARENT> <CHILD>

# Examples (bottom-up):
trudag manage create-link URD-010 SRD-010    # User → System
trudag manage create-link SRD-010 SWD-010    # System → Software
trudag manage create-link SWD-010 LLTC-010   # Software → Test
```

---
## Remove Links

```bash
# Remove link parent → child
trudag manage remove-link <PARENT> <CHILD>
# Examples:
trudag manage remove-link URD-010 SRD-010
trudag manage remove-link SRD-010 SWD-010
trudag manage remove-link SWD-010 LLTC-010
```


## Check Syntax & Integrity

```bash
# Validate requirements (YAML syntax, links, scores)
trudag manage lint
```
---

## ✅ Review & Approval

```bash
# Mark as reviewed (adds git SHA automatically)
trudag manage set-item <ID>

# Examples:
trudag manage set-item URD-010
trudag manage set-item SWD-010
```

**After running the above, manually edit the requirement markdown file to fill in the `reviewed:` field for audit trail:**

```bash
nano reqs/swd/SWD-010.md
```

---
## 📋 Requirement Structure

Check reqs/templates/ for full examples.

**Field Requirements:**

| Field | URD | SRD | SWD | LLTC |
|-------|-----|-----|-----|------|
| `id:` | ✓ | ✓ | ✓ | ✓ |
| `header:` | ✓ | ✓ | ✓ | ✓ |
| `text:` | ✓ | ✓ | ✓ | ✓ |
| `references:` | ✓ | ✓ | ✓ | ✓ |
| `score:` | ✗ | ✗ | ✗ | ✓ |
| `ASIL:` | ✗ | ✗ | ✓ | ✗ |
| `parents:` | ✗ | ✓ | ✓ | ✓ |
| `children:` | ✓ | ✓ | ✓ | ✗ |
| `reviewers:` | ✓ | ✓ | ✓ | ✓ |
| `reviewed:` | ✓ | ✓ | ✓ | ✓ |
| `normative:` | ✓ | ✓ | ✓ | ✓ |
| `active:` | ✓ | ✓ | ✓ | ✓ |
| `derived:` | ✓ | ✓ | ✓ | ✓ |
| `level:` | ✓ | ✓ | ✓ | ✓ |

---

## 🏷️ ASIL Levels (ISO 26262)

| ASIL | Risk | Example | SME Reviews |
|------|------|---------|------------|
| **QM** | None | Radio, configs | 1 |
| **A** | Low | Rear lights, display | 1 |
| **B** | Low-Med | Brake lights, sensors | 2+ |
| **C** | Medium | ABS, ESC, emergency stop | 2+ independent |
| **D** | High | Airbags, steering | 2+ + formal methods |

**DrivaPi typical:**
- Display features → **A** or **QM**
- Sensor processing → **B**
- Motor control → **B**
- Emergency stop → **C**

---

## 📊 V-Model (Linking Order)

```
URD (User)      ← Level 1.0 (Assertion)
  ↑ (score: block HERE)
SRD (System)    ← Level 2.0 (Assertion)
  ↑ (NO score)
SWD (Software)  ← Level 3.0 (Assertion, ASIL: here)
  ↑ (NO score)
LLTC (Tests)    ← Level 4.0 (Evidence/Premise)
```

**Golden rules:**
1. Child always links to PARENT (bottom-up)
2. Score ONLY in URD
3. ASIL ONLY in SWD
4. References at ALL levels
5. NO `evidence:` blocks (manual SME review only)

---

## 💯 Scoring Quick Reference

### Manual SME Scoring (LLTC level)

```yaml
---
id: LLTC-010
header: "Motor speed monitoring test cases"
text: |
  "Tests to verify motor speed monitoring functionality."
score:
  TestEngineer: 0. ninety five5  # SME confidence score (1.0=certain true, 0.5=unc
---
```

### Score Propagation (Automatic)

```
URD-010: (NO score) → inherits 0.95
   ↑
SRD-010: (NO score) → inherits 0.95
   ↑
SWD-010: (NO score) → inherits 0.95
   ↑ (trudag automatically propagates)
LLTC-010: score: 0.95
```

### Score Meaning

- **1.0** = Certain statement is true
- **0.75-0.9** = Very confident, minor doubts
- **0.5** = Completely uncertain
- **0.25-0.5** = Low confidence
- **0.0** = Certain statement is false / Default for unscored

**Default:** Requirements without `score:` block = **0.0** (unless they inherit from parent URD)

---

## 📦 Evidence Linking

**Use `references:`:**

```yaml
---
id: SWD-010
references:
  - type: "file"
    path: src/sensors/motor_speed.cpp
    description: "Implementation"
  - type: "file"
    path: artifacts/verification/static-analysis/cppcheck-SWD-010.xml
    description: "Static analysis (0 errors)"
  - type: "file"
    path: artifacts/verification/coverage/motor-coverage.txt
    description: "Coverage (87%)"
  - type: "file"
    path: docs/standards/iso26262/asil-justification-swd-010.md
    description: "ASIL A justification"
---
```

**Evidence Types (linked in references):**

| Type | Location | Linked In |
|------|----------|-----------|
| **Code** | `src/` | SWD |
| **Tests** | `tests/`, `artifacts/verification/tests/` | LLTC, SWD |
| **Design** | `docs/design/` | SRD, SWD |
| **Analysis** | `artifacts/verification/static-analysis/`, `coverage/` | SWD |
| **Review** | `reviewed:` field + PR links | Any level |
| **Compliance** | `docs/standards/iso26262/` | SWD (ASIL docs) |


---

## 🔧 Quick Troubleshooting

**`trudag: command not found`**
```bash
source .venv/bin/activate
```

**"YAML syntax error"**
```bash
# Check frontmatter (lines 1-40)
head -40 reqs/swd/SWD-010.md
# Look for: --- at start and end, correct indentation
```

**"Broken link: parent not found"**
```bash
# Create parent first
trudag manage create-item SRD 010 reqs/srd
# Then link
trudag manage create-link SRD-010 SWD-010
```

**"Score is 0.0 unexpectedly"**
```bash
# Check URD has score: block
# SRD/SWD/LLTC should NOT have score: (they inherit)
nano reqs/urd/URD-010.md
# Make sure score: block exists at URD level only
trudag score
```

**"ASIL field in SRD or LLTC"**
```bash
# ✗ WRONG
id: SRD-010
ASIL: "A"  # Error! Should be in SWD only

# ✓ CORRECT
id: SWD-010
ASIL: "A"  # Correct placement
```

---

## 📁 Folder Structure

```
reqs/
├── urd/          # User Requirements (level 1.0, Assertion)
│   └── URD-010.md
├── srd/          # System Requirements (level 2.0, Assertion)
│   └── SRD-010.md
├── swd/          # Software Requirements (level 3.0, Assertion, ASIL here)
│   └── SWD-010.md
└── lltc/         # Test Cases (level 4.0, Evidence/Premise)
    └── LLTC-010.md

artifacts/
├── trustable-report/          # Generated by trudag publish
└── verification/
    ├── tests/                 # Test results (*.xml)
    │   └── LLTC-010-junit.xml
    ├── static-analysis/       # Analysis reports
    │   └── cppcheck-SWD-010.xml
    └── coverage/              # Coverage reports
        └── motor-coverage.txt

docs/
├── design/                    # Architecture, interfaces
│   ├── motor_system_architecture.md
│   └── gpio_sensor_interface.md
├── user_needs_analysis.md
└── standards/iso26262/        # ASIL justification docs
    └── asil-justification-swd-010.md

src/sensors/
└── motor_speed.cpp            # Implementation

tests/unit/
└── test_motor_speed.cpp       # Tests
```

---

**More details:**
- Complete workflows → [workflow.md](workflow.md)
- TSF theory → [training.md](training.md)
- Evidence & Scoring → [evidence.md](evidence.md)
- Commands → [reference.md](reference.md)
