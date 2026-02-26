# HARA: Overall Performance System

## 1. Item Definition & Assumptions
- **Item:** Autonomous Driving Loop.
- **Function:** Maintains stable control at speed using Proportional-Integral-Derivative (PID) and sensors.
- **Operational Context:** Autonomous mode on track.
- **Assumption:** Tuned for max 4 m/s; lab safety barriers.

## 2. Hazard Analysis
We identified one primary hazard related to performance.

| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-10** | **Control Instability** (Unstable autonomous driving) | At speed in autonomous mode. | Poor PID tuning or loop errors causing wobble/crash. |

## 3. Risk Assessment (ISO 26262)
### Severity (S)
* **Score:** **S1** (Light to moderate injuries)
* **Rationale:** Instability causes minor lab incident (S1 per Annex B, low mass/speed).

### Exposure (E)
* **Score:** **E3** (Low to medium probability, 10-50%)
* **Rationale:** Autonomous tests frequent but supervised (E3 as "low" per Table B.2).

### Controllability (C)
* **Score:** **C1** (Simply controllable)
* **Rationale:** Operator overrides easily (C1 as "99% avoidable" per Table B.4).

### Calculation
**S1 + E3 + C1 = QM**.
*(Based on ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
Based on H-10, we derive the following Safety Goal:

| SG ID | ASIL | Description |
|:---|:---|:---|
| **SG-10** | **QM** | **Stable Performance:** Ensure smooth control <4 m/s or degrade mode. |
