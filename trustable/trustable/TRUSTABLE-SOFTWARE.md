---
active: true
derived: false
doc:
  name: Trustable Software Framework
  ref: TSF
  title: DrivaPi Trustable Software Framework
level: 1.0
links: []
normative: true
ref: ''
reviewed: 094a2fcde0054c62020bdab6e8543fbc093abf9ebda653430a9dc41401acc601
---

# Trustable Software Framework - DrivaPi

## Purpose
This framework helps us build and prove our autonomous vehicle system is safe and trustworthy.

## Core Principles
We follow these trust principles:
- **TT-CHANGES**: Manage changes safely
- **TT-CONFIDENCE**: Show measurable safety confidence
- **TT-CONSTRUCTION**: Use proven development processes
- **TT-EXPECTATIONS**: Meet documented requirements
- **TT-PROVENANCE**: Track everything from start to finish
- **TT-RESULTS**: Produce reliable, repeatable results

## What We Cover
- RPi5 + HAILO (AI perception and planning)
- STM32 + ThreadX (real-time control)
- CAN communication between components
- Safety monitoring and fault handling

## Standards We Follow
- ISO 26262 (Automotive Safety)
- ISO 21448 (SOTIF - AI safety)

## How It Works
- Requirements link to tests and evidence
- CI pipeline automatically checks safety
- Every safety claim has proof
- Changes are tracked and validated

## Framework Structure
```
trustable/
├── trustable/ # Framework definitions
│ ├── tenets/ # Trust principles (TT-)
│ ├── assertions/ # Framework assertions (TA-A_)
│ └── TRUSTABLE-SOFTWARE.md
├── assumptions-of-use/ # Operational assumptions (AOU-*)
├── lltc/ # Low-level test cases (LLTC-*)
├── srd/ # Software requirements (SR-*)
├── swd/ # Software design (SD-*)
├── templates/ # Document templates
└── urd/ # User requirements (UR-*)
```

## Maintenance
The team reviews this quarterly and updates based on:
- New safety standards
- Lessons from testing
- Technology changes


<p>
	<img src="../../docs/tsf/TSF_Arhitecture.svg" alt="TSF Architecture Diagram" width="700">
</p>
