# Speed Accuracy System Test

**Related Issue:** [#396 - System Test Validation](https://github.com/SEAME-pt/Team04_DrivaPi/issues/396)

**Objective:** Verify that the speed shown on the HMI display matches the real physical speed of the vehicle.

**Acceptance Criterion:** Speed deviation is within tolerance (< 5%).

---

## Test Setup

| Parameter | Value |
|---|---|
| Fixed distance | 2 m |
| Measurement tool | Stopwatch (precision: 0.1 s) |
| Speed samples | 10 readings received from **KUKSA** data broker **during** the 2 m run |

### Distance Evidence

<img width="500" src="https://github.com/user-attachments/assets/c4a21099-5b7a-41a6-84a3-7ff679a8e3bc"/>

<img width="500" src="https://github.com/user-attachments/assets/326b94ff-2980-4830-a904-5e94d16ddd03"/>

---

## Raw Measurements

### Display Speed Samples (received from KUKSA during the 2 m run)

| Sample Group | Speed (m/s) | Count |
|---|---|---|
| Group A | 1.0176 | × 6 |
| Group B | 1.04587 | × 2 |
| Group C | 1.03173 | × 2 |

**Average display speed:**

$$\bar{v}_{display} = \frac{(1.0176 \times 6) + (1.04587 \times 2) + (1.03173 \times 2)}{10} = \frac{10.2608}{10} = 1.02608 \ \text{m/s}$$

### Physical Speed (Stopwatch)

$$v_{physical} = \frac{d}{t} = \frac{2}{1.9} \approx 1.0526 \ \text{m/s}$$

---

## Results

| Metric | Value |
|---|---|
| Average display speed | 1.02608 m/s |
| Physical speed (stopwatch) | 1.0526 m/s |
| Absolute deviation | $\lvert v\_{\text{physical}} - \bar{v}\_{\text{display}}\rvert = \lvert 1.0526 - 1.02608\rvert = 0.02652 \ \text{m/s}$ |
| **Relative deviation** | $\delta = \dfrac{v_{\text{physical}} - \bar{v}\_{\text{display}}}{v\_{\text{physical}}} \times 100 = \dfrac{0.02652}{1.0526} \times 100 \approx \textbf{2.52\%}$ |
| Tolerance threshold | < 5 % |
| **Status** | ✅ **PASS** |

### Cross-check

Calculating expected time from average display speed:

$$t_{expected} = \frac{d}{\bar{v}_{display}} = \frac{2}{1.02608} \approx 1.949 \ \text{s}$$

This is very close to the measured 1.9 s, confirming consistency between display and physical measurements.

---

## Notes

- Stopwatch precision is limited to 0.1 s, which is the main source of measurement uncertainty.
- The real physical speed is likely closer to the peak display speed (≈ 1.047 m/s), which would reduce the deviation further.
- Tests were performed in a controlled environment as required.
