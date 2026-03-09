#ifndef MAIN_H
#define MAIN_H

#include <string.h>
#include <setjmp.h>
#include <math.h>
#include <stdarg.h>
#include <stdbool.h>
#include "unity.h"
#include "tx_api.h"
#include "stm32u5xx_hal.h"

void Error_Handler(void);
void UartPrintf(const char *format, ...);

extern TX_MUTEX g_speedDataMutex;
extern TX_EVENT_FLAGS_GROUP g_eventFlags;
extern TX_QUEUE g_queueSpeedCmd;
extern TX_QUEUE g_queueSteerCmd;
extern I2C_HandleTypeDef hi2c3;
extern UART_HandleTypeDef huart1;
extern TX_MUTEX g_motorMutex;
extern TX_MUTEX g_servoMutex;
extern TX_MUTEX g_gearMutex;
extern TX_MUTEX g_emergencyMutex;
extern float g_current_speed;
extern float g_vehicleSpeed;
extern bool g_emergencyBrake;

#endif
