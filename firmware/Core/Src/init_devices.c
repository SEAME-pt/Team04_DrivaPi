/*
 * init_devices.c
 *
 *  Created on: Feb 13, 2026
 *      Author: DrivaPi
 */


#include "app_threadx.h"

/**
 * @brief Initialize all onboard I2C devices and sensors.
 */
void InitAllDevices(void)
{
	char *msg;

	if (BatteryInit(&hi2c2) != HAL_OK)
	{
		msg = "Battery: Initialization failed!\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	}
	else 
		g_batteryPowerReady = true;

	if (Hts221Init(&hi2c2) != HAL_OK)
	{
		msg = "HTS221: Initialization failed!\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	}

	SensorsInit();
}
