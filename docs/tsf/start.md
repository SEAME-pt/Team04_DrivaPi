# Getting Started with TSF

**Goal:** Install tools and validate existing requirements
**Time:** 15 minutes

---

## 🚀 Quick Setup

### 1. Install trudag (5 min)

```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install --upgrade pip pyyaml

# Install trudag (official TSF tool)
git clone https://gitlab.com/CodethinkLabs/trustable/trustable.git /tmp/trustable
cd /tmp/trustable
git checkout 2025.9.16
pip install .
cd -

# Verify installation
trudag --version
```

### 2. Validate Requirements (2 min)

```bash
# Validate everything
trudag manage lint

# Calculate scores
trudag score

# Generate report
trudag publish --output-dir artifacts/trustable-report
```

---

## ✅ Verification Checklist

Before starting work:

- [ ] `source .venv/bin/activate` works
- [ ] `trudag --version` shows version
- [ ] `trudag manage lint` passes without errors
- [ ] `.dotstop.dot` file exists
- [ ] Folders `reqs/urd/`, `reqs/srd/`, `reqs/swd/`, `reqs/lltc/` exist

---

## 🎯 Next Steps

**To start working:**
- Basic commands → [reference.md](reference.md)
- Create requirements → [workflow.md](workflow.md) (Workflow 1)
- Understand theory → [training.md](training.md)

**Problems?**
- Error `trudag: command not found` → Re-activate environment: `source .venv/bin/activate`
- Validation error → Read error message, usually YAML syntax
- Other issues → Ask in stand-up or check [workflow.md](workflow.md) "Fix Errors" section
