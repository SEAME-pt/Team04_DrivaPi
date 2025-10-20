# Getting Started with DrivaPi TSF

**Version:** 3.0
**Last Updated:** October 2025
**Time to Complete:** 30 minutes

---

## 🎯 What You'll Learn

- Install official TSF tools (`trudag` + `doorstop`)
- Validate existing requirements
- Create your first requirement
- Generate traceability reports

---

## 📋 Prerequisites

**Required:**
- Python 3.11+ installed
- Git configured
- Text editor (VS Code recommended)
- Terminal/command line access

**Check:**
```bash
python3 --version  # Should show 3.11+
git --version
```

---

## 🚀 Setup (30 minutes)

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

### Step 3: Install Official Tools (10 min)

```bash
# Upgrade pip
pip install --upgrade pip

# Install Doorstop
pip install doorstop pyyaml

# Verify
doorstop --version
```

**Install Trustable (trudag):**
```bash
# Clone official repository
git clone https://gitlab.com/CodethinkLabs/trustable/trustable.git /tmp/trustable

# Install from specific tag
cd /tmp/trustable
git checkout 2025.9.16
pip install .

# Return to project
cd -

# Verify
trudag --version
```

**Expected output:**
```
trudag X.X.X
doorstop, version X.X.X
```

### Step 4: Validate Requirements (5 min)

```bash
# Run official validations
trudag manage lint
doorstop
```

**Expected output:**
```
✓ All requirements validated
✓ No broken links
✓ Structure is valid
```

**If errors appear:**
- Read error messages carefully
- Fix YAML syntax issues
- Ensure `ref:` matches filename
- Re-run validation

### Step 5: Test Traceability (5 min)

```bash
# Update Doorstop structure
trudag manage migrate

# Generate traceability report
trudag report export --output artifacts/test-report.zip

# Check output
ls -lh artifacts/test-report.zip
```

### Step 6: Verify Project Structure (5 min)

```bash
# Should see this structure:
tree -L 2 reqs/

# Expected:
# reqs/
# ├── urd/           ← User Requirements
# ├── srd/           ← System Requirements
# ├── swd/           ← Software Requirements
# └── lltc/          ← Test Cases
```

---

## ✅ Verification Checklist

Before you start working:

- [ ] Virtual environment activated (`.venv`)
- [ ] `trudag --version` works
- [ ] `doorstop --version` works
- [ ] `trudag manage lint` passes
- [ ] `doorstop` passes (no errors)
- [ ] Can see `reqs/urd/`, `reqs/srd/`, etc.

---

## 🎓 Next Steps

1. **Read Workflows:** `docs/WORKFLOWS.md`
2. **Quick Reference:** `docs/TSF_REFERENCE.md`
3. **Training:** `docs/TRAINING.md`
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
pip install .
```

### Issue: `doorstop` shows "no documents found"

**Solution:**
```bash
# Check .doorstop.yml files exist
ls reqs/*/.doorstop.yml

# Should show 4 files (urd, srd, swd, lltc)
```

### Issue: `trudag manage lint` fails

**Solution:**
```bash
# Read error message carefully
# Common issues:
# - Missing 'ref:' field
# - 'ref:' doesn't match filename
# - Missing 'reviewers:' block
# - Invalid YAML syntax

# Fix the YAML file, then re-run
trudag manage lint
```

### Issue: Python version too old

**Solution:**
```bash
# Install Python 3.11+ from python.org
# Or use pyenv:
pyenv install 3.11
pyenv local 3.11
```

---

## 📚 Documentation Map

```
docs/tsf/
├── start.md              ← You are here
├── workflows.md          ← Daily workflows
├── reference.md          ← Quick reference
├── training.md           ← Full training guide
└── evidence.md           ← Evidence collection
```

---

## 🔗 Official Resources

- **Trustable Docs:** https://codethinklabs.gitlab.io/trustable/trustable/
- **Doorstop Docs:** https://doorstop.readthedocs.io/
- **ISO 26262 Overview:** https://www.iso.org/standard/68383.html

---

## ✨ You're Ready!

You can now:
- ✅ Validate requirements
- ✅ Create new requirements
- ✅ Generate traceability reports
- ✅ Participate in reviews

**Start with:** `docs/tsf/workflows.md` to learn common tasks.

---

**Questions?** Ask in team standup or check `docs/tsf/training.md`
