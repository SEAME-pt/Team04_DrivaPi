/**
	******************************************************************************
	* @file    firmware/Core/Inc/speed_sensor.h
	* @author  DrivaPi Team
	* @brief   This file contains the speed sensor definitions.
	******************************************************************************
	* @attention
	*
*/

#ifndef __SPEED_SENSOR_H
#define __SPEED_SENSOR_H

#ifdef __cplusplus
extern "C" {
#endif

#include "app_threadx.h"

#define WHEEL_PERIMETER_M   0.212f
#define PULSES_PER_REV      30.0f
#define TIMER_PERIOD        65535

#ifndef TX_TIMER_TICKS_PER_SECOND
#define TX_TIMER_TICKS_PER_SECOND 1000
#endif

extern TIM_HandleTypeDef htim1;
extern UART_HandleTypeDef huart1;

/* Function prototypes */
float			ReadSpeedSensor(void);
RNDGear_t		DetermineRNDGear(float speed, int16_t pwm_value);
VOID 			SpeedSensor(ULONG initial_input);

#ifdef __cplusplus
}
#endif
#endif
