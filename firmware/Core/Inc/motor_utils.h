/**
	******************************************************************************
	* @file    motor_utils.h
	* @author  MCD Application Team
	* @brief   Header for motor_utils.c module
	******************************************************************************
	* @attention
	*
*/

#ifndef __MOTOR_UTILS_H
#define __MOTOR_UTILS_H

#ifdef __cplusplus
extern "C" {
#endif

#include "app_threadx.h"
void        UartPrintf(const char* format, ...);
void        UartPrint(const char* msg);
void        SoftwareDelay(uint32_t ms);
uint16_t    ClampU16(int32_t computed_value);

#ifdef __cplusplus
}
#endif
#endif