# HARA: Obstacle Detection System

## 1. Item Definition & Assumptions
- **Item:** Computer Vision (Primary) with Ultrasonic Sensor Fallback for Obstacle Detection.
- **Function:** Primarily recognizes obstacles via vision pipeline; falls back to ultrasonic for distance confirmation.
- **Operational Context:** Autonomous mode in lab/track; low speeds (<4 m/s).
- **Assumption:** Vehicle is small-scale; operators nearby for intervention.

## 2. Hazard Analysis
We identified one primary hazard related to obstacle detection.

| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-04** | **Missed Obstacle Detection** (System fails to detect/respond to obstacle) | Vehicle approaching obstacle in autonomous mode. | Vision pipeline error (low confidence, misdetection) or fallback sensor noise/failure causing no trigger. |

## 3. Risk Assessment (ISO 26262)
### Severity (S)
* **Score:** **S1** (Light to moderate injuries)
* **Rationale:** Small vehicle/low speed limits harm to minor bruises or cuts from impact; no fatal risk (per ISO Annex B, S1 for non-life-threatening in controlled env).

### Exposure (E)
* **Score:** **E3** (Low to medium probability, ~10-50%)
* **Rationale:** Obstacles in tests are common but not every run; autonomous mode not continuous (E3 as "occasional" per Table B.2, lab use < daily driving).

### Controllability (C)
* **Score:** **C1** (Simply controllable)
* **Rationale:** Operator in lab can easily see/hear and intervene (E-stop); high visibility (C1 as "99% of drivers can avoid" per Table B.4).

### Calculation
**S1 + E3 + C1 = ASIL A**
*(Based on ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
Based on H-04, we derive the following Safety Goal:

| SG ID | ASIL | Description |
|:---|:---|:---|
| **SG-04** | **A** | **Reliable Obstacle Detection:** Vision (primary) must detect obstacles with >80% confidence; fallback to ultrasonic <50cm and trigger avoidance within 150ms, or flag error. |
