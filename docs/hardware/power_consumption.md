# Raspberry Pi 5 (16GB) System — Power Summary

This document is a summary of the power analysis performed for the PiRacer system. Tables, totals, runtime estimates and recommended protections are included.

---

## Contents
- Block 1 — Raspberry Pi system (5 V domain)
- Block 2 — STM32 + sensors + servo + motors
- Totals, rail requirements and runtime estimates
- Battery configuration options
- Recommended protections, converters and wiring

---

## Assumptions
- Pack nominal voltage: 11.1 V (3 × 3.7 V cells).  
- Pack fully charged voltage: 12.6 V (3 × 4.2 V cells).  
- DC‑DC converter efficiency: 90% (0.9).  
- Example pack capacity: 4.8 Ah.

---

## 🟦 BLOCK 1 — Raspberry Pi System (5 V rail)

Includes: Raspberry Pi 5 (16 GB), Hailo AI HAT, Seeed Dual-CAN HAT, USB SSD (USB 3 enclosure), Waveshare 7.9" touch display.

| Component | Typical power | Peak power | Notes |
|---|---:|---:|---|
| Raspberry Pi 5 (16GB) | 9–12 W | 14–16 W | Idle 3.5–4 W, heavy combos up to 16 W |
| Hailo AI HAT | 2.5 W | 3 W | inference device |
| Seeed Dual-CAN HAT | 0.45–0.6 W | 0.6 W | 90–120 mA @ 5 V |
| USB SSD (NVMe via USB3) | 5 W | 7 W | active/peak numbers for NVMe enclosure |
| Waveshare 7.9" touchscreen | 3 W | 3.5 W | display/backlight dependent |
| **TOTAL (Block 1)** | **21.0–23.1 W** | **28.1–30.1 W** | |

Rail requirement (5 V): 5–7 A recommended (allow for millisecond spikes).  
Practical recommendation: size 5 V buck for 12 A to give margin and account for inrush/peaks.

---

## 🟩 BLOCK 2 — STM32 + Sensors + Servo + Motors (6–7 V motor/servo rail)

Includes: STM32U585I-IT01A, LM393 speed sensor, CAN transceiver, MG996R servo, two PiRacer 37‑520 DC gearmotors.

| Component | Typical power | Peak power | Notes |
|---|---:|---:|---|
| STM32U585I-IT01A | 0.5 W | 0.5 W | MCU power |
| LM393 speed sensor | 0.01 W | 0.01 W | negligible |
| CAN transceiver | 0.2 W | 0.2 W | |
| MG996R servo (assume 6 V) | 6 W | 15 W | typical vs stall |
| PiRacer 37‑520 motor #1 (6 V) | 6 W | 12 W | no-load / under load / stall |
| PiRacer 37‑520 motor #2 (6 V) | 6 W | 12 W | |
| **TOTAL (Block 2)** | **18.7 W** | **39.7 W** | |

Rail recommendation for motors/servo: design for 7 V output (6–7 V nominal), allow 3–7 A continuous depending on usage, peaks up to ~10–15 A if multiple actuators stall simultaneously.

---

## Power conversion & battery input (example: 3S Li-ion pack)

Assume DC‑DC buck converters with 90% efficiency (0.9). Below are input current calculations for both nominal pack voltage (11.1 V) and fully charged pack voltage (12.6 V).

Using nominal voltage 11.1 V (11.1 × 0.9 = 9.99 V effective)
- Block 1 (typical 23.1 W): 23.1 / 9.99 ≈ 2.31 A  
  - Peak 30.1 W: 30.1 / 9.99 ≈ 3.01 A
- Block 2 (typical 18.7 W): 18.7 / 9.99 ≈ 1.87 A  
  - Peak 39.7 W: 39.7 / 9.99 ≈ 3.98 A
- Combined typical 41.8 W: 41.8 / 9.99 ≈ 4.19 A  
  - Combined peak 69.8 W: 69.8 / 9.99 ≈ 6.99 A

Using fully charged voltage 12.6 V (12.6 × 0.9 = 11.34 V effective)
- Block 1 (typical 23.1 W): 23.1 / 11.34 ≈ 2.04 A  
  - Peak 30.1 W: 30.1 / 11.34 ≈ 2.66 A
- Block 2 (typical 18.7 W): 18.7 / 11.34 ≈ 1.65 A  
  - Peak 39.7 W: 39.7 / 11.34 ≈ 3.50 A
- Combined typical 41.8 W: 41.8 / 11.34 ≈ 3.69 A  
  - Combined peak 69.8 W: 69.8 / 11.34 ≈ 6.16 A

Pack energy examples
- At nominal 11.1 V: 11.1 × 4.8 Ah ≈ 53.3 Wh
  - Runtime at combined peak 69.8 W: 53.3 / 69.8 ≈ 0.76 h (≈ 46 min)
  - Runtime at combined typical 41.8 W: 53.3 / 41.8 ≈ 1.27 h (≈ 1 h 16 min)
  - Runtime at 20 W average: 53.3 / 20 ≈ 2.67 h
- At fully charged 12.6 V: 12.6 × 4.8 Ah = 60.48 Wh
  - Runtime at combined peak 69.8 W: 60.48 / 69.8 ≈ 0.87 h (≈ 52 min)
  - Runtime at combined typical 41.8 W: 60.48 / 41.8 ≈ 1.45 h (≈ 1 h 27 min)
  - Runtime at 20 W average: 60.48 / 20 ≈ 3.02 h

Notes
- Use nominal (11.1 V) values for conservative continuous-current sizing. Use fully charged (12.6 V) values to check peak inrush and voltage stress.
- All currents above are input currents at pack voltage before converter losses; rail currents at 5 V or 6–7 V are higher by the appropriate voltage division.
- Use the worst-case typical values when sizing continuous supplies; use peak combined values when sizing fuses, transient handling and wiring for short-duration events.

---

## Battery configuration options

Option A — Two separate 3S packs (current plan)
- Pack 1 → Block 1 (Pi + HATs + display)
- Pack 2 → Block 2 (motors + servo + MCU)
Pros: isolation of motor spikes, easier fault containment, simpler converters per block.  
Cons: two chargers/BMS units, more wiring.

Option B — One larger pack (3S2P or 3S with parallel cells)
- 3S2P (11.1 V nominal, double capacity) gives longer runtime and higher current capacity.
- Use single 3S BMS rated for continuous current ≥ expected draw (recommend ≥10 A continuous, ≥15 A peak for this system).
Pros: simpler charging, more capacity, higher current capability.  
Cons: single point of failure if not properly fused; ensure BMS and wiring sized correctly.

---

## Recommended protections, components and wiring

1. BMS
   - Use a 3S BMS with cell balancing, over/under voltage and over current protection.
   - Rated for continuous current above expected continuous draw (recommend ≥10 A) and peak current above expected peaks.

2. Fuses
   - Main pack fuse (time‑delay/slow‑blow recommended for motor inrush): ~12–15 A depending on expected peaks.
   - Optional branch fuses for Pi rail and motor rail.

3. Buck converters
   - Pi rail: 5 V, choose a converter rated ~12 A (or higher) to allow margin.
   - Motor/servo rail: 6–7 V, choose a converter rated ~10 A (or higher).
   - Prefer modules with thermal shutdown and current limiting.

4. Capacitors / decoupling
   - Pi rail: 470–1000 µF low-ESR electrolytic at buck output.
   - Motor/servo rail: 1000 µF+ low-ESR capacitors near the motors/servo to absorb spikes and prevent brownouts.

5. Current & voltage monitoring
   - Use a pack voltage monitor and a current sensor (shunt or hall) to log/alert for over current or low-voltage conditions.

6. Wiring & connectors
   - Use appropriately sized wires (e.g., 14–12 AWG for 10–15 A runs). Derate for length and temperature.
   - Secure crimped/soldered connections and use heatshrink.
   - Route motor wires away from sensitive signal lines to reduce EMI.

7. Mechanical & thermal
   - Provide ventilation or heatsinking for high-current buck converters.
   - Mount caps and BMS away from heat sources and vibration.

---

## Quick checklist (practical parts list)
- 3S Li-ion pack (or 3S2P for more capacity)
- 3S BMS rated ≥10 A continuous, ≥15 A peak
- Inline main fuse (12–15 A)
- 5 V buck converter, 12 A rated (for Pi rail)
- 6–7 V buck converter, 10 A rated (for motors/servo)
- Low-ESR capacitors (470–1000 µF for Pi, 1000 µF+ for motors)
- Current sensor (e.g., INA219/INA3221 or hall-effect)
- Proper gauge wiring (12–14 AWG), connectors and mounting hardware

---

## Conclusions — Team decisions

- Primary decision: keep the current two-pack plan as documented.
  - Pack A → expansion (motors / servo / STM32 / CAN).
  - Pack B → Raspberry Pi + HATs + display.
  - Keep all protections and components listed above (3S BMS, main fuse, branch fuses, buck converters, low‑ESR caps, current monitoring, correct wiring gauge).

- Single‑pack / parallel option (alternative):
  - Use one full 3S pack to power everything with the protections above.
  - If extra current is needed, add a second identical pack in parallel on the expansion side to increase available amps (effectively 3S2P capacity/current). Ensure packs are matched, balanced and connected safely.
  - Required notes when paralleling packs: only parallel identical, same‑state packs; use BMSs rated for parallel operation or a single BMS designed for the combined configuration; include pre‑charge/current limiting when connecting packs to avoid large inrush; fuse each pack individually.

- Testing plan (two‑step):
  1. Documentation check: read the expansion board and individual component datasheets to confirm connector ratings, expected currents and recommended wiring/decoupling.
  2. Bench tests: measure real current draw directly on the components and on the expansion board under expected loads (idle, nominal, and stall/peak). Verify buck converter regulation, temperature, and that voltage does not brown out under peaks. Log results and adjust fuse / BMS / converter sizing accordingly.

- Action items before final deployment:
  - Implement recommended protections and fuses.
  - Perform the documentation check and bench tests described above.
  - If bench tests show higher draw than estimated, prefer the two‑pack solution or increase pack/current ratings rather than risking undersized wiring/protection.