/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : servo_motor.h
  * @brief          : Servo motor control header
  ******************************************************************************
  */
/* USER CODE END Header */

#ifndef __SERVO_MOTOR_H
#define __SERVO_MOTOR_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"
#include "pca9685.h"
#include <stdint.h>

/* Default servo configuration (override as needed) */
#ifndef PCA9685_COUNTS
#define PCA9685_COUNTS 4096u
#endif

#define PCA9685_ADDR_SERVO 0x40u
#define SERVO_CH 0u

/* Default pulse width (in PCA9685 counts) for 0..180 degree mapping. These
 * are defaults; callers may pass explicit min/max counts to Servo_SetAngle
 * and Servo_Sweep to support different servos.
 */
#define SERVO_DEFAULT_MIN_PULSE_COUNTS 200u
#define SERVO_DEFAULT_MAX_PULSE_COUNTS 500u
#define SERVO_DEFAULT_FREQ_HZ 50u

/* Function prototypes
 * - Servo_SetAngle: set a servo to an angle (0..180). Caller provides I2C
 *   handle, device 7-bit address, PCA9685 channel, and optional min/max
 *   pulse counts for mapping. Returns 0 on success, negative on error.
 * - Servo_Sweep: sweep servo between start and end angles stepping by
 *   angle_step_deg and pausing delay_ms between steps. Returns 0 on success.
 */
int Servo_SetAngle(I2C_HandleTypeDef *hi2c,
                   uint8_t addr7,
                   uint8_t channel,
                   uint16_t angle_deg,
                   uint16_t min_pulse_counts,
                   uint16_t max_pulse_counts);

int Servo_Sweep(I2C_HandleTypeDef *hi2c,
                uint8_t addr7,
                uint8_t channel,
                uint16_t angle_start_deg,
                uint16_t angle_end_deg,
                uint16_t angle_step_deg,
                uint32_t delay_ms,
                uint16_t min_pulse_counts,
                uint16_t max_pulse_counts);

/* External I2C handle (optional). Prefer passing handle explicitly to
 * Servo_* functions; the external handle remains for legacy callers.
 */
extern I2C_HandleTypeDef hi2c3;

#ifdef __cplusplus
}
#endif

#endif /* __SERVO_MOTOR_H */
