# GPIO Sensor Interface Specification

**Date:** 2025-11-03  
**Project:** DrivaPi  
**Subsystem:** Motor Speed Sensing  
**Document ID:** gpio_sensor_interface.md  

---

## 1. Interface Overview

The GPIO sensor interface defines the electrical and protocol specifications for connecting a motor speed tachometer sensor to the Raspberry Pi GPIO subsystem.

### Hardware Architecture

```
Motor Rotation
      ↓
Tachometer Sensor (Hall-effect)
      ↓
Pulse Train (3.3V digital)
      ↓
GPIO Pin 17 (Raspberry Pi BCM)
      ↓
GPIO Driver (Linux kernel)
      ↓
MotorSpeedSensor C++ Driver
      ↓
Application Layer
```

---

## 2. Electrical Interface

### Connector Specification

**Connector Type:** 3-pin header (0.1" pitch)

| Pin | Signal | Voltage | Direction |
|-----|--------|---------|-----------|
| 1 | GND | 0V | - |
| 2 | +3.3V | 3.3V | Power |
| 3 | TACH | 0-3.3V | Input |

### Pin Assignment (Raspberry Pi)

**Physical Pin Location:** Header P1, Pin 11

| Raspberry Pi | BCM # | GPIO Pin |
|--------------|-------|----------|
| Physical Pin 11 | GPIO 17 | Input |

### Signal Characteristics

**TACH Signal (Pulse Train):**
- **Type:** TTL digital pulses (Hall-effect output)
- **Voltage:** 0-3.3V logic levels
- **Frequency:** 0 Hz (stopped) to ~166 Hz (10000 RPM)
  - Calculation: 10000 RPM ÷ 60 sec/min = 166.7 pulses/sec
- **Frequency Range:** 0-200 Hz (margin for over-speed)
- **Pulse Width:** Typically 50% duty cycle (vendor-dependent)
- **Rise Time:** <1 µs (TTL standard)
- **Fall Time:** <1 µs (TTL standard)

**Power Supply:**
- **+3.3V Pin:** Supplies sensor power (100 mA max)
- **GND Pin:** Common ground (must be connected)
- **Current Draw:** ~50 mA (typical hall-effect sensor)

---

## 3. GPIO Configuration

### Linux GPIO Setup

**BCM Pin Number:** 17  
**Direction:** Input  
**Pull-up:** Internal pull-up enabled (30-50 kΩ)  
**Debounce:** No hardware debounce (software-handled)  

### Setup Methods

**Method 1: Using gpiod (Recommended for Raspberry Pi OS 11+)**

```bash
# Find GPIO chip
gpioinfo | grep 17

# Export GPIO 17
gpioset gpiochip0 17=0

# Read GPIO 17
gpioget gpiochip0 17
```

**Method 2: Using sysfs (Legacy)**

```bash
# Export GPIO
echo 17 > /sys/class/gpio/export

# Set as input
echo in > /sys/class/gpio/gpio17/direction

# Read GPIO
cat /sys/class/gpio/gpio17/value
```

**Method 3: Using wiringPi Library**

```cpp
#include <wiringPi.h>

wiringPiSetupGpio();
pinMode(17, INPUT);
int state = digitalRead(17);
```

---

## 4. Protocol Specification

### Pulse Counting Protocol

**Measurement Window:** 1000 milliseconds (±10ms tolerance)

**Algorithm:**
```
1. Start counting at T=0
2. Monitor GPIO 17 for rising edges
3. Increment pulse counter on each rising edge
4. Stop counting at T=1000ms
5. Calculate RPM = pulse_count × 60
```

**Example Calculation:**
- Motor speed: 2400 RPM
- Expected pulses in 1 sec: 2400 ÷ 60 = 40 pulses
- Measurement window: 1000ms
- Result: 40 pulses counted → 40 × 60 = 2400 RPM ✓

### Timing Specifications

| Parameter | Specification | Tolerance |
|-----------|---------------|-----------|
| Measurement Window | 1000 ms | ±10 ms |
| Maximum Pulse Frequency | 200 Hz | - |
| Minimum Pulse Duration | 2.5 µs | - |
| Settling Time | <1 ms | - |

---

## 5. Connector Pinout Details

### DrivaPi Motor Sensor Header

```
Front View:
┌─────────┐
│ 1  2  3 │
│ GND +3V TACH
└─────────┘

Pin 1: GND (Black wire)
Pin 2: +3.3V (Red wire)
Pin 3: TACH (Yellow wire)
```

### Wiring Guidelines

**Cable Requirements:**
- **Type:** Shielded twisted pair (recommended)
- **Length:** Maximum 5 meters
- **Gauge:** 22 AWG or better
- **Shield:** Connected to GND at sensor end

**Connector Assembly:**
1. Strip 0.25" from wire ends
2. Tin wires with solder (optional)
3. Insert into crimp pins
4. Crimp securely
5. Insert into header housing
6. Ensure pins are fully seated

---

## 6. Sensor Hardware Specification

### Recommended Sensor: Standard Hall-Effect Tachometer

**Sensor Type:** Hall-effect pulse generator

| Specification | Value | Notes |
|---------------|-------|-------|
| Supply voltage | 5V or 3.3V | Use 3.3V for Raspberry Pi |
| Current draw | 20-50 mA | Typical operation |
| Output type | Open-collector or push-pull | Ensure 3.3V TTL compatible |
| Frequency response | DC to 200 Hz | Supports up to 12000 RPM |
| Temperature range | -40°C to +85°C | Standard automotive |
| Mounting | Bolt-on or snap-on | Depends on motor type |

**Sensor Features:**
- ✓ 1 pulse per motor revolution
- ✓ No batteries required (powered by DrivaPi)
- ✓ Weatherproof connector (IP67 minimum)
- ✓ EMI/RFI shielded

---

## 7. Electrical Safety

### ESD Protection

- GPIO 17 has internal protection diode
- Additional external protection recommended:
  - Series 100Ω resistor on TACH line
  - 100nF capacitor to GND (low-pass filter)

### Overvoltage Protection

| Condition | Protection |
|-----------|-----------|
| 5V applied to 3.3V GPIO | Not supported - use voltage divider |
| ESD spike | Internal diode clamps at Vdd + 0.3V |
| Latchup | POR (Power-on Reset) recovery |

### Circuit Diagram

```
Motor Tachometer Output
         │
         └─┬─ 100Ω ─┬─ GPIO 17 (BCM17)
           │        │
          ///      100nF
           │        │
           │        ├─ Pull-up (internal)
           │        │
         GND ──────GND (Raspberry Pi)
```

---

## 8. Environmental Conditions

### Operating Environment

**Temperature:** -10°C to +40°C (lab environment)  
**Humidity:** 20% to 80% RH (non-condensing)  
**Vibration:** <5G (typical test lab)  
**EMI:** Standard industrial environment (< 100 V/m at 1 GHz)  

### Cable Routing

- **Keep away from:** High-current power cables, motor leads
- **Route with:** Other signal cables (twisted pair)
- **Grounding:** Shield must be grounded at sensor end only
- **Distance from power:** Minimum 10cm separation

---

## 9. Calibration & Testing

### Pre-Installation Verification

```bash
# 1. Check GPIO availability
gpioinfo | grep 17

# 2. Test GPIO connectivity
gpioset gpiochip0 17=0
gpioget gpiochip0 17

# 3. Verify 3.3V power supply
# (Use multimeter on Pin 2 vs Pin 1)

# 4. Check for short circuits
# (Resistance between TACH and GND should be >1MΩ)
```

### Sensor Calibration

**Pulse Verification:**
1. Manually rotate motor 10 times
2. Count pulses (should be 10)
3. Verify no spurious pulses

**Frequency Test:**
1. Run motor at known speed (e.g., 3000 RPM)
2. Measure pulse frequency: 3000 ÷ 60 = 50 Hz
3. Verify measured frequency matches

---

## 10. Troubleshooting Guide

| Issue | Symptom | Cause | Solution |
|-------|---------|-------|----------|
| No pulses | read_rpm() returns -1 | GPIO not connected | Check pin 3 connection |
| Sporadic pulses | Random RPM values | Loose connector | Reseat connector |
| High frequency noise | Jittery readings | EMI from motor | Add shielding |
| Constant low reading | RPM too low | Slow motor speed | Normal - verify in log |
| Constant high reading | RPM too high | Sensor short | Check TACH to GND |

---

## 11. Compliance & Standards

- **Electrical:** TTL logic levels (3.3V standard)
- **Mechanical:** Standard 0.1" header spacing
- **Environmental:** Industrial operating conditions
- **Safety:** ASIL A (SWD-010 requirement)

---

**Document Status:** Released  
**Next Review:** Post-integration test  
**Traceability:** SRD-010
