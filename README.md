# SEAME Automotive Journey

Documentation of our journey building an autonomous vehicle platform using PiRacer as part of the SEAME automotive program.

## Team: DrivaPi (Team04)
Hugo, João, Bernardo, Miguel, Melanie

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
- **Scribe rotation:** João → Hugo → Melanie → Bernardo → Miguel

All stand-ups documented in `/documents/standups/`

See our [Stand-Up Guide](documents/standups/stand-up-guide.md) for details.

## Requirements & TSF onboarding

We follow the Trustable Software Framework (TSF) approach for requirements, traceability and release baselining. For authors and reviewers:

- Training and quick-start: `docs/tsf/TSF-training.md`
- Requirements management workflow: `docs/tsf/REQS_WORKFLOW.md`
- Quick reference (cheat-sheet): `docs/tsf/TSF-quick-reference.md`
- Templates: `reqs/templates/` (create new items using Doorstop or copy templates manually; e.g. `doorstop add SWD` or `cp reqs/templates/SWD-template.yml reqs/swd/SWD-001.yml`)
 - Templates: `reqs/templates/` (use Doorstop interactive mode or copy templates from `reqs/templates/` to create new items)
 - Linter: Use the official TSF tools for validation — `trudag manage lint` and `doorstop` are the supported commands. Convenience helper scripts were previously present in the repository but have been removed to enforce an official-only workflow; see `docs/ops/trudag-official.md` for guidance and optional restore instructions.

Follow the workflow doc for authoring, review, approval and creating Trustable reports with trudag.

## Progress Timeline

**Day 1 (Oct 8, 2025):** Hardware setup, assembly started, technology research
*[Log: documents/october08.md] | [Stand-up: documents/standups/2025-10-08.md]*

**Day 2 (Oct 9, 2025):** Hardware assembly finalized with custom parts
*[Log: documents/october09.md] | [Stand-up: documents/standups/2025-10-09.md]*

**Day 3 (Oct 10, 2025):** Custom builds (acrylic/steel mounts), Qt app created, ThreadX selected
*[Log: documents/october10.md] | [Stand-up: documents/standups/2025-10-10.md]*

**Day 4 (Oct 13, 2025):** Sprint 1 begins, stand-up process launched, AGL deployment
*[Log: documents/october14.md] | [Stand-up: documents/standups/2025-10-14.md]*

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
- Speed sensor mount design in progress
- Display integration ongoing

**Software:** Development environment setup
- AGL build ready for deployment
- Qt application restructuring
- GitHub project structure established

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

- **Hugo:** Hardware assembly and custom fabrication
- **João:** Operating system and development environment
- **Bernardo:** Hardware integration and testing
- **Miguel:** GitHub project, Agile/Scrum methodologies
- **Melanie:** GUI development and team coordination

---

*Educational project following automotive industry best practices*
