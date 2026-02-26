# HARA: Communication System

## 1. Item Definition & Assumptions
- **Item:** STM32-RPi5 Bidirectional Comms (CAN/Protocol).
- **Function:** Exchanges control and status data.
- **Operational Context:** Continuous during operation.
- **Assumption:** No malicious attacks; lab network.

## 2. Hazard Analysis
We identified one primary hazard related to comms.

| ID | Hazard Description | Operational Situation | Cause of Hazard |
|:---|:---|:---|:---|
| **H-08** | **Communication Loss/Failure** (Loss of control signals) | During autonomous control. | Timeout, stale frames, or protocol error causing no response. |

## 3. Risk Assessment (ISO 26262)
### Severity (S)
* **Score:** **S2** (Severe/survival uncertain)
* **Rationale:** Loss could cause brief uncontrolled motion (S2 per Annex B for potential collision in lab).

### Exposure (E)
* **Score:** **E3** (Low to medium probability, 10-50%)
* **Rationale:** Comms failures occasional in tests (E3 as "low" per Table B.2, not high like production).

### Controllability (C)
* **Score:** **C2** (Normally controllable)
* **Rationale:** Operator can E-stop; not immediate catastrophe (C2 as "90% avoidable" per Table B.4).

### Calculation
**S2 + E3 + C2 = ASIL A**.
*(Based on ISO 26262 Part 3 Table 4)*

## 4. Safety Goals (SG)
Based on H-08, we derive the following Safety Goal:

| SG ID | ASIL | Description |
|:---|:---|:---|
| **SG-08** | **A** | **Reliable Comms:** Detect loss and failsafe to stop within 100ms. |
