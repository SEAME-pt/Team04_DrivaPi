# HARA: Startup and Calibration System

## 1. Item Definition & Assumptions
- **Item:** Boot Sequence and Self-Calibration.
- **Function:** Initializes servo, sensors, and performs tests on startup.
- **Operational Context:** Power-on in lab.
- **Assumption:** Manual supervision during boot.

## 2. Hazard Analysis
We identified one primary hazard related to startup.

| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-09** | **Calibration/Startup Failure** (System starts in unsafe state) | Immediate post-boot operation. | Failed calibration or test causing instability. |

## 3. Risk Assessment (ISO 26262)
### Severity (S)
* **Score:** **S1** (Light to moderate injuries)
* **Rationale:** Instability post-boot leads to minor test issues (S1 per Annex B, no high impact).

### Exposure (E)
* **Score:** **E3** (Low to medium probability, 10-50%)
* **Rationale:** Boot happens per session, not constant (E3 as "occasional" per Table B.2).

### Controllability (C)
* **Score:** **C1** (Simply controllable)
* **Rationale:** Operator resets easily pre-operation (C1 as "99% avoidable" per Table B.4).

### Calculation
**S1 + E3 + C1 = QM**.
*(Based on ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
Based on H-09, we derive the following Safety Goal:

| SG ID | ASIL | Description |
|:---|:---|:---|
| **SG-09** | **QM** | **Safe Startup:** Perform self-tests and calibrate; halt if failed. |
