/**
******************************************************************************
* @file           : dc_motor.h
* @brief          : DC motor control header
******************************************************************************
*/

#ifndef __DC_MOTOR_H
#define __DC_MOTOR_H

#ifdef __cplusplus
extern "C" {
#endif

#include "app_threadx.h"

#define PCA9685_ADDR_MOTOR 0x60
#define MOTOR_I2C hi2c3

#define MOTOR_L_PWM 7
#define MOTOR_L_A 5
#define MOTOR_L_B 6
#define MOTOR_R_PWM 0
#define MOTOR_R_A 1
#define MOTOR_R_B 2

#define BACKWARD 0
#define FORWARD 1
#define BRAKE 2

#ifndef PCA9685_COUNTS
#define PCA9685_COUNTS 4096u
#endif

void SetMotor(double value);
void MotorSetPWM(int32_t left_counts, int32_t right_counts);
void MotorBrake(void);
void MotorStop(void);
void MotorForward(double speed);
void MotorBackward(double speed);
void MotorLeft(double speed);
void MotorRight(double speed);

extern I2C_HandleTypeDef hi2c3;

#ifdef __cplusplus
}
#endif
#endif
