# HARA: HMI Display System

## 1. Item Definition & Assumptions
- **Item:** Qt-based Driver Dashboard.
- **Function:** Displays real-time status, warnings, and alerts.
- **Operational Context:** Operator monitoring during tests.
- **Assumption:** Trained operators; audible backups.

## 2. Hazard Analysis
We identified one primary hazard related to HMI.

| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-07** | **Stale or Inaccurate Display** (HMI shows outdated/wrong data) | Operator relying on dashboard for decisions. | Data staleness or refresh failure causing misjudgment. |

## 3. Risk Assessment (ISO 26262)
### Severity (S)
* **Score:** **S1** (Light to moderate injuries)
* **Rationale:** Misjudgment leads to minor delay in intervention (S1 per Annex B, no severe outcome in lab).

### Exposure (E)
* **Score:** **E3** (Low to medium probability, 10-50%)
* **Rationale:** HMI relied on frequently but not solely (E3 as "occasional" per Table B.2).

### Controllability (C)
* **Score:** **C1** (Simply controllable)
* **Rationale:** Operator cross-checks with direct observation (C1 as "99% avoidable" per Table B.4).

### Calculation
**S1 + E3 + C1 = QM**.
*(Based on ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
Based on H-07, we derive the following Safety Goal:

| SG ID | ASIL | Description |
|:---|:---|:---|
| **SG-07** | **QM** | **Fresh Display:** Validate data <1s old or show warning. |
