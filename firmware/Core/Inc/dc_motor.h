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

#define NEUTRAL 0
#define FORWARD 1
#define REVERSE 2
#define BRAKE 3

void StopMotors(void);
void MoveMotors(uint16_t speed, bool forward);
void MotorCoast(void);

extern TIM_HandleTypeDef htim4;
extern TIM_HandleTypeDef htim8;
extern TIM_HandleTypeDef htim16;

#ifdef __cplusplus
}
#endif
#endif
