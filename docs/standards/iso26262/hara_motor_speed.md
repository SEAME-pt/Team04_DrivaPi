# HARA: Motor Speed Monitoring System

## 1. Item Definition & Assumptions
- **Item:** DrivaPi Speed Sensor Software Component.
- **Function:** Reads hall-effect encoder, calculates/reports velocity.
- **Operational Context:** Lab or controlled test track.
- **Assumption:** Small-scale vehicle; trained operators recognize cues (noise/vibration).

## 2. Hazard Analysis
| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-01** | **False Zero Speed Indication** (Reports 0 m/s while moving) | Maintenance/tuning near vehicle. | Bug (overflow, timeout) freezing speed at 0. |

## 3. Risk Assessment (ISO 26262)
### Severity (S)
* **Score:** **S1** (Light to moderate injuries)
* **Rationale:** Minor friction burns/cuts from wheel (S1 per Annex B).

### Exposure (E)
* **Score:** **E2** (Very low, <10%)
* **Rationale:** Software reliance rare (visual/noise primary) (E2 per Table B.2).

### Controllability (C)
* **Score:** **C1** (Simply controllable)
* **Rationale:** Audible/vibrating motor obvious (C1 per Table B.4).

### Calculation
**S1 + E2 + C1 = ASIL A**
*(per ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
| SG ID | ASIL | Description |
|:---|:---|:---|
| **SG-01** | **A** | **Prevent False Zero Speed Reporting:** Detect invalid states and flag error instead of silent 0. |
