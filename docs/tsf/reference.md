# TSF Quick Reference (Cheat Sheet)

**One page with all essential commands**

---

## 🛠️ Essential Commands

```bash
# ALWAYS activate environment first
source .venv/bin/activate

# Validate requirements
trudag manage lint

# Calculate scores
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
trudag manage create-item URD 042 reqs/urd
trudag manage create-item SRD 015 reqs/srd
trudag manage create-item SWD 123 reqs/swd
trudag manage create-item LLTC 001 reqs/lltc
```

---

## 🔗 Link Requirements (Traceability)

```bash
# Link child → parent (ALWAYS upward in V-Model)
trudag manage create-link <CHILD> <PARENT>

# Examples (bottom-up):
trudag manage create-link SRD-015 URD-042    # System → User
trudag manage create-link SWD-123 SRD-015    # Software → System
trudag manage create-link LLTC-001 SWD-123   # Test → Software
```

---

## ✅ Review & Approval

```bash
# Mark as reviewed (adds git SHA automatically)
trudag manage set-item <ID>

# Examples:
trudag manage set-item URD-042
trudag manage set-item SWD-123
```

**After running the above, manually edit the requirement markdown file to fill in the `reviewed:` field for audit trail:**
```bash
nano reqs/swd/SWD-123.md
```

---

## 📋 Markdown File Structure

```yaml
---
id: <REF>
header: "<HEADER>"
text: |
  <DESCRIPTION>

# TSF Type: Evidence/Assertion/Premise
ASIL: <ASIL>
verification_method: <VERIFICATION_METHOD>

# Links: Connects to parent Assertion
parents:
  - id: <PARENT_REF>
children:
  - id: <CHILD_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''  # Manually fill on PR approval

# Evidence Linking (use 'references:', NOT 'artifact:')
references:
  - type: "file"
    path: <relative/path/to/artifact>

# Optional: Manual SME Score
score:
  <SME_ID>: <0.0-1.0>

# Optional: Automated Validation
evidence:
  type: <validator_name>
  references:
    - type: "file"
      path: <path/to/artifact>
  configuration:
    <param>: <value>

active: true
derived: false
normative: true
level: <LEVEL>
---
<STATEMENT>
```

**Required fields:**
- `id:` - Requirement ID
- `header:` - Short title
- `text:` - Full description
- TSF Type - URD/SRD/SWD = Assertion; LLTC = Evidence/Premise
- `ASIL:` - A/B/C/D/QM
- `verification_method:` - How to test
- `reviewers:` - At least 1 (2 for ASIL B+)
- `reviewed: ''` - Empty until approval
- `parents:` - At least 1 parent requirement (except URD)
- `children:` - Child requirements (except LLTC)
- `normative: true` - Always true (obligatory)
- `active: true` - Always true (active requirement)
- `derived:` - If derived from another requirement (usually false)
- `level:` - 1.0 (URD), 2.0 (SRD), 3.0 (SWD), 4.0 (LLTC)

**Evidence & Scoring (NEW - see evidence.md):**
- `references:` - Links passive artifacts (files, URLs) for human review
- `score:` - Manual SME confidence scores (0.0-1.0)
- `evidence:` - Automated validator configuration (requires custom validator)

---

## 🏷️ ASIL Levels (ISO 26262)

| ASIL | Risk | Example | Reviews |
|------|------|---------|---------|
| **QM** | None | Radio, configs | 1 |
| **A** | Low | Rear lights | 1 |
| **B** | Low-Med | Brake lights | 2+ |
| **C** | Medium | ABS, ESC | 2+ independent |
| **D** | High | Airbags | 2+ + formal |

**DrivaPi typical:**
- Display features → **A** or **QM**
- Sensor processing → **B**
- Motor control → **B**
- Emergency stop → **C**

---

## 📊 V-Model (Linking Order)

```
URD (User)      ← Level 1.0 (Assertion)
  ↑
SRD (System)    ← Level 2.0 (Assertion)
  ↑
SWD (Software)  ← Level 3.0 (Assertion)
  ↑
LLTC (Tests)    ← Level 4.0 (Evidence/Premise)
```

**Golden rule:** Child always links to PARENT (bottom-up)

---

## 💯 Scoring Quick Reference

### Manual SME Scoring
```yaml
---
id: LLTC-042
references:
  - type: "file"
    path: tests/unit/test_temp.cpp
  - type: "file"
    path: artifacts/verification/tests/LLTC-042-junit.xml
score:
  ReviewerA: 0.9  # 90% confident based on evidence
  ReviewerB: 0.8  # 80% confident
---
```

### Automated Validation
```yaml
---
id: LLTC-042
evidence:
  type: junit_pass_fail_checker
  references:
    - type: "file"
      path: artifacts/verification/tests/LLTC-042-junit.xml
  configuration:
    expected_tests: 5
---
```

**Score Meaning:**
- 1.0 = Certain statement is true
- 0.5 = Completely uncertain
- 0.0 = Certain statement is false (or default for unscored)

**Default:** Requirements without `score:` or `evidence:` blocks default to **0.0**

---

## 📦 Evidence Linking (NEW)

**Use `references:` block (NOT deprecated `artifact:` block):**

```yaml
---
id: SWD-042
references:
  - type: "file"
    path: src/sensors/temperature.cpp
  - type: "file"
    path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml
  - type: "url"  # For PRs, external links
    path: https://github.com/SEAME-pt/Team04_DrivaPi/pull/142
score:
  CodeReviewer: 0.9
---
```

**Common Evidence Types:**
1. **Code** - `src/` files
2. **Tests** - `tests/` files + `artifacts/verification/tests/` results
3. **Design** - `docs/design/` diagrams, specs
4. **Review** - PR URLs, commit SHAs
5. **Analysis** - `artifacts/verification/static-analysis/`, coverage reports
6. **Compliance** - `docs/standards/` ISO 26262 docs

---

## 🔧 Quick Troubleshooting

**`trudag: command not found`**
```bash
source .venv/bin/activate
```

**"YAML syntax error"**
```bash
# Check frontmatter (lines 1-40)
head -40 reqs/swd/SWD-042.md
# Look for: --- at start and end, correct indentation
```

**"Broken link: parent not found"**
```bash
# Create parent first
trudag manage create-item SRD 015 reqs/srd
# Then link
trudag manage create-link SWD-042 SRD-015
```

**"Requirement has score 0.0" (unexpected)**
```bash
# Add score: block or evidence: block to requirement
nano reqs/lltc/LLTC-042.md
# Then recalculate
trudag score
```

---

## 📁 Folder Structure

```
reqs/
├── urd/          # User Requirements (level 1.0, Assertion)
├── srd/          # System Requirements (level 2.0, Assertion)
├── swd/          # Software Design (level 3.0, Assertion)
└── lltc/         # Test Cases (level 4.0, Evidence/Premise)

artifacts/
├── trustable-report/          # Generated reports
└── verification/
    ├── tests/                 # Test results (*.xml)
    ├── static-analysis/       # Analysis reports
    └── coverage/              # Coverage reports

docs/
├── design/                    # Architecture, interfaces
└── standards/                 # ISO 26262, ASIL docs
```

---

## 🎯 Typical Workflow (7 steps)

```bash
# 1. Create
trudag manage create-item SWD 042 reqs/swd

# 2. Edit (add header, text, ASIL, etc.)
nano reqs/swd/SWD-042.md

# 3. Link to parent
trudag manage create-link SWD-042 SRD-015

# 4. Add evidence links & score
nano reqs/swd/SWD-042.md
# Add references: block with artifact paths
# Add score: block with SME assessment

# 5. Validate
trudag manage lint

# 6. Calculate scores
trudag score

# 7. Commit
git add reqs/swd/SWD-042.md .dotstop.dot
git commit -m "feat(swd): Add SWD-042 with evidence and scoring"
```

---

## 🚀 Complete Development Cycle

```bash
# 1. Implement feature
nano src/sensors/temperature.cpp

# 2. Write tests
nano tests/unit/test_temperature.cpp

# 3. Run CI (generates test results, analysis)
./run_tests.sh > artifacts/verification/tests/LLTC-042-junit.xml
cppcheck src/sensors/temperature.cpp 2> artifacts/verification/static-analysis/cppcheck-SWD-042.xml

# 4. Create/update requirements with evidence links
nano reqs/lltc/LLTC-042.md  # Add references: to test files
nano reqs/swd/SWD-042.md     # Add references: to code, analysis

# 5. Add scores (manual or automated)
# Edit .md files to add score: or evidence: blocks

# 6. Validate and score
trudag manage lint
trudag score

# 7. Generate report
trudag publish --output-dir artifacts/trustable-report

# 8. Create PR
git add .
git commit -m "feat: Implement temperature sensor with full TSF traceability"
git push origin feature/temperature-sensor
```

---

**More details:**
- Complete workflows → [workflow.md](workflow.md)
- TSF theory → [training.md](training.md)
- Evidence & Scoring → [evidence.md](evidence.md)
- Commands → [reference.md](reference.md)
