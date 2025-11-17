# Raspberry Pi 5 (16GB) System — Power Summary

This document is a cleaned-up, readable version of the power analysis for the Raspberry Pi 5 based system and the supporting microcontroller/motor block. Tables, totals, runtime estimates and recommended protections are included.

---

## Contents
- Block 1 — Raspberry Pi system (5 V domain)
- Block 2 — STM32 + sensors + servo + motors
- Totals, rail requirements and runtime estimates
- Battery configuration options
- Recommended protections, converters and wiring

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
| **TOTAL (Block 1)** | **20.1–23.1 W** | **28–30 W** | |

Rail requirement (5 V): 6–8 A recommended (allow for millisecond spikes).  
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

## Power conversion & battery input (example: 3S Li-ion pack ~11.1 V nominal)

Assume DC‑DC buck converters with ~90% efficiency.

Block 1 (5 V rail)
- Peak power to Pi system: 30–40 W
- Input current from 11.1 V pack (90% eff):
  - Typical: 33 W → 33 / 11.1 / 0.9 ≈ 3.3 A
  - Peak: 40 W → 40 / 11.1 / 0.9 ≈ 4.0 A

Block 2 (6–7 V motor rail)
- Peak power: ~40 W
- Input current from 11.1 V pack (90% eff): ≈ 4.0 A

Pack energy example
- 3S pack (11.1 V) × 4.8 Ah ≈ 53 Wh
- Runtime at 40 W draw ≈ 53 / 40 ≈ 1.3 h (full-load)
- At average ~20 W system draw ≈ 2.5 h

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
   - Use a 3S BMS with cell balancing, over/under voltage and overcurrent protection.
   - Rated for continuous current above expected continuous draw (recommend ≥10 A) and peak current above expected peaks.

2. Fuses
   - Main pack fuse (fast-blow or automotive blade): ~12–15 A recommended depending on expected peaks.
   - Optional branch fuses for Pi rail and motor rail.

3. Buck converters
   - Pi rail: 5 V, choose a converter rated ~12 A (or higher) to allow margin.
   - Motor/servo rail: 6–7 V, choose converter rated ~10 A (or higher).
   - Prefer modules with thermal shutdown and current limiting.

4. Capacitors / decoupling
   - Pi rail: 470–1000 µF low-ESR electrolytic at buck output.
   - Motor/servo rail: 1000 µF+ low-ESR capacitors near the motors/servo to absorb spikes and prevent brownouts.

5. Current & voltage monitoring
   - Use a pack voltage monitor and a current sensor (shunt or hall) to log/alert for overcurrent or low-voltage conditions.

6. Wiring & connectors
   - Use appropriately sized wires (e.g., 14–12 AWG for 10–15 A runs).
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

If you want, I can:
- produce a printable README.md with this layout and finer formatting,
- generate a parts list with example model numbers,
- or create wiring diagrams (text-based) for both single-pack and dual-pack setups.