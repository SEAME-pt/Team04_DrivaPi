# Sprint 8 Review — Team04 DrivaPi

**Date:** February 2-13, 2026

**Sprint goal:** _Ensure hardware infrastructure stability, enhance infotainment features with real-time telemetry, and validate three key functional requirements (URD-SPEED_MEASUREMENT, URD-STEERING_CONTROL and URD-PROPULSION_CONTROL) through integration, system, and unit testing._

---

## Table of contents
- Summary
- Key achievements
- Decisions
- Measurements & validation
- Challenges & solutions
- Next steps (Sprint 9)
- Team highlights
- Team feedback (retrospective)
- Outcome

---

## Summary
Sprint 8 represented the final iteration of the project, with the team focused on consolidating hardware stability, advancing Qt-based infotainment features, and formally validating core functional requirements through integration and system testing. Whilst the team delivered the majority of planned work, the sprint surfaced several areas for improvement — including opportunities to strengthen inter-team communication and refine scope management — which contributed to some items, such as the emergency braking system, STM32–Qt communication, and selected physical hardware tests, carrying forward to Sprint 9.

## Key achievements
- **Hardware infrastructure:** Maintained stable hardware platform throughout the sprint, ensuring core vehicle components remained operational for testing.
- **Real-time telemetry:** Advanced infotainment telemetry features within the Qt application, improving data display and signal handling.
- **Functional requirement validation:** Made measurable progress towards validating URD-SPEED_MEASUREMENT, URD-STEERING_CONTROL, and URD-PROPULSION_CONTROL through unit and integration testing.
- **Sprint planning:** The team demonstrated solid planning capabilities, with a clearly structured backlog and well-defined acceptance criteria for each task.

## Decisions
- Carry forward incomplete emergency braking logic to Sprint 9 with dedicated ownership and a clear implementation deadline.
- Prioritise STM32–Qt communication resolution as a Sprint 9 blocker, given its impact on multiple dependent features.
- Refine sprint scope in future iterations to ensure a sustainable and achievable workload per team member.
- Strengthen inter-team communication cadence to keep parallel workstreams aligned.

## Measurements & validation
| Metric | Value | Status |
|------|------:|:-----|
| Functional Requirements Targeted | 3 (URD-SPEED_MEASUREMENT, URD-STEERING_CONTROL, URD-PROPULSION_CONTROL) | 🔄 Partial |
| Emergency Braking Implementation | Not completed | ❌ Incomplete |
| STM32–Qt Communication | Not functional | ❌ Incomplete |
| Qt Feature Completion | Partial | 🔄 In Progress |
| Physical Tests Executed | Partial — not all tests completed | 🔄 Incomplete |

## Challenges & solutions
| Challenge | Severity | Resolution |
|---|---|---|
| **Emergency braking not implemented** | High | Deferred to Sprint 9 with dedicated ownership and clear acceptance criteria |
| **STM32–Qt communication not yet functional** | High | Root cause analysis to be conducted at Sprint 9 kickoff; assigned as top priority |
| **Qt features partially complete** | Medium | Remaining features scoped into Sprint 9 backlog with refined overall scope |
| **Physical tests partially executed** | Medium | Test sessions to be rescheduled in Sprint 9 with dedicated hardware time |
| **Inter-team communication cadence** | High | Retrospective surfaced the opportunity; daily syncs to be reinforced going forward |
| **Sprint scope exceeded team capacity** | High | Sprint 9 scope calibrated to reflect team capacity and account for carryover work |

## Next steps (Sprint 9 priorities)
1. **Emergency braking logic:** Complete and validate STM32 emergency braking implementation with full TSF traceability.
2. **STM32–Qt communication:** Resolve communication pipeline between STM32 firmware and Qt telemetry display as a Sprint 9 blocker.
3. **Qt feature completion:** Deliver outstanding Qt infotainment features deferred from Sprint 8.
4. **Physical testing:** Execute all physical hardware tests in a dedicated, scheduled session.
5. **ADAS stack initiation:** Begin establishing the Camera/HAILO/CARLA stack for ADAS functionality.
6. **TSF traceability enforcement:** Enforce strict TSF traceability through real-code testing across all safety-critical components.
7. **Communication improvement:** Strengthen daily syncs and inter-role communication to keep parallel workstreams aligned.

## Team highlights
- **Bernardo:** Hardware integration, physical testing execution, and STM32 firmware work.
- **Gaspar:** Development environment stability, communication pipeline investigation, and repository upkeep.
- **Hugo:** Hardware platform maintenance, physical testing coordination, and integration support.
- **Melanie:** Qt application development, GUI coordination, telemetry feature progress, and team coordination.
- **Miguel:** Sprint planning, backlog management, Agile facilitation, and progress tracking.

## Team feedback (retrospective)

### Highlights
- **Bernardo:** The team partially met its core objectives and made meaningful progress across several areas.
- **Gaspar:** There is clear room to grow — the foundations were in place and the team showed commitment throughout.
- **Hugo:** The sprint went well overall; the team broadly delivered what had been planned.
- **Melanie:** Goals were broadly addressed, and the team maintained a strong collaborative effort despite a demanding workload.
- **Miguel:** The sprint achieved a solid baseline, with the team meeting its most critical commitments.

### Areas for improvement
- **Bernardo:** The team would benefit from more structured day-to-day coordination to maintain clarity across workstreams.
- **Gaspar:** Closer alignment between team members during execution would help bridge the gap between planning and delivery.
- **Hugo:** The planning was strong; focusing on execution discipline in the next sprint will help close the gap between intent and outcome.
- **Melanie:** Calibrating the sprint scope more carefully to available capacity would help maintain a sustainable pace.
- **Miguel:** Improved coordination across workstreams would help the team operate more cohesively and efficiently.

---

## Outcome
Sprint 8 goal **partially achieved**: the team maintained hardware stability and advanced telemetry and Qt features, whilst carrying forward selected items — including the emergency braking system, STM32–Qt communication, and remaining physical tests — into Sprint 9. The retrospective surfaced valuable insights around scope calibration and communication cadence, both of which the team is actively addressing.

The team demonstrated strong planning discipline and commitment throughout the sprint. Sprint 9 will build on this foundation by refining execution practices, improving cross-role alignment, and assigning clear ownership to carryover work.

**Foundation for Sprint 9:** The team enters Sprint 9 with a focused and realistic backlog centred on completing the vehicle's safety-critical features, validating functional requirements end-to-end, and initiating the ADAS stack.

**Next review:** Sprint 9 Review
