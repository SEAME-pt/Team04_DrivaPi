# ASIL Justification: SWD-010

**Date:** 2025-11-12 | **Author/Reviewer:** Miguel/Gaspar | **ASIL Target:** QM

## 1. Requirement Summary
- **ID/Description:** SWD-010 - Motor speed sensor driver shall read GPIO pulses and convert to RPM.
- **Related HARA/Safety Goal:** hara-motor-speed.md; N/A

## 2. ASIL Assignment & Decomposition
- **Assigned ASIL:** A - Derived from HARA (S1 + E2 + C1 = QM)
- **Justification:** This requirement implements motor speed monitoring addressing hazard H-01.

## 3. Risk Assessment Summary
| Factor | Classification | Justification/Evidence |
|:---|:---|:---|
| Severity (S) | S1 | Motor overheats - minor burn risk |
| Exposure (E) | E2 | Extended tests ~2-5% of operation |
| Controllability (C) | C1 | Operator observes and stops immediately |

## 4. Verification Requirements (QM)
- **Unit/Integration Testing:** 5 unit tests (Target: ≥70% coverage)
- **Static Analysis:** cppcheck: 0 errors
- **Code Review:** 1 independent reviewer (Joao Gaspar)

## 5. Review Notes & Dependencies
- **Dependencies:** GPIO driver, emergency stop system
- **Review:** 

**References:** ISO 26262-9:2018