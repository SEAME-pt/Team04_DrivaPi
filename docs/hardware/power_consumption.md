# Raspberry Pi 5 (16GB) System — Power Summary

This document summarizes the power analysis for the PiRacer system. It includes component powers, block totals, rail requirements, battery/runtime estimates, recommended protections and a testing plan. Numbers use conservative, verifiable assumptions; follow the test plan to validate for your hardware.

---

## Contents
- Block 1 — Raspberry Pi system (5 V domain)
- Block 2 — STM32 + sensors + servo + motors (motor/servo rail)
- Power conversion, battery assumptions and runtime calculations
- Battery configuration options and safety notes
- Protections, wiring and testing plan
- Team conclusions / decisions

---

## Key assumptions & conventions
- Pack nominal voltage: 11.1 V (3 × 3.7 V cells). Fully charged = 12.6 V (3 × 4.2 V). Use nominal voltage (11.1 V) for Watt‑hour runtime calculations. Use 12.6 V only to check peak input voltages and component stress.
- Converter efficiency (example): 90% (0.9). Use input_power = output_power / efficiency and input_current = input_power / pack_voltage.
- Use verified cell capacity for sizing. Many low‑quality 18650 claims (e.g., 4800 mAh) are false — design with verified capacity (e.g., 3200 mAh) or measured data.
- Use usable capacity (account for BMS cutoff and safe depth‑of‑discharge). Example conservative usable fraction: 75–85% (80% used below).

---

## 🟦 BLOCK 1 — Raspberry Pi System (5 V rail)

Includes: Raspberry Pi 5 (16 GB), Hailo AI HAT, Seeed Dual‑CAN HAT, USB SSD (NVMe, USB3), Waveshare 7.9" touchscreen.

| Component | Typical power | Peak power | Notes |
|---|---:|---:|---|
| Raspberry Pi 5 (16GB) | 9–12 W | 14–16 W | Idle ≈3.5–4 W; heavy loads up to ~16 W |
| Hailo AI HAT | 2.5 W | 3 W | Inference HAT |
| Seeed Dual‑CAN HAT | 0.45–0.6 W | 0.6 W | 90–120 mA @ 5 V |
| USB SSD (NVMe via USB3) | 5 W | 7 W | NVMe enclosure peaks |
| Waveshare 7.9" touchscreen | 3 W | 3.5 W | Backlight dependent |
| **TOTAL (Block 1)** | **20.95–23.1 W** | **28.1–30.1 W** | Sum of above (typical / peak) |

Rail recommendation (5 V): 6–8 A continuous recommended; size the 5 V buck with margin (recommend 12 A rated output for continuous margin and inrush/short peaks).

Notes:
- Keep units consistent: power in W, currents in A. When sizing wiring and fuses, convert using pack/input voltage and converter efficiency (see conversion section).
- For continuous thermals, derate converter rating by 10–20% if ventilation is limited.

---

## 🟩 BLOCK 2 — STM32 + Sensors + Servo + Motors (motor/servo rail, 6–7 V)

Includes: STM32U585 MCU, LM393 speed sensor, CAN transceiver, MG996R servo, two PiRacer 37‑520 DC gearmotors.

| Component | Typical power | Peak power | Notes |
|---|---:|---:|---|
| STM32U585I‑IT01A | 0.5 W | 0.5 W | MCU |
| LM393 speed sensor | 0.01 W | 0.01 W | negligible |
| CAN transceiver | 0.2 W | 0.2 W | |
| MG996R servo (6 V) | 6 W | 15 W | Typical vs. stall (measure stall in amps) |
| PiRacer 37‑520 motor #1 (6 V) | 6 W | 12 W | No‑load / under load / stall |
| PiRacer 37‑520 motor #2 (6 V) | 6 W | 12 W | |
| **TOTAL (Block 2)** | **18.7 W** | **39.7 W** | |

Rail recommendation (motor/servo): design for 6–7 V; allow 3–7 A continuous depending on usage profile. Plan wiring/fuses/converters for short peak currents (stall/inrush) up to ~10–15 A or measured values.

Important: convert motor/servo power estimates to amps via the motor supply voltage and verify stall/start currents on the bench; do not assume stall current from watt estimates alone.

---

## Power conversion & battery input (method & example)

Correct method:
- input_power (W) = output_power (W) / efficiency
- input_current (A) = input_power (W) / pack_nominal_voltage (V)

Using efficiency = 0.9 and pack nominal = 11.1 V:

- Block 1 (conservative typical = 23.1 W):  
  input_power = 23.1 / 0.9 = 25.67 W → input_current ≈ 25.67 / 11.1 ≈ 2.31 A  
  Peak 30.1 W → input_power = 30.1 / 0.9 = 33.44 W → input_current ≈ 3.01 A

- Block 2 (typical 18.7 W):  
  input_power = 18.7 / 0.9 = 20.78 W → input_current ≈ 1.87 A  
  Peak 39.7 W → input_power = 39.7 / 0.9 = 44.11 W → input_current ≈ 3.97 A

- Combined (typical conservative = 41.8 W):  
  input_power = 41.8 / 0.9 = 46.44 W → input_current ≈ 46.44 / 11.1 ≈ 4.19 A  
  Combined peak 69.8 W → input_power = 69.8 / 0.9 = 77.56 W → input_current ≈ 77.56 / 11.1 ≈ 6.99 A

Pack energy (use nominal voltage × verified capacity)
- Example verified capacity: 3.2 Ah → 11.1 V × 3.2 Ah = 35.52 Wh (use this for runtime).
- Usable capacity: account for BMS cutoff / DoD. Example conservative usable fraction: 80% → usable_Wh = 35.52 × 0.8 = 28.42 Wh.

Runtime examples (3.2 Ah pack)
- Combined typical 41.8 W:
  - 100% usable: 35.52 / 41.8 ≈ 0.85 h (≈ 51 min)
  - 80% usable: 28.42 / 41.8 ≈ 0.68 h (≈ 41 min)
- Combined peak 69.8 W (short bursts): 35.52 / 69.8 ≈ 0.51 h (≈ 31 min) — note peaks are short; sustained at peak will deplete quickly.

Notes:
- Do NOT compute Wh/runtime using 12.6 V charged voltage — this overestimates energy. Use nominal pack voltage and verified capacity and account for usable fraction.
- For safety use conservative margins (size converters 20–50% above expected continuous draw for thermal margin; provision for short peak handling separately).

---

## Battery options, paralleling and safety

Option A — Two separate 3S packs (team default)
- Pack A → expansion (motors / servo / STM32 / CAN)
- Pack B → Raspberry Pi + HATs + display
Pros: isolates motor spikes, simplifies fault containment. Cons: two chargers/BMS units and more wiring.

Option B — Single pack (3S) powering all
- Single 3S with a BMS rated for combined current. Use branch fuses and good wiring.
- Consider a single higher‑capacity pack (3S2P) instead of two separate packs for simpler charging.

Parallel packs (increase current capacity)
- If paralleling packs, only parallel identical packs (same chemistry, capacity, age, state‑of‑charge). Use a BMS designed for parallel use or separate BMS on each pack with proper controls.
- Fuse each pack individually and include soft‑start/pre‑charge or current limiting when connecting packs in parallel to avoid large inrush currents.
- Paralleling increases risk; avoid unless you can validate cell matching and safety.

Cell selection notes
- Use reputable manufacturers and verified capacity. Many "4800 mAh 18650" cells are counterfeit. Typical genuine max for 18650 chemistry ≈ 3000–3500 mAh depending on cell type.

---

## Protections, components and wiring

1. BMS:
   - 3S BMS with balancing, over/under voltage protection and overcurrent protection.
   - Rated continuous current > expected continuous draw (recommend ≥10 A) and peak current > expected peaks.

2. Fuses:
   - Main pack fuse: choose rating considering continuous draw + margin. For motors choose time‑delay (slow‑blow) for inrush tolerance; e.g., 12–15 A depending on expected peaks and pack configuration.
   - Branch fuses for Pi rail and motor rail recommended.

3. Buck converters:
   - Pi rail: 5 V converter rated ≥12 A for margin and thermal headroom.
   - Motor/servo rail: 6–7 V converter rated ≥10 A (or higher depending on measured motor currents).
   - Prefer converters with thermal shutdown, current limiting and clear efficiency specification.

4. Capacitors / decoupling:
   - Pi rail: 470–1000 µF low‑ESR electrolytic at buck output.
   - Motor rail: 1000 µF+ low‑ESR capacitors placed close to motor/servo power input to absorb spikes and reduce brownouts.

5. Wiring & connectors:
   - Use correct gauge: 14 AWG for 10–15 A runs, 12 AWG for >15 A runs; derate for length and temperature. Short high‑current runs may tolerate smaller wire but keep margin.
   - Use secure crimps/solder and mechanical strain relief. Route motor cables separately to reduce EMI.

6. Current & voltage monitoring:
   - Use a shunt or hall‑effect sensor and logging (INA219/INA3221, ACS7xx, etc.). Monitor pack voltage and current and log peak events.

7. Thermal & mechanical:
   - Heatsink or airflow for converters and high‑power components.
   - Mount BMS and caps away from heat and vibration.

8. Safety:
   - Have a documented test plan and emergency cutoff (e.g., accessible main fuse and a kill switch).
   - Carry appropriate PPE and follow Li‑ion handling best practices when building and testing.

---

## Testing plan (detailed)

1. Documentation review
   - Read expansion board and component datasheets for connector/current ratings.
   - Identify recommended decoupling, connector pinouts, max currents and recommended wiring.

2. Bench measurement
   - Measure idle, nominal, and worst‑case loads with instrumentation:
     - Use clamp meter or shunt + DAQ for current traces.
     - Measure stall/start currents for motors/servos (in amps).
     - Measure voltage drop at connectors and regulators under load.
     - Measure buck converter temperature at expected continuous current and peaks.
   - Validate that BMS/fuses and wiring do not overheat and that voltage does not brown out.

3. Iteration
   - If measured draws exceed predicted values, increase converter and fuse ratings, or revert to two‑pack solution for isolation.
   - Recompute runtime from measured usable Wh.

Record all measurements in a test log and attach to this document.

---

## Minor fixes / edits applied in this revision
- Corrected Block 1 component sum and clarified block totals.
- Replaced any phrasing implying voltage is "reduced" by converter — efficiency applies to power; formulas are explicit.
- Added usable capacity (DoD/BMS cutoff) and advised conservative sizing.
- Standardized 5 V rail recommendation to 6–8 A and converter sizing guidance (12 A).
- Clarified wire gauge recommendations and fuse type guidance.
- Strengthened warnings about counterfeit cell capacities and paralleling packs.

---

## Team conclusions (current)
- Keep two‑pack plan as primary (Pack A → expansion, Pack B → Pi/display) with protections listed above.
- Single pack / parallel pack option remains as alternative following strict matching, fusing and pre‑charge procedures.
