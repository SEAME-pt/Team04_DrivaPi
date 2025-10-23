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

# After running the above, manually edit the requirement markdown file to fill in the 'reviewed:' field for audit trail:
```bash
nano reqs/swd/SWD-123.md
```

---

## 📋 Markdown File Structure

```markdown
---
id: <REF>
header: "<HEADER>"
text: |
  <DESCRIPTION>

# TSF Type: Evidence/Assertion/Premise

ASIL: <ASIL>
Verification Method: <VERIFICATION_METHOD>

# Links: Connects to parent Assertion
links:
  - <PARENT_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''  # Manually fill on PR approval

active: true
derived: false
normative: true
level: <LEVEL>
---
```

**Required fields:**
- `id:` - Requirement ID
- `header:` - Short title
- `text:` - Full description
- `TSF Type:` - URD/SRD/SWD = Assertion; LLTC = Premise
- `ASIL:` - A/B/C/D/QM
- `verification_method:` - How to test
- `reviewers:` - At least 1 (2 for ASIL B+)
- `reviewed: ''` - Empty until approval
- `links:` - At least 1 parent link (except URD)
- `normative: true` - Always true (obligatory)
- `active: true` - Always true (active requirement)
- `derived:` - if derived from another requirement (usually false)
- `level:` - 1.0 (URD), 2.0 (SRD), 3.0 (SWD), 4.0 (LLTC)

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
URD (User)      ← Level 1.0
  ↑
SRD (System)    ← Level 2.0
  ↑
SWD (Software)  ← Level 3.0
  ↑
LLTC (Tests)    ← Level 4.0
```

**Golden rule:** Child always links to PARENT (bottom-up)

---

## 🔧 Quick Troubleshooting

**`trudag: command not found`**
```bash
source .venv/bin/activate
```

**"YAML syntax error"**
```bash
# Check frontmatter (lines 1-20)
head -20 reqs/swd/SWD-042.md
# Look for: --- at start and end, correct indentation
```

**"Broken link: parent not found"**
```bash
# Create parent first
trudag manage create-item SRD 015 reqs/srd
# Then link
trudag manage create-link SWD-042 SRD-015
```

---

## 📁 Folder Structure

```
reqs/
├── urd/          # User Requirements (level 1.0)
├── srd/          # System Requirements (level 2.0)
├── swd/          # Software Design (level 3.0)
└── lltc/         # Test Cases (level 4.0)

artifacts/
└── trustable-report/   # Generated reports
```

---

## 🎯 Typical Workflow (5 steps)

```bash
# 1. Create
trudag manage create-item SWD 042 reqs/swd

# 2. Edit
nano reqs/swd/SWD-042.md

# 3. Link
trudag manage create-link SWD-042 SRD-015

# 4. Validate
trudag manage lint

# 5. Commit
git add reqs/swd/SWD-042.md .dotstop.dot
git commit -m "feat(swd): Add SWD-042"
```

---

**More details:**
- Complete workflows → [workflow.md](workflow.md)
- TSF theory → [training.md](training.md)
- Evidence → [evidence.md](evidence.md)
