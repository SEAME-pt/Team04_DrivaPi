/*
 * init_devices.c
 *
 *  Created on: Feb 13, 2026
 *      Author: hugofslopes
 */


#include "app_threadx.h"

/**
 * @brief Initialize all onboard I2C devices and sensors.
 */
void InitAllDevices(void)
{
	const char *msg = "Initializing PCA9685 devices...\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	PCA9685_InitAllDevices();

	if (Battery_Init(&hi2c3) == HAL_OK)
	{
		msg = "Battery: Initialized successfully\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	}
	else
	{
		msg = "Battery: Initialization failed!\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	}

	if (HTS221_Init(&hi2c2) != HAL_OK)
	{
		msg = "HTS221: Initialization failed!\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	}

	SensorsInit();
}
