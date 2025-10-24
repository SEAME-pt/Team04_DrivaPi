# PiRacer Embedded Control System: Real-Time Rust Implementation

## Executive Summary

This project implements a **real-time embedded control system** written in **Rust** to manage low-level hardware communication and control for a PiRacer platform.
The methodology focuses on safety and performance, utilizing direct Linux file descriptor polling for input events and precise I2C register manipulation via the `rppal` crate for actuator control, ensuring minimal latency between input and vehicle response.

## Technical Stack

The following table:

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| Language | Rust | "System programming for performance, memory safety, and embedded development." |
| OS Interface | Linux Joystick API (`/dev/input/js0`) | Direct synchronous reading of raw 8-byte joystick event buffers. |
| Hardware Access | `rppal` Crate | "Rust peripheral access library for Raspberry Pi, providing high-performance GPIO and I2C wrappers." |
| Communication | I2C Protocol | Low-level bus protocol for deterministic communication with PCA9685 controllers. |
| Actuators | PCA9685 Drivers (x2) | "Dedicated I2C devices (0x40, 0x60) used as 12-bit, $50 Hz$ PWM signal generators." |

## System Architecture: Implementation Mechanics

The system's efficiency is rooted in its explicit handling of input events and deterministic hardware control.

### 1. Gamepad Input Handler: The Poll-and-Parse Mechanism

The `Joystick::poll` method is central to the input handler, executing the following low-level process:

**Raw Polling:** The function attempts a synchronous read of exactly `8 bytes` from the `/dev/input/js0` file descriptor.
This fixed size corresponds to the standard Linux joystick event struct.

**Event Decoding:** The 8 bytes are parsed into:
* `value (i16)`: The magnitude of the axis movement or button state.
* `typev (u8)`: Determines if the event is a button (`typev & 0x01`) or an axis (`typev & 0x02`).
* `number (u8)`: The index (channel) of the specific button or axis.

**Normalization and Mapping:**
* **Axis:** If it's an axis event, the raw `i16` value is converted to a normalized floating-point value (`f64`).
* **Button:** The `ShanWanGamepad::read_data` layer uses the fixed `number` index to look up the input and translate it into the appropriate field (`button_a`, `analog_stick_left.z`, etc.) within the high-level `ShanWanGamepadInput` struct.

### 2. Hardware Driver: Precise PCA9685 Register Control

The `PiRacer` structure and its methods provide direct register-level control over the two `PCA9685` chips.

**Initialization (`wake_pca9685`):**
* It begins by clearing the sleep bit in the `MODE1` register and setting `MODE2` for totem pole output.
* It calculates the `PRESCALE` value based on the desired 50 Hz frequency using the formula: `PRESCALE = round(25,000,000 / (4096 * Frequency)) - 1.0`
* The chip is briefly put to sleep (`MODE1 |= 0x10`) to apply the new prescale value, ensuring correct PWM timing.

**PWM Pulse Generation (`write_pwm`):**
* This low-level function writes the ON and OFF tick values (`0` to `4095`) directly to the appropriate `4-byte` register block.
* The target register address is calculated based on the channel: `reg = LED0_ON_L + (4 * channel)`.

**Motor Direction Logic (`set_motor`):**
* The function implements H-Bridge logic over the motor driver `PCA9685 (0x60)`.
* **Speed Control:** The magnitude of the input value determines `pwm_val`, which is applied to the dedicated PWM channels (`CH7` for Left, `CH0` for Right).
* **Direction Control:** The sign of the input value (`value > 0.0`) determines the state of the two control pins (`IN1` and `IN2`) per motor to set the current flow:
    * **Forward (`value > 0`):** `IN1 = HIGH (4095 ticks)`, `IN2 = LOW (0 ticks)`.
    * **Backward (`value <= 0`):** `IN1 = LOW (0 ticks)`, `IN2 = HIGH (4095 ticks)`.

## Real-Time Control Loop

The main function executes a continuous, blocking loop (due to synchronous `joystick.poll()`) that provides an immediate, low-latency control experience.

* **Read:** `gamepad.read_data()` retrieves the current normalized `Input X` (steering) and `Input Y` (throttle).
* **Translate & Scale:** The raw input is scaled to the actuator's required range:
    * **Steering Pulse:** Linear mapping from `[-1.0, 1.0]` to a servo pulse range `[200, 500]`.
    * **Motor PWM:** The absolute `Input Y` value determines the duty cycle for the H-bridge PWM pins, while the sign determines the `IN1`/`IN2` direction pins.
* **Actuate:** `rppal -> I2C -> PCA9685` command sequence is executed to apply the physical changes.
* **Termination:** The application gracefully exits using the gamepad's `"B"` button, which calls `car.stop()` implicitly via the loop break and function exit (setting motor speed to `0.0`).
