/**
******************************************************************************
* @file           : servo_motor.h
* @brief          : Servo motor control header
******************************************************************************
*/

#ifndef __SERVO_MOTOR_H
#define __SERVO_MOTOR_H

#ifdef __cplusplus
extern "C" {
#endif

#include "pca9685.h"
#include "app_threadx.h"

#ifndef PCA9685_COUNTS
#define PCA9685_COUNTS 4096u
#endif

#define PCA9685_ADDR_SERVO 0x40u
#define SERVO_CH 0u

#define SERVO_DEFAULT_MIN_PULSE_COUNTS 200u
#define SERVO_DEFAULT_MAX_PULSE_COUNTS 500u
#define SERVO_DEFAULT_FREQ_HZ 50u

int	SetServoAngle(I2C_HandleTypeDef *hi2c, uint8_t addr7, uint8_t channel, uint16_t angle_deg, uint16_t min_pulse,
	uint16_t max_pulse);

int	ServoSweep(I2C_HandleTypeDef *hi2c, uint8_t addr7, uint8_t channel, uint16_t angle_start_deg, uint16_t angle_end_deg,
uint16_t angle_step_deg, uint32_t delay_ms, uint16_t min_pulse, uint16_t max_pulse);

extern I2C_HandleTypeDef hi2c3;

#ifdef __cplusplus
}
#endif
#endif
