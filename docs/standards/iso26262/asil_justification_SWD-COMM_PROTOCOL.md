# ASIL Justification: SWD-COMM_PROTOCOL

## 1. Requirement Summary
- **Requirement ID:** SWD-COMM_PROTOCOL
- **Component:** Communication Protocol (`comm_protocol.c`)
- **Safety Goal:** SG-08 (Reliable Comms)
- **Related Hazard:** H-08 (Communication Loss/Failure)

## 2. ASIL Decomposition & Assignment
- **Assigned ASIL:** **A**
- **Rationale:** The communication protocol is the primary interface for receiving control commands (Steering, Speed) from the HMI/Planner.
  Failure of this component (e.g., dropped packets, corrupted data without detection, or unhandled timeouts) directly leads to Hazard **H-08**, where the vehicle may continue executing the last known command ("stale data") or fail to stop.

  As derived in `hara_comms.md`, the risk assessment is:
  - **S2** (Severe/survival uncertain - potential collision)
  - **E3** (Low to medium probability)
  - **C2** (Normally controllable)
  - **Result:** **ASIL A**

## 3. Verification Strategy (ASIL A)
To meet the "Trustable" standard for ASIL A, the following verification activities are mandatory:

1. **Unit Testing:**
   - Must verify **Packet Integrity**: CRC calculation and validation logic.
   - Must verify **Timeout Handling**: Ensure internal counters increment and trigger error flags when data stream stops.
   - Must verify **Rejection Logic**: Invalid or unknown CAN IDs must be discarded safely.
   - **Target:** 100% Branch Coverage for critical parsing logic.

2. **Static Analysis:**
   - Must run CodeQL or equivalent.
   - **Target:** Zero High-Severity alerts (specifically buffer overflows or memory leaks in packet buffers).

3. **Code Coverage:**
   - **Target:** >90% Line Coverage as defined in `LLTC-COMM_COV`.

4. **Fault Injection:**
   - Integration tests must simulate a "cable disconnect" or "noise burst" to verify the system transitions to the Safe State (Stop/Degraded) within 100ms.

## 4. Traceability
- **Source:** `to be added`
- **Tests:** `to be added`
