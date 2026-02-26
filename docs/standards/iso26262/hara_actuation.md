# HARA: Vehicle Actuation System

## 1. Item Definition & Assumptions
- **Item:** Vehicle Actuation System (DC Motor & Servo via PCA9685 PWM).
- **Function:** Converts digital commands into physical propulsion and steering.
- **Operational Context:** Lab/test track; low speeds (<4 m/s); supervised operation.
- **Assumption:** Small-scale vehicle; trained operators present.

## 2. Hazard Analysis
| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-02** | **Unintended Acceleration** | Vehicle stopped or moving slowly. | Invalid PWM calculation causing uncommanded motion. |
| **H-03** | **Unintended Steering** | Vehicle moving. | Invalid servo PWM causing sudden angle change. |

## 3. Risk Assessment (ISO 26262)
### H-02: Unintended Acceleration
* **Severity (S):** **S1** (Light to moderate injuries)
* **Rationale:** Low torque/speed limits harm to minor bruises (S1 per Annex B).
* **Exposure (E):** **E3** (Low to medium, 10-50%)
* **Rationale:** Propulsion used in tests but intermittent (E3 per Table B.2).
* **Controllability (C):** **C2** (Normally controllable)
* **Rationale:** Operator E-stop/brake available (C2 per Table B.4).

### H-03: Unintended Steering
* **Severity (S):** **S1** (Light to moderate injuries)
* **Rationale:** Sudden steer causes minor drift (S1 per Annex B).
* **Exposure (E):** **E3** (Low to medium, 10-50%)
* **Rationale:** Steering in maneuvers (E3 per Table B.2).
* **Controllability (C):** **C2** (Normally controllable)
* **Rationale:** Visual feedback/quick reaction (C2 per Table B.4).

### Calculation
**S1 + E3 + C2 = ASIL A** for both.
*(per ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
| SG ID | Linked Hazard | ASIL | Description |
|:---|:---|:---|:---|
| **SG-02** | H-02 | **A** | **Safe Propulsion:** Clamp speed requests to +/-100% and ensure 0.0 maps to stop. |
| **SG-03** | H-03 | **A** | **Safe Steering:** Clamp angles [0,180] to prevent binding. |
