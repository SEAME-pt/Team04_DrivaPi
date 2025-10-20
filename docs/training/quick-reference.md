# TSF Quick Reference Card

**Version:** 2.0 - Official TSF Tools Only
**Date:** 20 October 2025
**Team:** DrivaPi (Team04)

---

## ⚠️ IMPORTANT

**This project uses EXCLUSIVELY:**
- ✅ `trudag` (Eclipse Trustable)
- ✅ `doorstop` (requirements backend)
- ❌ **NO** custom Python scripts

---

## 🚀 Daily Commands

```bash
# VALIDATION
trudag manage lint          # Validate requirements
trudag manage migrate       # Update structure
doorstop                    # Run Doorstop checks

# TSF Quick Reference Card

**Version:** 2.0 - Official TSF Tools Only
**Date:** 20 October 2025
**Team:** DrivaPi (Team04)

---

## ⚠️ IMPORTANT

This project uses the official TSF tooling only:

- ✅ `trudag` (Eclipse Trustable)
- ✅ `doorstop` (requirements backend)
- ❌ DO NOT use custom Python scripts

---

## 🚀 Daily Commands

```bash
# VALIDATION
trudag manage lint          # Validate requirements
trudag manage migrate       # Update structure
doorstop                    # Run Doorstop checks

# CREATE REQUIREMENT
doorstop add SWD            # Interactive
cp reqs/templates/SWD-template.yml reqs/swd/SWD-XXX.yml  # Manual

# EDIT
doorstop edit SWD-001       # Doorstop editor
nano reqs/swd/SWD-001.yml   # Manual edit

# LINKS
doorstop link SWD-001 SRD-001   # Create traceability link

# APPROVE
trudag manage set-item reqs/swd/SWD-001.yml
git add reqs/swd/SWD-001.yml
git commit -m "review: Approve SWD-001"

# BASELINE
git tag -a BASELINE-V1.0 -m "Baseline v1.0"
trudag report export --output artifacts/trustable-v1.0.zip
```

---

## 📋 V-Model Hierarchy

```
URD (User)      → WHAT users need
  ↓ links
SRD (System)    → HOW the system provides it
  ↓ links
SWD (Software)  → HOW the software implements it
  ↓ links
LLTC (Tests)    → HOW to verify
```

---

## 📝 Required YAML Fields

```yaml
ID-XXX:
  ref: ID-XXX                     # = filename
  header: "Title"
  text: "The system SHALL..."     # Use "shall"
  ASIL: B                         # A/B/C/D/QM
  Verification Method: Unit Test
  links: [PARENT-ID]              # Parent in the V-model
  reviewers:
    - name: "Name"
      email: "email@example.com"
  reviewed: ''                    # Empty → SHA of approval
  active: true
  derived: false
  normative: true
  level: 1.0
```

---

## 📂 File Structure

```
reqs/
├── urd/          # User Requirements
├── srd/          # System Requirements
├── swd/          # Software Requirements
├── lltc/         # Test Cases
└── templates/    # Official templates
```

---

## ✅ DO / ❌ DON'T

### ✅ DO:
- Use "shall" for requirements
- Be specific (units, timing)
- Link to the parent requirement
- Use the official trudag/doorstop tools

### ❌ DON'T:
- Use vague words ("fast", "approximately")
- Put multiple requirements in one
- Forget units/ranges

---

## 🎯 Good vs Bad Example

❌ **BAD:**
"System shows speed fast"

✅ **GOOD:**
"System SHALL display speed in km/h ±1 km/h, updated every 100ms"

---

## 🏷️ ASIL Levels

| ASIL | Risk | Examples |
|------|------|----------|
| QM   | No safety | Radio |
| A    | Low       | Rear lights |
| B    | Low-Medium| Brake lights |
| C    | Medium    | ABS, ESC |
| D    | High      | Airbags, steering |

---

## 🔄 CI/CD

GitHub Actions runs:
1. `trudag manage lint`
2. `trudag manage migrate`
3. Upload artifacts

---

## 📖 Docs

- Setup: `docs/setup/SETUP.md`
- Workflow: `docs/guides/requirements/workflow.md`
- Training: `docs/training/TSF-training.md`
- Templates: `reqs/templates/`

---

**Last Updated:** 20 October 2025
