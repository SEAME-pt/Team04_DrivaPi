/*
 * init_devices.c
 *
 *  Created on: Feb 13, 2026
 *      Author: DrivaPi
 */


#include "app_threadx.h"

#define UART_BOOT_INIT_TIMEOUT_MS 20u

/**
 * @brief Initialize all onboard I2C devices and sensors.
 */
void InitAllDevices(void)
{
	const char *msg = "Initializing PCA9685 devices...\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_INIT_TIMEOUT_MS);
	msg = "[BOOT] Before PCA init\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_INIT_TIMEOUT_MS);
	PCA9685_InitAllDevices();
	msg = "[BOOT] After PCA init\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_INIT_TIMEOUT_MS);

	/* Battery_Init removed - now done in SensorBatteryThread after ThreadX starts */
	/* This avoids blocking HAL_Delay calls before scheduler is running */

	msg = "[BOOT] HTS init deferred to thread\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_INIT_TIMEOUT_MS);

	msg = "[BOOT] Before SensorsInit\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_INIT_TIMEOUT_MS);
	SensorsInit();
}
