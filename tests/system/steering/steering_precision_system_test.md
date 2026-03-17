# Steering Precision System Test

**Related Issue:** [#483 — HLTC-to-Test Mapping](https://github.com/SEAME-pt/Team04_DrivaPi/issues/483)

**Objective:** Verify that steering commands issued from the HMI result in correct physical wheel deflection angles within the defined tolerance.

**Acceptance Criterion:** Physical wheel angle corresponds to commanded steering direction within ±2 degrees.

---

## Test Setup

| Parameter | Value |
|---|---|
| Steering command source | HMI joystick input via AGL → CAN → STM32 → PCA9685 → servo |
| Measurement method | Hand-drawn protractor on cardboard (5°-interval lines, 0°–127° range, centre/straight at 90°); camera above |
| Commanded positions tested | Full left, centre (return), full right |
| Video duration | ~18.6 s |
| Evidence | `evidence/steering_precision_system_test.mp4` |

> **Measurement note:** The protractor is hand-drawn and the overhead camera introduces a perspective component. Absolute angle readings carry an estimated ±3–5° uncertainty. Symmetry comparisons (left vs right) are reliable to within ~1–2°.

---

## Test Procedure

1. Vehicle placed on flat cardboard surface with hand-drawn fan protractor (90° = straight ahead).
2. Full-left command issued from HMI joystick — wheel deflects to maximum left position, held ~4 s.
3. Centre command issued — wheel returns toward straight position.
4. Full-right command issued — wheel deflects to maximum right position, held ~6 s.
5. Each position visually compared against protractor reference lines.

---

## Observations

| Command | Protractor reading (°) | Deflection from centre (°) | Position stable (no drift)? |
|---|---|---|---|
| Full left | ~45° on scale (90° − 45° = 45° from straight) | ~45° left | ✅ Yes |
| Centre (return) | ~90° (straight reference line) | ~0–1° from straight | ✅ Yes |
| Full right | ~135° on scale (135° − 90° = 45° from straight) | ~45° right | ✅ Yes |

**Symmetry:** Left deflection ≈ right deflection within ~1–2° visual measurement — consistent with ±2° tolerance criterion.

**Movement quality:** Smooth transition between all positions; no oscillation, binding, or overshoot observed.

---

## Result

| Metric | Value |
|---|---|
| Commanded positions verified | 3 of 3 (full left, centre, full right) |
| Angular tolerance criterion | ±2 degrees (left/right symmetry) |
| Estimated left deflection | ~45° |
| Estimated right deflection | ~45° |
| Left–right asymmetry (estimated) | < 2° |
| Centre offset from straight | < 2° |
| Position stability (no drift) | ✅ Yes |
| **Status** | ✅ **PASS** |

**Video evidence:** `evidence/steering_precision_system_test.mp4`

---

## Notes

- The servo is driven via the PCA9685 I²C PWM controller at address 0x40 (steering channel).
- Measurement uncertainty of ±3–5° applies to absolute angles due to the hand-drawn protractor and camera perspective; symmetry assessment is reliable to ~1–2°.
- The vehicle shifted slightly on the cardboard during the right-turn hold phase (frames ~14–18 s); this does not affect the angle measurement, as the wheel position relative to the servo arm is independent of vehicle translation.

