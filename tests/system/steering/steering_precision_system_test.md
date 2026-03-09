# Steering Precision System Test

**Related Issue:** [#483 — HLTC-to-Test Mapping](https://github.com/SEAME-pt/Team04_DrivaPi/issues/483)

**Objective:** Verify that steering commands issued from the HMI result in correct physical wheel deflection angles within the defined tolerance.

**Acceptance Criterion:** Physical wheel angle corresponds to commanded steering direction within ±2 degrees.

> ⚠️ **Note:** Measurement fields marked `[TBD]` must be filled in from the video evidence before this document can be used to assign a TSF score. See `evidence/steering_precision_system_test.mp4`.

---

## Test Setup

| Parameter | Value |
|---|---|
| Steering command source | HMI joystick input via AGL → CAN → STM32 → PCA9685 → servo |
| Measurement method | [TBD — e.g. protractor, angle ruler, visual reference] |
| Commanded positions tested | Full left, centre, full right |
| Test date | [TBD] |
| Tester | [TBD] |
| Evidence | Video recording (`evidence/steering_precision_system_test.mp4`) |

---

## Test Procedure

1. Vehicle placed on a flat surface with front wheels visible from above.
2. Steering set to centre position — verify wheels straight (0° reference).
3. Full-left command issued from HMI joystick — measure physical wheel angle.
4. Full-right command issued from HMI joystick — measure physical wheel angle.
5. Each position held for ≥ 2 seconds to confirm stability (no drift).
6. Return to centre — verify symmetric response.

---

## Observations

| Command | Expected response | Measured angle (°) | Deviation from expected (°) | Within ±2°? |
|---|---|---|---|---|
| Centre | 0° (wheels straight) | [TBD] | [TBD] | [TBD] |
| Full left | Max left deflection | [TBD] | [TBD] | [TBD] |
| Full right | Max right deflection | [TBD] | [TBD] | [TBD] |
| Centre (return) | 0° (wheels straight) | [TBD] | [TBD] | [TBD] |

Qualitative observations from video: [TBD — e.g. smooth response, no mechanical binding, symmetric deflection observed]

---

## Result

| Metric | Value |
|---|---|
| Commanded positions verified | [TBD] of 3 |
| Angular tolerance criterion | ±2 degrees |
| Observed max deviation | [TBD] ° |
| Stability (no drift) | [TBD] |
| **Status** | [TBD — PASS / FAIL] |

**Video evidence:** `evidence/steering_precision_system_test.mp4`

---

## Notes

- The servo is driven via the PCA9685 I²C PWM controller at address 0x40 (steering channel).
- Complete this document from the video recording before adding `score: MelanieReis: 1.0` to `TSF/requirements/hltc/HLTC-STEERING-ACCURACY.md`.
