# PID Control Loop Implementation for DC Motors

## Overview

This document outlines the design and implementation of PID (Proportional-Integral-Derivative) control loops to regulate DC motor speed on the DrivaPi vehicle. A PID controller automatically adjusts motor PWM (Pulse-Width Modulation) signals to maintain a target speed by continuously comparing actual speed to desired speed. 

## 1. PID Theory

### 1.1 Core Concept

A PID controller continuously adjusts PWM signals sent to the motor based on the error between target speed and actual measured speed.

### 1.2 PID Equation

The fundamental PID control law:

$$u(t) = K_p \cdot e(t) + K_i \int_0^t e(\tau) d\tau + K_d \frac{de(t)}{dt}$$

Where:
- **u(t)** = normalized control command in range [-1, 1], mapped to bidirectional PWM (−4095…+4095)
- **e(t)** = Speed error = target_speed − current_speed
- **K_p, K_i, K_d** = Proportional, Integral, Derivative gains

### 1.3 PID Terms Explained

#### Proportional (P) Term
- **Effect**: Direct, instantaneous response to error
- **Formula**: $u_p = K_p \cdot e(t)$
- **Behavior**:
  - Larger error → Larger control action
  - Fast response, but may overshoot and oscillate
- **Tuning**: Start with moderate K_p; increase until system responds quickly but doesn't oscillate excessively

#### Integral (I) Term
- **Effect**: Eliminates steady-state error over time
- **Formula**: $u_i = K_i \int_0^t e(\tau) d\tau$
- **Behavior**:
  - Accumulates past errors
  - Drives error to zero, even with constant disturbances
  - Can cause overshoot and slow response if K_i is too large
- **Tuning**: Start small; increase cautiously to avoid oscillation

#### Derivative (D) Term
- **Effect**: Dampens response; reduces overshoot and oscillation
- **Formula**: $u_d = K_d \frac{de(t)}{dt}$
- **Behavior**:
  - Responds to rate of change of error
  - Provides predictive correction before overshoot occurs
  - Sensitive to measurement noise
- **Tuning**: Increase to reduce overshoot; too high causes stiffness and noise sensitivity

---

## 2. DC Motor Characteristics for DrivaPi

### 2.1 Motor Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Model | JGB37-520 DC | Geared DC motor |
| Type | DC brushed motor with integral gearbox | Compact, high-torque |
| Voltage | 12V | Powered from vehicle battery |
| Idle Speed | ~740 RPM | No-load speed at 12V, motor output |
| Gear Ratio | 10:1 | Reduces speed, increases torque |
| Wheel Speed (est.) | ~74 RPM | At 10:1 reduction |
| Max Current | ~200–300 mA | Short-term peak with load |
| Encoder Resolution | 30 PPR | 30 pulses per revolution |

### 2.2 Speed Measurement

Speed is calculated using encoder pulses counted by the STM32 (microcontroller) and converted to m/s. The encoder sends pulses via an LM393 comparator to condition the signal.

**Encoder-Based Speed Calculation:**
```c
delta_pulses = current_encoder_count - last_encoder_count;
// Handle timer overflow
if (delta_pulses > TIMER_PERIOD / 2)
    delta_pulses -= (TIMER_PERIOD + 1);
else if (delta_pulses < -TIMER_PERIOD / 2)
    delta_pulses += (TIMER_PERIOD + 1);

rotations = delta_pulses / PULSES_PER_REV;
distance_m = rotations * WHEEL_PERIMETER_M;
speed_mps = distance_m / dt;  // dt is time interval in seconds
```

**Example Calculation:**
- Sampling interval: 100 ms
- Encoder: 30 PPR
- Wheel perimeter: 0.212 m
- If 15 pulses in 100 ms → Speed = 1.06 m/s (≈3.8 km/h)

### 2.3 Motor Dynamics

**Non-linearities to consider:**
1. **Dead Zone**: Minimum PWM needed to start motor motion (typically 20–30%)
2. **Saturation**: PWM capped at 4095 (100%)
3. **Inertia**: Acceleration is gradual, not instantaneous
4. **Load Variation**: Friction and weight affect motor response
5. **Temperature**: Motor efficiency changes with heat

---

## 3. Tuning Methods

**Note:** In equations, K_p, K_i, K_d refer to the actual gains implemented in code as `gain_p`, `gain_i`, `gain_d`.

### 3.1 Manual Tuning (Recommended for DrivaPi)

**Step 1: Set Baseline (P only)**
- Set gain_i = 0, gain_d = 0
- Choose modest gain_p (e.g., 50–100)
- Test step response: Set target speed suddenly, observe response
- Goal: Fast response, acceptable overshoot (~20%)

**Step 2: Add Integral (PI control)**
- Set gain_i small (e.g., gain_p / 10)
- Test steady-state error removal
- Increase gain_i until error is eliminated without oscillation
- If oscillation occurs, reduce gain_i

**Step 3: Add Derivative (PID)**
- Set gain_d small (e.g., gain_p × 0.01)
- Increase gain_d to reduce overshoot and oscillation
- Watch for noise amplification; if unstable, reduce gain_d
- Aim for critically damped response (fast, no oscillation)

**Empirical Starting Point:**
```
gain_p = 100  (adjust based on motor response speed)
gain_i = gain_p / 20 = 5  (slow integral action)
gain_d = gain_p × 0.05 = 5  (mild derivative action)
```

### 3.2 Practical Tuning Checklist

```
for each tuning iteration:
  1. Set target speed to 50% max speed
  2. Observe rise time (time to reach target)
  3. Measure overshoot (how much speed exceeds target)
  4. Measure settling time (time to stabilize)
  
  If oscillating: reduce gain_p or gain_i; increase gain_d
  If too slow: increase gain_p
  If steady-state error persists: increase gain_i
  If overshoot is excessive: increase gain_d or reduce gain_p
```

### 3.3 Anti-Windup Limit

**What is Integral Windup?**

Integral windup occurs when the integral term accumulates a large value because the control output is saturated (e.g., PWM at maximum 4095). During saturation, the motor cannot respond further, but the integral keeps growing as error persists. When the error finally decreases, the accumulated integral takes time to "unwind," causing overshoot and delayed response.

**Example:** If target speed is 2 m/s but motor is saturated at max PWM, the integral accumulates while speed slowly increases. Once speed approaches target, the large integral drives excessive PWM, causing overshoot past the target.

**Solution:** Clamp the integral term to prevent excessive accumulation during saturation.

The implementation uses a named integral clamp constant:
- `PID_INTEGRAL_LIMIT` in `motor_control.h`

Rationale:
- Prevents integral windup when output is saturated at the PWM limit
- Makes tuning explicit

Tuning guideline:
- If recovery after large commands is slow, reduce `PID_INTEGRAL_LIMIT`
- If steady-state error is not removed, increase `PID_INTEGRAL_LIMIT` or `gain_i`

---

## 4. PID Architecture & Integration

### 4.1 DrivaPi Hardware Architecture

```
┌────────────────────────────────────┐
│  STM32 Microcontroller             │
│                                    │
│  ┌────────────────────────────┐    │
│  │  CAN Receiver              │    │
│  └────────────┬───────────────┘    │
│               │                    │
│               ▼ (target speed)     │
│  ┌────────────────────────────┐    │
│  │  PID Controller            │    │
│  │  (motor_control.c)         │    │
│  └────────────┬───────────────┘    │
│               │                    │
│               ▼                    │
│  ┌────────────────────────────┐    │
│  │  I2C Master                │    │
│  │  (to PCA9685)              │    │
│  └────────────┬───────────────┘    │
│               │                    │
└───────────────┼────────────────────┘
                │ I2C Bus
                ▼
    ┌──────────────────────────┐
    │  PCA9685 PWM Driver      │
    └────────────┬─────────────┘
                 │ PWM signals 
                 ▼
    ┌──────────────────────────┐
    │  Motor Driver H-bridge   │
    │  (per motor)             │
    └────────────┬─────────────┘
                 │
                 ▼
    ┌──────────────────────────┐
    │  JGB37-520 DC Motor      │
    └────────────┬─────────────┘
                 │
                 ▼ (mechanical output)
    ┌──────────────────────────┐
    │  LM393 Comparator        │
    │  (pulse conditioning)    │
    └────────────┬─────────────┘
                 │ Digital pulse via GPIO
                 │
┌────────────────┘
│
▼
┌──────────────────────────────────┐
│  STM32 Timer (TIM1)              │
│  GPIO Input Capture              │
│  (counts encoder pulses)         │
└──────────────────────────────────┘
         │
         ▼ (feedback)
    ┌────────────────┐
    │ Speed Sensor   │
    │ (speed_sensor.c)
    │ Calculates m/s │
    └────────────────┘
         │
         ▼ (feedback loop)
    PID Controller
```

**Signal Flow:**
1. **Command:** Raspberry Pi 5 sends target speed via CAN (Controller Area Network) to STM32
2. **Control:** PID calculates PWM output → I2C (two-wire protocol) sends PWM to PCA9685 driver
3. **Motor:** PCA9685 outputs PWM → H-bridge driver → DC motor spins → Wheel rotates
4. **Feedback:** Wheel encoder pulses → LM393 conditions signal → STM32 timer counts → Speed calculation → back to PID
5. **Loop:** PID continuously adjusts PWM to match target speed

---

### 4.2 Integration Points

**File: `motor_control.h`**
Defines the `MotorPIDState` struct and the control API prototypes:
- `MotorPIDInit()` – Initializes PID gains and internal controller state
- `MotorPIDUpdate()` – Runs one PID iteration using current speed feedback
- `UpdateMotorControl()` – Updates the main control loop using target + measured speed

Initialize a global `g_motorPidState` instance with tuned gains before starting periodic control updates.

**File: `motor_control.c`**
Implements the PID control loop:
- `MotorPIDInit()` – Sets `gain_p`, `gain_i`, `gain_d` and clears previous error/integral memory
- `MotorPIDUpdate()` – Core PID calculation; call periodically (100 ms) from the main control thread
- `UpdateMotorControl()` – Main entry point; updates target speed from CAN and calls `MotorPIDUpdate()` with measured speed feedback

`UpdateMotorControl()` should be called on the main control loop (e.g., from a 100 ms timer or periodic task) to continuously regulate motor speed.

Example initialization sequence:

```c
MotorPIDInit(&g_motorPidState, 0.5f, 0.1f, 0.01f);
g_motorPidState.target_speed = 0.0f;
```

---

### 4.3 Current State vs. Future Implementation

#### Current State (March 2026)

The STM32 receives PWM values (-4095 to +4095) via CAN and sends them directly to the motor driver. No speed feedback or PID control.

#### Future Implementation (PID Control - Phase 2)

Transition from receiving PWM to receiving target speed commands. The PID controller will:
- Accept target speed (m/s) from remote via CAN
- Read encoder speed feedback
- Calculate required PWM using PID algorithm
- Automatically maintain target speed

**Key Changes:**
1. CAN message format: PWM → target speed (m/s)
2. STM32: Direct PWM forwarding → `UpdateMotorControl()` function
3. Add speed feedback from `speed_sensor.c`
4. Tune PID gains (gain_p, gain_i, gain_d)

---