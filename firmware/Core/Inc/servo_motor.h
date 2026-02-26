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

#define SERVO_MIN_PULSE 205
#define SERVO_MAX_PULSE 410
#define SERVO_FREQ 0x79

int	SetServoAngle(uint8_t channel, uint16_t angle_deg);

int	ServoSweep(uint8_t channel, uint16_t angleStartDeg, uint16_t angleEndDeg,
uint16_t angleStepDeg);

extern I2C_HandleTypeDef hi2c3;

#ifdef __cplusplus
}
#endif
#endif
