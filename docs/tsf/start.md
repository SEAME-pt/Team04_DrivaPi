# Getting Started with DrivaPi TSF

**Version:** 4.0
**Last Updated:** October 2025

---

## 🎯 What You'll Learn

- Install official TSF tool (`trudag`)
- Initialize a new TSF project
- Create and link requirements
- Validate and publish reports

---

## 📋 Prerequisites

**Required:**
- Python 3.11+ installed
- Git configured
- Text editor (VS Code recommended)

**Check:**
```bash
python3 --version  # Should show 3.11+
git --version
```

---

## 🚀 Setup (20 minutes)

### Step 1: Clone Repository (2 min)

```bash
git clone https://github.com/SEAME-pt/Team04_DrivaPi.git
cd Team04_DrivaPi
```

### Step 2: Create Virtual Environment (3 min)

```bash
# Create venv
python3 -m venv .venv

# Activate (Linux/Mac)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate
```

**Verify activation:**
```bash
which python  # Should show .venv/bin/python
```

### Step 3: Install trudag (5 min)

```bash
# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install pyyaml

# Clone official trustable repository
git clone https://gitlab.com/CodethinkLabs/trustable/trustable.git /tmp/trustable

# Install from specific tag
cd /tmp/trustable
git checkout 2025.9.16
pip install .

# Return to project
cd -

# Verify installation
trudag --version
```

**Expected output:**
```
trudag X.X.X
```

### Step 4: Initialize Project (if starting fresh) (3 min)

**Note:** Your project is already initialized! Skip this if `.dotstop.dot` exists.

```bash
# Only for NEW projects:
trudag --init

# This creates:
# - .dotstop.dot (graph structure)
# - .dotstop_extensions/ (custom validators)
```

### Step 5: Validate Requirements (2 min)

```bash
# Run validation
trudag manage lint

# Expected output:
✓ All requirements validated
✓ No broken links

# Calculate trust scores
trudag score
```

### Step 6: Generate Report (5 min)

```bash
# Create Trustable report
trudag publish --output-dir artifacts/trustable-report

# View results
ls artifacts/trustable-report/
# Should show: dashboard.md, URD.md, SRD.md, SWD.md, LLTC.md, etc.
```

### Step 7: Verify Project Structure

```bash
# Check requirements structure
ls -R reqs/

# Expected structure:
# reqs/
# ├── urd/URD-001.md
# ├── srd/SRD-001.md
# ├── swd/SWD-001.md
# ├── lltc/LLTC-001.md
# └── templates/
```

---

## ✅ Verification Checklist

Before you start working:

- [ ] Virtual environment activated (`.venv`)
- [ ] `trudag --version` works
- [ ] `trudag manage lint` passes with no errors
- [ ] `trudag score` runs successfully
- [ ] `.dotstop.dot` file exists
- [ ] Can see `reqs/urd/`, `reqs/srd/`, `reqs/swd/`, `reqs/lltc/`

---

## 🎓 Next Steps

1. **Read Workflows:** `docs/tsf/workflow.md`
2. **Quick Reference:** `docs/tsf/reference.md`
3. **Training:** `docs/tsf/training.md`
4. **Create First Requirement:** Follow Workflow 1

---

## 🆘 Troubleshooting

### Issue: `trudag: command not found`

**Solution:**
```bash
# Ensure venv is activated
source .venv/bin/activate

# Reinstall trustable
cd /tmp/trustable
git checkout 2025.9.16
pip install .
cd -
```

### Issue: `trudag manage lint` fails

**Solution:**
```bash
# Read error message carefully
# Common issues:
# - Markdown frontmatter syntax error
# - Missing required fields (normative, level)
# - File not listed in .dotstop.dot

# Check .dotstop.dot contains your requirement
cat .dotstop.dot
```

### Issue: Requirements not showing in report

**Solution:**
```bash
# Ensure requirements are marked as reviewed
trudag manage set-item URD-001
trudag manage set-item SRD-001

# Recalculate scores
trudag score

# Regenerate report
trudag publish --output-dir artifacts/trustable-report
```

---

## 📚 Key Concepts

### Files Created by trudag

1. **`.dotstop.dot`** - Graph structure tracking all requirements and their links
2. **`.dotstop_extensions/`** - Custom validators (e.g., license checks)
3. **`reqs/<type>/<ID>.md`** - Markdown files with YAML frontmatter

### Requirement File Format

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
---
The system SHALL do something specific and testable.
```

### The V-Model Structure

```
URD (User Requirements)     ← WHAT users need
  ↓
SRD (System Requirements)   ← HOW system provides
  ↓
SWD (Software Design)       ← HOW software implements
  ↓
LLTC (Low Level Tests)      ← HOW to verify
```

---

**Ready to create your first requirement?** Continue to `docs/tsf/workflow.md`
