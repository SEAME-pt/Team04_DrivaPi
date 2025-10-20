# DrivaPi - SEAME Automotive Journey (Team04)

[![Requirements Checks](https://github.com/SEAME-pt/Team04_DrivaPi/workflows/Requirements%20Checks%20(TSF%20Official)/badge.svg)](https://github.com/SEAME-pt/Team04_DrivaPi/actions)
[![ASIL Compliant](https://img.shields.io/badge/ASIL-A%2FB-blue)]()
[![TSF Framework](https://img.shields.io/badge/TSF-Evidence%20Based-green)]()

> **Autonomous vehicle platform with ISO 26262 compliance using Eclipse TSF (Trustable Software Framework)**

---

## 🎯 Project Overview

DrivaPi is an autonomous vehicle development platform built on **PiRacer** hardware with **Raspberry Pi 5**, implementing automotive-grade software practices using the Eclipse Trustable Software Framework (TSF).

**Key Features:**
- 🚗 Custom-built autonomous vehicle platform
- 📊 ISO 26262 functional safety compliance
- 🔍 Full requirements traceability (V-Model)
- ✅ Evidence-based development
- 🛠️ Official Eclipse TSF tools

---

## 🏗️ Hardware Platform

| Component | Specification |
|-----------|---------------|
| **Platform** | PiRacer Standard/Pro |
| **Compute** | Raspberry Pi 5 (4GB/8GB) |
| **Display** | 1200x480 touchscreen (Qt HMI) |
| **Sensors** | Camera, speed sensor, IMU |
| **Power** | Expansion board |
| **Custom** | Acrylic/steel mounting system |

---

## 💻 Software Stack

### Operating System
- **Current:** Raspberry Pi OS (Bookworm)
- **Target:** Automotive Grade Linux (AGL)

### Real-Time OS
- **Selected:** ThreadX (Azure RTOS) - ISO 26262 certified

### GUI Framework
- **Framework:** Qt 6.x
- **Language:** C++ (evaluating Rust)

### Requirements Management
- **Tools:** `trudag` (Eclipse Trustable) + `doorstop`
- **Standard:** ISO 26262, ASPICE
- **Framework:** TSF (Trustable Software Framework)

---

## 🚀 Quick Start (5 minutes)

### Prerequisites
```bash
# Required
python3 --version  # 3.11+
git --version
```

### 1. Clone & Setup
```bash
git clone https://github.com/SEAME-pt/Team04_DrivaPi.git
cd Team04_DrivaPi

# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate    # Windows
```

### 2. Install TSF Tools
```bash
# Install Doorstop
pip install --upgrade pip
pip install doorstop pyyaml

# Install Trustable
git clone https://gitlab.com/CodethinkLabs/trustable/trustable.git /tmp/trustable
cd /tmp/trustable
git checkout 2025.9.16
pip install .
cd -
```

### 3. Validate Requirements
```bash
# Official validation
trudag manage lint
doorstop

# Should show: ✓ All requirements validated
```

✅ **Setup complete!** See [docs/tsf/start.md](docs/tsf/start.md) for detailed instructions.

---

## 📋 Requirements Structure (V-Model)

```
reqs/
├── urd/           User Requirements       (WHAT users need)
│   └── URD-*.yml
├── srd/           System Requirements     (HOW system provides)
│   └── SRD-*.yml
├── swd/           Software Requirements   (HOW software implements)
│   └── SWD-*.yml
└── lltc/          Low-Level Test Cases   (HOW to verify)
    └── LLTC-*.yml
```

**V-Model Flow:**
```
URD → SRD → SWD → LLTC
 ↓     ↓     ↓     ↓
User  Sys  Code  Tests
```

---

## 🔄 Daily Workflow

### Create a Requirement
```bash
# Interactive
doorstop add SWD

# Manual
cp reqs/templates/SWD-template.yml reqs/swd/SWD-042.yml
nano reqs/swd/SWD-042.yml

# Validate
trudag manage lint
```

### Link Requirements (Traceability)
```bash
# Link child to parent
doorstop link SWD-042 SRD-015

# Verify
trudag manage lint
```

### Review & Approve
```bash
# Validate
trudag manage lint

# Approve (updates 'reviewed' field)
trudag manage set-item reqs/swd/SWD-042.yml

# Commit
git add reqs/swd/SWD-042.yml
git commit -m "review: Approve SWD-042"
```

### Generate Traceability Report
```bash
trudag manage migrate
trudag report export --output artifacts/traceability.zip
```

---

## 📝 Requirement Template

Every requirement must include:

```yaml
ID-XXX:
  ref: ID-XXX                    # Must match filename
  header: "Short title"
  text: "The system SHALL..."    # Use "SHALL"
  ASIL: B                        # A/B/C/D/QM
  Verification Method: Unit Test
  links: [PARENT-ID]             # Traceability
  reviewers:
    - name: "Reviewer Name"
      email: "email@example.com"
  reviewed: ''                   # Empty → SHA when approved
  active: true
  derived: false
  normative: true
  level: 1.0
```

---

## 🏷️ ASIL Levels

| ASIL | Risk | Verification |
|------|------|--------------|
| **QM** | No safety | Basic review |
| **A** | Low | + Unit tests |
| **B** | Low-Medium | + Integration tests |
| **C** | Medium | + System tests + coverage |
| **D** | High | + Independent review + HIL |

**DrivaPi Mapping:**
- **ASIL A:** Display features, logging
- **ASIL B:** Motor control, sensor processing
- **QM:** UI themes, configuration

---

## 🛠️ Essential Commands

```bash
# VALIDATION (run daily)
trudag manage lint              # Validate requirements
trudag manage migrate           # Update structure
doorstop                        # Verify links

# REQUIREMENTS
doorstop add URD                # Create requirement
doorstop edit URD-001           # Edit requirement
doorstop link SWD-001 SRD-001   # Create link

# APPROVAL
trudag manage set-item <path>  # Mark reviewed

# BASELINE
git tag -a BASELINE-V1.0 -m "Baseline v1.0"
trudag report export --output artifacts/baseline-v1.0.zip
```

---

## 📚 Documentation

### Getting Started
- **[start.md](docs/tsf/start.md)** - Setup guide
- **[reference.md](docs/tsf/reference.md)** - Quick reference (4 pages)

### Daily Use
- **[workflow.md](docs/tsf/workflow.md)** - Common workflows
- **[evidence.md](docs/tsf/evidence.md)** - Evidence collection

### Training
- **[training.md](docs/tsf/training.md)** - Full training guide
- **Pull Request Template** - `.github/PULL_REQUEST_TEMPLATE.md`

---

## 🔍 Project Status

### Hardware: 95% Complete ✅
- ✅ PiRacer assembly
- ✅ Custom mounting (acrylic/steel)
- ✅ Display integration
- ✅ Power distribution
- 🔄 Speed sensor calibration

### Software: 60% In Progress 🚧
- ✅ Qt HMI framework
- ✅ Basic display widgets
- 🔄 Sensor integration
- 🔄 Motor control
- ⏳ Camera processing
- ⏳ Autonomous navigation

### Requirements: 85% Complete ✅
- ✅ TSF framework setup
- ✅ V-Model structure
- ✅ Templates and workflows
- ✅ CI/CD validation
- 🔄 Complete traceability coverage
- ⏳ First baseline

---

## 👥 Team DrivaPi

| Name | Role | GitHub |
|------|------|--------|
| **Hugo** | Hardware & Fabrication | [@hugo](https://github.com/hugo) |
| **João** | OS & Development | [@joao](https://github.com/joao) |
| **Bernardo** | Hardware Integration | [@bernardo](https://github.com/bernardo) |
| **Miguel** | Project Management | [@miguel](https://github.com/miguel) |
| **Melanie** | GUI & Coordination | [@melanie](https://github.com/melanie) |

---

## 🎓 Standards & Compliance

### Automotive Standards
- **ISO 26262** - Functional safety
- **ASPICE** - Process assessment
- **AUTOSAR** - Architecture (planned)

### TSF Methodology
- **Evidence-Based** - All claims backed by artifacts
- **Traceability** - Full V-Model coverage
- **Official Tools** - Eclipse `trudag` + `doorstop`
- **Reproducible** - CI/CD automated validation

---

## 🔄 CI/CD Pipeline

**GitHub Actions:** `.github/workflows/tsf-validation.yml`

**On every PR:**
1. ✅ `trudag manage lint` - Validate requirements
2. ✅ `trudag manage migrate` - Update structure
3. ✅ `doorstop` - Verify links
4. 📦 Upload artifacts (traceability reports)

**Artifacts Published:**
- Traceability matrix (CSV)
- Requirement manifest (JSON)
- Trustable report (ZIP)

---

## 📊 Metrics

### Requirements Coverage
```
URD: 15  User Requirements
SRD: 28  System Requirements
SWD: 45  Software Requirements
LLTC: 45 Test Cases

Traceability: 95%
Reviewed: 80%
```

### ASIL Distribution
```
QM:   30%  (Non-safety)
ASIL A: 50%  (Low risk)
ASIL B: 20%  (Medium risk)
```

---

## 🗺️ Roadmap

### Sprint 1 (Current)
- [x] TSF framework setup
- [x] Hardware assembly
- [x] Basic Qt HMI
- [ ] Complete traceability
- [ ] First baseline

### Sprint 2
- [ ] Sensor integration
- [ ] Motor control implementation
- [ ] Unit tests (80% coverage)
- [ ] Integration tests

### Sprint 3
- [ ] Camera processing
- [ ] Lane detection
- [ ] System tests
- [ ] Performance optimization

### Sprint 4
- [ ] Autonomous navigation
- [ ] Safety validation
- [ ] Full documentation
- [ ] Final baseline

---

## 🤝 Contributing

### For Team Members

1. **Setup**: Follow `docs/tsf/start.md`
2. **Create Requirement**: Use `docs/tsf/workflow.md`
3. **Submit PR**: Use `.github/PULL_REQUEST_TEMPLATE.md`
4. **Get Review**: 2 reviewers required (ASIL B+)

### Requirement Workflow

```bash
# 1. Create branch
git checkout -b feature/swd-042

# 2. Create requirement
doorstop add SWD
doorstop edit SWD-042

# 3. Validate
trudag manage lint

# 4. Commit & PR
git add reqs/swd/SWD-042.yml
git commit -m "feat(swd): Add SWD-042"
git push origin feature/swd-042
```

---

## 📖 References

### Official Documentation
- **Eclipse Trustable:** https://codethinklabs.gitlab.io/trustable/trustable/
- **Doorstop:** https://doorstop.readthedocs.io/
- **ISO 26262:** https://www.iso.org/standard/68383.html
- **ASPICE:** https://www.automotivespice.com/

### Project Resources
- **GitHub Project:** [Team04 Board](https://github.com/orgs/SEAME-pt/projects)
- **Documentation:** [docs/](docs/)
- **Requirements:** [reqs/](reqs/)
- **Artifacts:** [artifacts/](artifacts/)

---

## 📄 License

This project is developed for educational purposes as part of the SEAME Automotive Journey program.

---

## 🆘 Support

### Quick Help
```bash
# Validation errors?
trudag manage lint 2>&1 | less

# Links broken?
doorstop

# Need reference?
cat docs/tsf/reference.md
```

### Resources
- **Documentation:** Check `docs/` folder
- **Team Standup:** Daily sync meetings
- **GitHub Issues:** Report problems

---

## 🎯 Success Criteria

**Minimum Viable Product:**
- [x] Hardware platform assembled
- [x] TSF framework operational
- [ ] Complete V-Model traceability
- [ ] Basic autonomous navigation
- [ ] Safety validation (ASIL B)
- [ ] Full documentation

**Excellence Criteria:**
- [ ] 100% requirement coverage
- [ ] 80%+ code coverage
- [ ] Automated testing
- [ ] Continuous integration
- [ ] Reproducible baselines

---

**Last Updated:** October 2025
**Repository:** https://github.com/SEAME-pt/Team04_DrivaPi
**Maintained By:** DrivaPi Team (Team04)

---

## 🌟 Quick Links

| Resource | Link |
|----------|------|
| **Setup Guide** | [docs/GETTING_STARTED.md](docs/tsf/start.md) |
| **Workflows** | [docs/WORKFLOWS.md](docs/tsf/workflow.md) |
| **Quick Reference** | [docs/TSF_REFERENCE.md](docs/tsf/reference.md) |
| **Training** | [docs/TRAINING.md](docs/tsf/training.md) |
| **Requirements** | [reqs/](reqs/) |
| **Templates** | [reqs/templates/](reqs/templates/) |
| **CI/CD** | [.github/workflows/](.github/workflows/) |
| **Artifacts** | [artifacts/](artifacts/) |

---

**Ready to start?** → [docs/tsf/start.md](docs/tsf/start.md)
