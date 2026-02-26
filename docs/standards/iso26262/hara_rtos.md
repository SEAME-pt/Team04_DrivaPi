# HARA: RTOS Scheduling System

## 1. Item Definition & Assumptions
- **Item:** ThreadX RTOS for Control Tasks.
- **Function:** Schedules real-time tasks for deterministic execution.
- **Operational Context:** High-frequency loops in autonomous mode.
- **Assumption:** Lab setup; no extreme loads.

## 2. Hazard Analysis
We identified one primary hazard related to scheduling.

| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-06** | **Scheduling Overrun/Delay** (Critical task misses deadline) | During emergency response or control loop. | Priority inversion, overload, or RTOS misconfig causing delayed execution. |

## 3. Risk Assessment (ISO 26262)
### Severity (S)
* **Score:** **S2** (Severe/survival uncertain)
* **Rationale:** Delay in stop could cause collision with object/operator; moderate due to low speed (S2 per Annex B for potential harm).

### Exposure (E)
* **Score:** **E2** (Very low probability, <10%)
* **Rationale:** Overloads rare in tuned lab system (E2 as "improbable" per Table B.2).

### Controllability (C)
* **Score:** **C2** (Normally controllable)
* **Rationale:** Operator can intervene, but delay reduces window (C2 as "90% avoidable" per Table B.4).

### Calculation
**S2 + E2 + C2 = ASIL A**.
*(Based on ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
Based on H-06, we derive the following Safety Goal:

| SG ID | ASIL | Description |
|:---|:---|:---|
| **SG-06** | **A** | **Deterministic Timing:** Ensure control tasks execute <50ms with priority inheritance. |
