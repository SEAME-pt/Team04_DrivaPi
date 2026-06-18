# Motor and Servo PWM Calculations for STM32

## Purpose

This document explains how the STM32 timer configuration in `main.c` generates:

- approximately 15 kHz PWM for the two DC motors (`TIM4` and `TIM16`)
- 50 Hz PWM for the servo (`TIM8`)

It also explains why the motor PWM command is limited to 665.

## Acronyms and register names (quick reference)

- `RCC` (Reset and Clock Control): MCU peripheral that configures and distributes clock signals and controls reset sources.
- `MSI` (Multi-Speed Internal clock): The internal, low-power RC oscillator available at multiple selectable frequencies.
- `MSIClockRange / RCC_MSIRANGE_x`: Selector for the MSI frequency; `RCC_MSIRANGE_4` selects 4 MHz on this MCU.
- `PLL` (Phase-Locked Loop): A clock block that creates a faster and stable internal clock from a lower-frequency source.
- `APB` (Advanced Peripheral Bus): The internal bus clock domain used by peripherals such as timers, UART, and SPI.
- `Prescaler` / `PSC`: A timer divider that slows the timer clock by `PSC + 1`.
- `ARR` (Auto-Reload Register): The maximum counter value before the timer resets and starts a new PWM cycle.
- `CCR` (Capture/Compare Register): The value that sets how long the PWM output stays high inside each cycle (duty cycle).
- `PLLM`: PLL input divider, applied first to the source clock before multiplication.
- `PLLN`: PLL multiplication factor, used to raise the divided clock frequency.
- `PLLR`: PLL output divider, used to generate the final system clock (`SYSCLK`) from the PLL.

## 1. System clock used by the timers

From `SystemClock_Config()`:

- `MSIClockRange = RCC_MSIRANGE_4` -> MSI source is 4 MHz
- `PLLM = 1`
- `PLLN = 80`
- `PLLR = 2`
- system clock source is `PLLCLK`

Clock equation:

$$
F_{SYSCLK} = \frac{F_{MSI}}{PLLM} \times \frac{PLLN}{PLLR}
$$

Substituting values:

$$
F_{SYSCLK} = \frac{4\,\text{MHz}}{1} \times \frac{80}{2} = 160\,\text{MHz}
$$

Because APB bus dividers are configured as `/1`, the timer clock used here is 160 MHz.

## 2. DC motor PWM calculation (`TIM4` and `TIM16`)

Both motor timers use the same configuration:

- `PSC = 15` -> hardware divides by `PSC + 1 = 16`
- `ARR = 665` -> counter length is `ARR + 1 = 666` ticks

General PWM frequency formula:

$$
F_{PWM} = \frac{F_{TIM}}{(PSC + 1)(ARR + 1)}
$$

Applying your values:

$$
F_{PWM,motor} = \frac{160\,000\,000}{16 \times 666}
= 15\,015\,\text{Hz} \approx 15\,\text{kHz}
$$

Conclusion: This math is intentionally chosen to produce approximately 15 kHz motor PWM.

## 3. Why motor speed is clamped to 665

In `moveMotors()`:

- `if (speed > 665) speed = 665;`
- `speed` is written directly into `CCR`

Since `ARR = 665`, valid `CCR` values are `0..665`.

Duty-cycle equation:

$$
Duty = \frac{CCR}{ARR + 1}
$$

Examples:

- `CCR = 0` -> 0% duty
- `CCR = 665` -> maximum possible duty for this timer setup (very close to 100%)

This is why software limits motor PWM command to 665.

## 4. Servo PWM calculation (`TIM8`)

Servo timer configuration:

- `PSC = 159` -> division by `PSC + 1 = 160`
- `ARR = 19999` -> period length of `ARR + 1 = 20000` ticks

Timer tick frequency:

$$
F_{tick} = \frac{160\,\text{MHz}}{160} = 1\,\text{MHz}
$$

So each tick is:

$$
T_{tick} = 1\,\mu s
$$

PWM period and frequency:

$$
T_{PWM} = 20000 \times 1\,\mu s = 20\,\text{ms}
$$

$$
F_{PWM,servo} = \frac{1}{20\,\text{ms}} = 50\,\text{Hz}
$$

This matches standard RC-servo control timing.

## 5. Servo angle to pulse-width mapping

In `setServoAngle()`:

$$
CCR = 1000 + \frac{angle \times 1000}{180}
$$

So angle `0..180` maps to:

- `1000` ticks -> 1.0 ms pulse
- `1500` ticks -> 1.5 ms pulse (center)
- `2000` ticks -> 2.0 ms pulse

within a 20 ms frame (50 Hz).

## 6. Final summary

- `TIM4` and `TIM16` are configured for approximately 15 kHz PWM for the DC motors.
- `TIM8` is configured for 50 Hz PWM for the servo.
- The motor maximum command value of 665 is directly tied to `ARR = 665`.
