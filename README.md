# SEAME Automotive Journey

Documentation of our journey building an autonomous vehicle platform using PiRacer as part of the SEAME automotive program.

## Team: DrivaPi (Team04)
Hugo, Gaspar, Bernardo, Miguel, Melanie

## What We're Building

An autonomous 1/10 scale vehicle with:
- Computer vision and autonomous driving
- Real-time control systems (ThreadX RTOS)
- Professional Qt-based monitoring interface
- Automotive industry standard architecture

**Platform:** PiRacer with Raspberry Pi 5

## Technology Stack

**Hardware:**
- Raspberry Pi 5
- Camera module
- Speed sensors
- Custom 3D-printed and laser-cut parts

**Software:**
- OS: Automotive Grade Linux (AGL)
- RTOS: ThreadX
- Programming: C++ with Rust evaluation
- GUI: Qt framework
- Standards: AUTOSAR and ISO 26262 principles

**Also investigating:**
- TSF: Trustable Software Framework (investigation and planned integration)

## Repository Structure

```
├── documents/
│   └── standups/          # Daily stand-up notes
│       ├── daily-log-template.md    # Daily template
│       ├── stand-up-guide.md
│       └── YYYY-MM-DD.md  # Daily stand-up notes
├── photos/                # Progress photos
└── README.md             # This file
```

## Team Practices

### Daily Stand-Ups
We conduct two daily sessions to stay synchronized:
- **Morning:** Quick sync when team is complete (~10 min)
- **Evening:** Progress review before departure (~15 min)
- **Facilitator:** Melanie
- **Scribe rotation:** Gaspar → Hugo → Melanie → Bernardo → Miguel

All stand-ups documented in `/documents/standups/`

See our [Stand-Up Guide](documents/standups/stand-up-guide.md) for details.

## Progress Timeline

**Day 1 (Oct 8, 2025):** Hardware setup, assembly started, technology research
*[Stand-up: documents/standups/2025-10-08.md]*

**Day 2 (Oct 9, 2025):** Hardware assembly finalized with custom parts
*[Stand-up: documents/standups/2025-10-09.md]*

**Day 3 (Oct 10, 2025):** Custom builds (acrylic/steel mounts), Qt app created, ThreadX selected
*[Stand-up: documents/standups/2025-10-10.md]*

**Day 4 (Oct 13, 2025):** Sprint 1 begins, stand-up process launched, AGL deployment
*[Stand-up: documents/standups/2025-10-14.md]*

**Day 5 (Oct 14, 2025):** Speed sensor fitting test (hole misalignment), powered car via expansion board, migrated docs to GitHub, continued AGL setup and Qt deployment.
*[Stand-up: documents/standups/2025-10-14.md]*

**Day 6 (Oct 15, 2025):** AGL running (Wi‑Fi pending), camera connected, Qt deployment and TSF→SDV automation in progress.
*[Stand-up: documents/standups/2025-10-15.md]*

## Current Sprint

**Sprint 1:** October 13-25, 2025
**Goal:** Establish software foundation and complete hardware integration

**Focus Areas:**
- Deploy AGL on Raspberry Pi 5
- Complete display integration
- Finalize speed sensor mounting
- Restructure Qt application for real-time data
- Establish development workflow and stand-up routine

## Current Status

**Hardware:** ~90% complete
- Speed sensor mount nearly finished; print file sent to Maria.
- Display integration ongoing.
- Camera connected and tested.
- Expansion board powering devices; observed low-voltage warnings — power distribution plan required.

**Software:** Development environment & deployment
- AGL build ready for deployment; AGL is running on a device but Wi‑Fi requires missing binaries and follow-up.
- Qt application restructuring and deployment pipeline (cross‑compile + SSH flashing) in progress.
- TSF → SDV: active investigation (Doorstop, Trudag) and initial automation plans via GitHub Actions.
- GitHub project structure established.

**Process:** Stand-up system launched (Week 1)
- Daily morning + evening sessions
- Documentation framework in place
- Blocker tracking active

## Key Decisions Made

- ✅ **RTOS:** ThreadX selected
- ✅ **GUI Framework:** Qt confirmed
- ✅ **OS:** AGL (Automotive Grade Linux) - deployment in progress
- 🔄 **Language:** C++ vs Rust - prototyping both

## Team Roles

- **Hugo:** Hardware assembly and custom fabrication, Qt deployment
- **Gaspar:** AGL lead (OS deployment and debugging).
- **Bernardo:** Hardware integration lead, power & wiring troubleshooting.
- **Miguel:** GitHub project, Agile/Scrum methodologies, TSF lead — mapping TSF tenets/assertions into SDV, and GitHub Actions automation for TSF→SDV.
- **Melanie:** GUI lead and TSF implementation support; documentation and team coordination

---

*Educational project following automotive industry best practices*
