# Motor Bridge Comparison for STM32 DC Motor Control

This document compares three common dual H-bridge motor driver options for the DrivaPi car project. The goal is to choose a driver that works well with a 12V source, is easy to integrate with STM32, and keeps the system practical for a small car.

## Options Compared

### 1. TB6612FNG
A modern dual motor driver with better efficiency than older H-bridge modules.

- **Motor supply:** about 4.5V to 13.5V
- **Logic supply:** 2.7V to 5.5V
- **Current:** around 1.2A continuous per channel, higher peak current depending on module and cooling
- **Strengths:** low voltage drop, compact, efficient, good PWM behavior
- **Weaknesses:** lower current limit than L298N, so it must match the motor load
- **Typical price:** about **$3 to $8** per module

### 2. L298N
A very common and easy-to-find dual motor driver board.

- **Motor supply:** about 5V to 35V
- **Logic supply:** 5V
- **Current:** up to 2A per channel in theory, but practical use is lower without strong cooling
- **Strengths:** cheap, widely available, simple to find and test
- **Weaknesses:** large voltage drop, runs hot, wastes power, less efficient for battery systems
- **Typical price:** about **$2 to $5** per module

### 3. L9110S
A very small and low-cost dual motor driver board.

- **Motor supply:** about 2.5V to 12V
- **Logic supply:** 2.5V to 12V
- **Current:** lower than the other two, suitable only for small loads
- **Strengths:** very cheap, simple, small size
- **Weaknesses:** weakest current margin, not ideal for 12V motor systems, less robust for a car platform
- **Typical price:** about **$1 to $3** per module

## Comparison Table

| Option | 12V Compatibility | Current Capability | STM32 Integration | Efficiency | Typical Price | Overall Fit |
|---|---|---:|---|---|---:|---|
| TB6612FNG | Good | Medium | Very good | Best | $3-$8 | Best choice |
| L298N | Good | Medium-high on paper | Good | Poor | $2-$5 | Safe fallback |
| L9110S | Borderline | Low | Good | Fair | $1-$3 | Not recommended |

## What is better in each one

### TB6612FNG is better for:
- Battery-powered robot cars
- Lower heat generation
- Better PWM control
- Cleaner STM32 wiring and logic-level control
- Better overall efficiency when running from a 3S pack

### L298N is better for:
- Very cheap prototypes
- Fast testing when current draw is not the main concern
- Cases where availability matters more than efficiency

### L9110S is better for:
- Very small motors
- Tiny educational projects
- Low-cost demos with light loads

## Recommendation

For the DrivaPi project, the **TB6612FNG is the best option**.

### Why it is the best choice
- It works well with a **12V class power system** used by the car.
- It is **more efficient** than the L298N, so less battery power is wasted as heat.
- It is a better fit for **STM32 PWM control** and direction control.
- It gives a good balance between **price, size, and performance**.

### Why not the others
- **L298N** is easy to find, but it wastes too much power and gets hot quickly.
- **L9110S** is cheap, but it is not strong enough for a reliable 12V motor setup.

## Final Decision

**Selected driver: TB6612FNG**

This option gives the best balance for the new expansion-board replacement, especially if the goal is a compact, efficient, and reliable motor control stage for the STM32.

---
