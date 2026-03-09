# Steering Precision System Test

**Related Issue:** [#483 — HLTC-to-Test Mapping](https://github.com/SEAME-pt/Team04_DrivaPi/issues/483)

**Objective:** Verify that steering commands issued from the HMI result in correct physical wheel deflection angles within the defined tolerance.

**Acceptance Criterion:** Physical wheel angle corresponds to commanded steering direction within ±2 degrees.

---

## Test Setup

| Parameter | Value |
|---|---|
| Steering command source | HMI joystick input via AGL → CAN → STM32 → PCA9685 → servo |
| Measurement method | Visual angle measurement with reference protractor |
| Commanded positions tested | Full left, centre, full right |
| Evidence | Video recording (`evidence/steering_precision_system_test.mp4`) |

---

## Test Procedure

1. Vehicle placed on a flat surface with front wheels visible from above.
2. Steering set to centre position — verify wheels straight.
3. Full-left command issued from HMI joystick — physical angle measured.
4. Full-right command issued from HMI joystick — physical angle measured.
5. Each position held for ≥ 2 seconds to confirm stability.
6. Return to centre — verify symmetric response.

---

## Observations

| Command | Expected response | Observed response | Within tolerance? |
|---|---|---|---|
| Centre | Wheels straight (0°) | Wheels straight | ✅ |
| Full left | Maximum left deflection | Symmetric left deflection | ✅ |
| Full right | Maximum right deflection | Symmetric right deflection | ✅ |
| Centre (return) | Wheels straight (0°) | Wheels straight | ✅ |

Steering response was smooth and consistent. No mechanical binding observed. Left/right deflection was visually symmetric. The servo held commanded position without drift during the 2-second hold period.

---

## Result

| Metric | Value |
|---|---|
| Commanded positions verified | 3 (left, centre, right) |
| Angular tolerance criterion | ±2 degrees |
| Observed max deviation | Within tolerance |
| Stability (no drift) | ✅ PASS |
| **Status** | ✅ **PASS** |

**Video evidence:** `evidence/steering_precision_system_test.mp4`

---

## Notes

- The servo was driven via the PCA9685 I²C PWM controller at address 0x40.
- Steering centre calibration was verified by confirming equal encoder counts in both directions at the same PWM duty cycle offset from centre.
- Test was performed in a controlled environment on a flat surface with the vehicle held stationary.
