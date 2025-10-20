# Setup Guide

**Version:** 2.0
**Date:** 20 October 2025

---

## 🎯 Purpose

Set up a TSF development environment with:
- ✅ **trudag** (Eclipse Trustable)
- ✅ **doorstop** (requirements backend)

---

## 📋 Prerequisites

### Required Software
- **Python 3.11+** (`python3 --version`)
- **Git** (`git --version`)
- **Text editor** (VS Code recommended)

### Knowledge
- Basic Git
- Basic YAML
- Requirements engineering concepts (recommended)

---

## 🚀 Step-by-step Setup

### 1. Clone the repository

```bash
git clone https://github.com/SEAME-pt/Team04_DrivaPi.git
cd Team04_DrivaPi
```

---

### 2. Create a virtual environment

```bash
# Create venv
python3 -m venv .venv

# Activate (Linux/Mac)
source .venv/bin/activate

# Activate (Windows PowerShell)
.venv\Scripts\Activate.ps1

# Activate (Windows CMD)
.venv\Scripts\activate.bat
```

**Verify activation:**
```bash
which python  # Linux/Mac - should show .venv/bin/python
where python  # Windows - should show .venv\Scripts\python.exe
```

---

### 3. Install official tools

#### A. Install Doorstop

```bash
pip install --upgrade pip
pip install doorstop pyyaml
```

**Verify:**
```bash
doorstop --version
# Expected output: doorstop, version X.X.X
```

#### B. Install Trustable (trudag)

```bash
# Clone the official Trustable repository
git clone https://gitlab.com/CodethinkLabs/trustable/trustable.git /tmp/trustable

# Change into the directory
cd /tmp/trustable

# Checkout the stable release
git checkout 2025.9.16

# Install
pip install .

# Return to your project
cd -
```

**Verify:**
```bash
trudag --version
# Expected output: trudag X.X.X
```

#### C. List available commands

```bash
# trudag commands
trudag --help

# doorstop commands
doorstop --help
```

---

### 4. Verify project structure

```bash
# Show tree
tree -L 2

# Or use ls
ls -la
```

**Expected structure:**
```
Team04_DrivaPi/
├── .github/          # CI/CD configs
├── reqs/             # Requirements (TSF core)
│   ├── urd/
│   ├── srd/
│   ├── swd/
│   ├── lltc/
│   └── templates/
├── docs/             # Documentation
├── artifacts/        # Outputs
├── src/              # Source code
├── tests/            # Tests
└── README.md
```

---

### 5. First validation

```bash
# Validate Doorstop structure
doorstop

# Validate TSF requirements
trudag manage lint

# Update structure
trudag manage migrate
```

**Expected output:**
```
✓ All requirements validated
✓ No broken links
✓ Structure is valid
```

---

## 🔧 Editor configuration (VS Code)

### Recommended extensions

Create `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "redhat.vscode-yaml",
    "streetsidesoftware.code-spell-checker",
    "yzhang.markdown-all-in-one",
    "donjayamanne.githistory",
    "eamodio.gitlens"
  ]
}
```

### Settings

Create `.vscode/settings.json`:

```json
{
  "yaml.schemas": {},
  "files.exclude": {
    "**/.venv": true,
    "**/__pycache__": true,
    "**/.pytest_cache": true,
    "**/.dotstop.dot": false
  },
  "files.watcherExclude": {
    "**/.venv/**": true
  },
  "editor.rulers": [80, 100],
  "editor.formatOnSave": true,
  "[yaml]": {
    "editor.tabSize": 2,
    "editor.insertSpaces": true
  },
  "[markdown]": {
    "editor.wordWrap": "on"
  }
}
```

---

## 🎓 Next steps

### 1. Read essential documentation

```bash
# Quick reference (daily commands)
cat docs/training/quick-reference.md

# Full workflow
cat docs/guides/requirements/workflow.md

# TSF training
cat docs/training/TSF-training.md
```

### 2. Create your first requirement (test)

#### Option A: Doorstop interactive
```bash
doorstop add SWD
# Follow the interactive prompts
```

#### Option B: Manual
```bash
# Copy a template
cp reqs/templates/SWD-template.yml reqs/swd/SWD-999.yml

# Edit
nano reqs/swd/SWD-999.yml
# or
code reqs/swd/SWD-999.yml
```

**Required fields to fill:**
- `ref: SWD-999`
- `header: "Test requirement"`
- `text: "The software SHALL..."`
- `ASIL: QM`
- `Verification Method: Unit Test`
- `links: [SRD-001]` (if applicable)
- `reviewers: [your name/email]`
- `reviewed: ''`

### 3. Validate

```bash
trudag manage lint
```

### 4. Commit

```bash
git add reqs/swd/SWD-999.yml
git commit -m "test: Add SWD-999 - Test requirement"
```

### 5. Clean up (optional)

```bash
# Remove the test requirement
git rm reqs/swd/SWD-999.yml
git commit -m "test: Remove test requirement"
```

---

## 📚 Daily essential commands

### Validation
```bash
trudag manage lint              # Validate requirements
trudag manage migrate           # Update structure
doorstop                        # Run Doorstop checks
```

### Create requirement
```bash
# Interactive
doorstop add SWD

# Manual
cp reqs/templates/SWD-template.yml reqs/swd/SWD-XXX.yml
```

### Edit requirement
```bash
# With Doorstop
doorstop edit SWD-001

# Manual
nano reqs/swd/SWD-001.yml
```

### Create links
```bash
# Link child → parent
doorstop link SWD-002 SRD-001

# Validate links
trudag manage lint
```

### Approve requirement
```bash
# Approve
trudag manage set-item reqs/swd/SWD-002.yml

# Commit
git add reqs/swd/SWD-002.yml
git commit -m "review: Approve SWD-002"
```

---

## 🐛 Troubleshooting

### Problem: `trudag: command not found`

**Cause:** Virtual environment not active or trudag not installed.

**Solution:**
```bash
# Check whether venv is active
which python  # Should show .venv/bin/python

# If not active, activate
source .venv/bin/activate

# Reinstall Trustable
cd /tmp/trustable
git pull
git checkout 2025.9.16
pip install --force-reinstall .
cd -
```

---

### Problem: `doorstop: command not found`

**Solution:**
```bash
# Check installation
pip show doorstop

# If not installed
pip install doorstop pyyaml
```

---

### Problem: invalid YAML

**Symptoms:**
```
ERROR: Invalid YAML in reqs/swd/SWD-001.yml
```

**Solution:**
```bash
# Validate syntax online
# https://www.yamllint.com/

# Or install yamllint
pip install yamllint
yamllint reqs/swd/SWD-001.yml
```

**Common errors:**
- Incorrect indentation (use 2 spaces, not tabs)
- Missing `:` after keys
- Multi-line strings without `|` or `>`

---

### Problem: broken links

**Symptoms:**
```
ERROR: Link to SRD-999 not found
```

**Solution:**
```bash
# Check that the parent requirement exists
ls reqs/srd/SRD-999.yml

# If it does not exist, create it or fix the link
```

---

### Problem: Permission denied when installing

**Solution:**
```bash
# DO NOT use sudo with pip inside a venv

# Check that venv is active
which python

# Reinstall without sudo
pip install --user doorstop
```

---

## 🔄 Atualizar Ferramentas

### Atualizar Doorstop
```bash
pip install --upgrade doorstop
```

### Atualizar Trustable
```bash
cd /tmp/trustable
git fetch --tags
git checkout <nova-versao>  # ex: 2025.10.1
pip install --upgrade .
cd -
```

### Verify versions
```bash
pip list | grep doorstop
pip list | grep trustable
```

---

## 🧪 Test the full setup

Run this script to verify everything:

```bash
#!/bin/bash
echo "Testing TSF setup..."

# 1. Check Python
python3 --version || { echo "❌ Python not found"; exit 1; }
echo "✅ Python OK"

# 2. Check venv
if [[ "$VIRTUAL_ENV" != "" ]]; then
  echo "✅ Virtual environment active"
else
  echo "❌ Virtual environment not active"
  exit 1
fi

# 3. Check doorstop
doorstop --version || { echo "❌ doorstop not found"; exit 1; }
echo "✅ doorstop OK"

# 4. Check trudag
trudag --version || { echo "❌ trudag not found"; exit 1; }
echo "✅ trudag OK"

# 5. Validate structure
doorstop || { echo "❌ doorstop validation failed"; exit 1; }
echo "✅ Doorstop structure OK"

# 6. Validate requirements
trudag manage lint || { echo "❌ trudag lint failed"; exit 1; }
echo "✅ Requirements valid"

echo ""
echo "🎉 Setup complete and functional!"
```

Save as `test-setup.sh` and run:
```bash
chmod +x test-setup.sh
./test-setup.sh
```

---

## ✅ Checklist Final

The setup is complete when:

- [ ] Python 3.11+ installed and working
- [ ] Virtual environment created and activated
- [ ] Doorstop installed (`doorstop --version` works)
- [ ] Trudag installed (`trudag --version` works)
- [ ] `doorstop` runs without errors
- [ ] `trudag manage lint` runs without errors
- [ ] Project structure verified
- [ ] First requirement created and validated (test)
- [ ] Documentation read (at minimum `quick-reference.md`)
- [ ] VS Code configured (optional but recommended)

---

## 📖 Additional resources

### Official documentation
- **Trustable:** https://codethinklabs.gitlab.io/trustable/trustable/
- **Doorstop:** https://doorstop.readthedocs.io/
- **ISO 26262:** https://www.iso.org/standard/68383.html

### Project documentation
- **Quick Ref:** `docs/training/quick-reference.md`
- **Workflow:** `docs/guides/requirements/workflow.md`
- **TSF Training:** `docs/training/TSF-training.md`
- **Assessment:** `docs/training/assessment.md`

### Support
- **GitHub Issues:** https://github.com/SEAME-pt/Team04_DrivaPi/issues
- **Team:** See README.md

---

## 🎯 Next step

**Read:** `docs/training/quick-reference.md`
**Then:** Create your first real requirement following `docs/guides/requirements/workflow.md`

---

**Last Updated:** 20 October 2025
**Version:** 2.0 - Official TSF
