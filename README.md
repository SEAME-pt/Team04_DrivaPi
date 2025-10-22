# SEAME Automotive Journey

Autonomous vehicle using PiRacer as part of the SEAME automotive program.

## Team: DrivaPi (Team04)
Hugo, João, Bernardo, Miguel, Melanie

---

## 🎯 What We're Building

- Computer vision and autonomous driving
- Real-time control systems (ThreadX RTOS)
- Qt-based interface
- Automotive industry standard architecture
- **Requirements management with TSF**

**Platform:** PiRacer with Raspberry Pi 5

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **OS** | Automotive Grade Linux (AGL) |
| **RTOS** | ThreadX |
| **Language** | C++ (+ Rust evaluation) |
| **GUI** | Qt framework |
| **Requirements** | TSF (Trustable Software Framework) |
| **Standards** | ISO 26262 |

---

## 📁 Repository Structure

```
.
├── reqs/                  # TSF Requirements
│   ├── urd/              # User Requirements
│   ├── srd/              # System Requirements
│   ├── swd/              # Software Design
│   └── lltc/             # Test Cases
│
├── src/                  # Source code
├── tests/                # Unit/integration/system tests
├── docs/                 # Documentation
│   ├── standups/        # Daily stand-ups
│   └── tsf/             # TSF docs
│
├── artifacts/
│   ├── trustable-report/ # TSF reports
│   ├── verification/     # Test results, analysis
│   └── baselines/        # Release snapshots
│
└── .dotstop.dot          # TSF traceability graph
```

---

## 🚀 Quick Start

### Setup TSF (15 min)

```bash
# Clone
git clone https://github.com/SEAME-pt/Team04_DrivaPi.git
cd Team04_DrivaPi

# Install trudag
python3 -m venv .venv
source .venv/bin/activate
pip install pyyaml
git clone https://gitlab.com/CodethinkLabs/trustable/trustable.git /tmp/trustable
cd /tmp/trustable && git checkout 2025.9.16 && pip install . && cd -

# Validate
trudag manage lint
trudag score
trudag publish --output-dir artifacts/trustable-report
```

**Complete guide:** [docs/tsf/start.md](docs/tsf/start.md)

---

## 📋 TSF Documentation

| Doc | When to Use | Time |
|-----|-------------|------|
| **[start.md](docs/tsf/start.md)** | First time, setup | 15 min |
| **[reference.md](docs/tsf/reference.md)** | Cheat sheet, commands | Reference |
| **[workflow.md](docs/tsf/workflow.md)** | Create requirements, review | Reference |
| **[training.md](docs/tsf/training.md)** | Understand TSF/ISO 26262 theory | 1-2h |
| **[evidence.md](docs/tsf/evidence.md)** | Link artifacts | Reference |

### Essential Commands

```bash
source .venv/bin/activate                        # ALWAYS first
trudag manage create-item SWD 042 reqs/swd      # Create requirement
trudag manage create-link SWD-042 SRD-015       # Link (child→parent)
trudag manage lint                               # Validate
trudag manage set-item SWD-042                   # Mark as reviewed
trudag publish --output-dir artifacts/trustable-report  # Generate report
```

---

## 👥 Team Practices

### Daily Stand-Ups

- **Morning:** Quick sync (~10 min)
- **Evening:** Progress review (~15 min)
- **Facilitator:** Melanie
- **Docs:** [documents/standups/](documents/standups/)

### Workflow

1. Create branch
2. Create requirements (`trudag manage create-item`)
3. Implement (code, tests, docs)
4. Link artifacts to requirements
5. Validate (`trudag manage lint`)
6. Create PR (2 reviews for ASIL B)
7. Merge

**Commit format:** `<type>(<scope>): <description>`
- Types: `feat`, `fix`, `docs`, `test`, `review`
- Scopes: `urd`, `srd`, `swd`, `lltc`, `hmi`, `sensor`

---

## 📈 Progress

| Date | Achievement |
|------|-------------|
| Oct 8 | Hardware setup initiated |
| Oct 9 | Assembly finalized with custom parts |
| Oct 10 | Qt app created, ThreadX selected |
| Oct 13 | Sprint 1 starts, AGL deployment |
| Oct 14 | TSF framework integrated |

**Current Sprint:** Sprint 1 (Oct 13-25)
**Status:** ~90% hardware, dev environment setup, TSF operational

---

## 📊 Traceability Status

**Current baseline:** Sprint 1
- 1 example URD (User Requirements) ✅
- 1 example SRD (System Requirements) ✅
- 1 example SWD (Software Design) ✅
- 1 example LLTC (Test Cases) ✅
- 100% reviewed ✅
- Complete V-Model chain ✅

**View report:** [artifacts/trustable-report/dashboard.md](artifacts/trustable-report/dashboard.md)

---

## 📚 Standards Compliance

- **ISO 26262:** Functional safety
  - ASIL levels assigned
  - Hazard analysis
  - V-Model development

- **TSF:** Trustable Software Framework
  - Requirements traceability
  - Evidence-based trust
  - Git audit trail

---

## 👤 Team Roles

| Member | Focus |
|--------|-------|
| **Hugo** | Hardware, fabrication, QT deployment |
| **João** | OS, dev environment |
| **Bernardo** | Hardware integration, testing |
| **Miguel** | GitHub, Agile/Scrum |
| **Melanie** | GUI, coordination, requirements |

---

## 📜 License

Educational project - SEAME Automotive Program

---

*Last update: Oct 21, 2025 | Sprint 1 | Active development*
