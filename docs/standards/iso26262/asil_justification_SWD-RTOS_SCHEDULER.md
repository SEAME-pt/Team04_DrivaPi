# ASIL Justification: SWD-RTOS_SCHEDULER

## 1. Requirement Summary
- **Requirement ID:** SWD-RTOS_SCHEDULER
- **Component:** RTOS Configuration & Scheduler Monitor
- **Safety Goal:** SG-06 (Deterministic Timing)
- **Related Hazard:** H-06 (Scheduling Overrun/Delay)

## 2. ASIL Decomposition & Assignment
- **Assigned ASIL:** **A**
- **Rationale:** The RTOS scheduler ensures that safety-critical control loops (Obstacle Avoidance, Speed Control) execute within their defined periods (<50ms).
  Failure of the scheduler (e.g., Priority Inversion, Deadlock, or Starvation) leads directly to Hazard **H-06**, where the vehicle reacts too slowly to an obstacle or command.

  As derived in `hara_rtos.md`, the risk assessment is:
  - **S2** (Severe - delayed stop causes collision)
  - **E2** (Very low probability)
  - **C2** (Normally controllable)
  - **Result:** **ASIL A**

## 3. Verification Strategy (ASIL A)
To meet the "Trustable" standard for ASIL A, the following verification activities are mandatory:

1. **Unit/Integration Testing:**
   - **Priority Inheritance:** Verify that high-priority tasks are not blocked indefinitely by low-priority tasks holding shared resources (Mutex testing).
   - **Deadline Monitoring:** Verify that the "Watchdog" or "Monitor" task correctly flags a violation if a critical task takes longer than its budget.
   - **Target:** 100% Path Coverage for the Monitor task logic.

2. **Static Analysis:**
   - **Target:** Zero High-Severity alerts (focus on concurrency issues, race conditions).

3. **Code Coverage:**
   - **Target:** >90% Line Coverage for the scheduling configuration and monitoring code as defined in `LLTC-SCHEDULER_COV`.

4. **Timing Analysis:**
   - System validation must measure **Jitter** and **Latency** under maximum load (Worst-Case Execution Time - WCET) to prove the <50ms guarantee.

## 4. Traceability
- **Source:** `to be added`
- **Tests:** `to be added`
