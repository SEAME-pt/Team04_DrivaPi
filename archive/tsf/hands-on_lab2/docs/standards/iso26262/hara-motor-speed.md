

**Date:** 2025-11-12 | **Authors/Reviewers:** Miguel/Gaspar | **ASIL Target:** QM

## 1. Item Definition & Assumptions
- **Description:** Motor speed sensor system for DrivaPi lab testing
- **Boundaries:** Motor rotation → RPM value measurement and monitoring
- **Interfaces:** GPIO hardware driver, Emergency stop button
- **Context:** Laboratory environment, trained operators only, emergency stop available
- **Assumptions:** 
  - Controlled lab environment with proper safety equipment
  - Trained operators present during all motor tests
  - Emergency stop button accessible and functional

## 2. Hazards & Operational Situations
| ID | Hazard Description | Operational Situation | Exposure (E) / Justification |
|:---|:---|:---|:---|
| H-001 | Sensor fails silently during test | Extended motor test | E2 (Low probability; extended tests represent 2-5% of total operating time) |

## 3. Risk Assessment & ASIL
- **Severity (S):** S1 - Light to moderate injuries
  - Worst outcome: Motor overheats due to undetected speed anomaly
  - Potential consequence: Minor burn risk if operator touches overheated motor
  - Classification: S1 (Light to moderate injuries - minor burns, no life-threatening harm)
  
- **Exposure (E):** E2 - Low probability (1-10% of operating time)
  - Extended motor tests occur regularly but not continuously
  - Historical data indicates approximately 2-5% of total operational time
  - Justification: A few occurrences during system lifetime
  
- **Controllability (C):** C1 - Simply controllable
  - Operator is present during all tests
  - Emergency stop button readily accessible
  - 99%+ of trained operators can avoid harm with sufficient warning
  - Recovery action: Press emergency stop button immediately

- **ASIL Calculation:** S1 + E2 + C1 = **QM** (from ISO 26262-3:2018 Table 4)
  - Per ISO 26262-3:2018, Clause 6.4.3.10, Table 4
  - Combination S1/E2/C1 results in QM

## 4. Safety Goals
| Goal ID | ASIL | Description | Safe State |
|:---|:---|:---|:---|
| SG-001 | QM | Motor speed sensor shall function reliably and accurately monitor motor RPM | Operator can monitor motor status and execute emergency stop if anomaly detected |

## 5. Dependencies & Review Notes
- **Dependencies:** 
  - Emergency stop button system (must be functional)
  - GPIO hardware driver (reliable pulse counting)
  - Operator training and presence
  - Lab environment controls
  
- **Related Requirements:** SWD-998 (Motor speed sensor implementation)
- **Review:** 


**References:** ISO 26262-3:2018 (Hazard Analysis and Risk Assessment)
