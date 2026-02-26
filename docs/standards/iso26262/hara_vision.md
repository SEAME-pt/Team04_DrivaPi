# HARA: Computer Vision System

## 1. Item Definition & Assumptions
- **Item:** Hailo Pipeline for Lane and Obstacle Recognition (Primary Detection).
- **Function:** Processes camera feeds for lane detection and primary obstacle recognition; sensor as fallback.
- **Operational Context:** Autonomous driving on marked paths; lab environment.
- **Assumption:** Backup sensors (ultrasonic) available; low vehicle mass reduces impact risk.

## 2. Hazard Analysis
We identified one primary hazard related to vision processing.

| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-05** | **Lane Misdetection** (System fails to detect lane markings accurately) | Vehicle in autonomous lane-following mode. | Low light, errors in pipeline, or low confidence causing drift into hazards. |

## 3. Risk Assessment (ISO 26262)
### Severity (S)
* **Score:** **S1** (Light to moderate injuries)
* **Rationale:** Drift leads to off-path or minor bump; small vehicle/no high speed (S1 per Annex B, no survival risk).

### Exposure (E)
* **Score:** **E2** (Very low probability, <10%)
* **Rationale:** Lane mode in specific tests, not default; lab paths clear (E2 as "rare" per Table B.2).

### Controllability (C)
* **Score:** **C1** (Simply controllable)
* **Rationale:** Operator can override instantly in lab (C1 as easily avoidable per Table B.4).

### Calculation
**S1 + E2 + C1 = QM**.
*(Based on ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
Based on H-05, we derive the following Safety Goal:

| SG ID | ASIL | Description |
|:---|:---|:---|
| **SG-05** | **QM** | **Accurate Lane Detection:** System must detect lanes with >80% confidence or fallback to manual/sensors. |
