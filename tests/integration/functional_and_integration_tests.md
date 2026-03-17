# Functional vs Integration Tests — Study Note

This note explains what functional tests and integration tests are, how they differ and how to apply them to DrivaPi.

---

## Functional Tests

- Purpose: Verify that a specific function or feature behaves according to its requirement (black-box focus on behavior, not implementation details). Black-box testing means you test a system by only looking at its external behavior, what it does, without looking inside at how it works internally.
- Scope: A single feature or narrow slice of behavior. The surrounding factors are controlled so the behavior under test is clear and repeatable.
- Inputs: Clearly defined inputs (commands, signals, UI actions) and preconditions.
- Expected Results: Observable outputs/behaviors and acceptance criteria.
- Pass/Fail: Determined by matching behavior to the requirement.

DrivaPi examples:
- Given forward/backward throttle input, the car moves forward/backward.
- If an obstacle is detected by the sensor within threshold distance, the car stops.

---

## Integration Tests

- Purpose: Verify that multiple components work together correctly and respect their interface contracts.
- Scope: Two or more components connected (controller + CAN + peripheral), validating data flows and timing across boundaries.
- Inputs: End-to-end or cross-component stimuli that traverse interfaces.
- Expected Results: Correct interactions, message formats, state transitions and timing across modules.
- Pass/Fail: Based on interface and end-to-end behavior criteria.

DrivaPi examples:
- Does the Raspberry Pi send valid commands that the STM32 understands and executes correctly?
- Does the STM32 correctly control the motors when commanded by the controller?
- Does sensor feedback reach the correct component (display/controller) and trigger appropriate responses?
- Does the GUI on the Raspberry Pi successfully communicate with the controller and display real-time updates?

---

## Key Differences

| Aspect | Functional Tests | Integration Tests |
|--------|------------------|-------------------|
| **Focus** | Requirement/feature behavior | Component interactions |
| **Granularity** | Narrow slice | Cross-component slice |
| **Dependencies** | Controlled surroundings | Real interfaces between components |
| **Failure Localization** | Pinpoints behavior in one feature | Reveals interface/contract issues |
| **Test Data** | Covers feature boundaries and typical/edge cases | Covers protocol/flow/timing across modules |

---

## Minimal Test Case Template

- ID/Title: Short, descriptive name
- Objective: Requirement or interaction being verified
- Preconditions: System/setup assumptions
- Steps/Stimuli: Inputs and actions
- Expected Results: Observable outcomes and criteria
- Notes: Data sets, corner cases, measurements
