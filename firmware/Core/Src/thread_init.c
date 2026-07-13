/**
  ******************************************************************************
  * @file    firmware/Core/Src/thread_init.c
  * @author  DrivaPi Team
  * @brief   This file contains the thread initialization function.
  ******************************************************************************
  * @attention
  *
  */

#include "app_threadx.h"

/**
 * @brief  Function that implements the kernel's initialization.
 * @param  None
 */
void sysview_register_thread(TX_THREAD *thread)
{
	if ((thread == TX_NULL) || (thread->tx_thread_name == TX_NULL))
		return;

	SEGGER_SYSVIEW_NameResource((U32)(uintptr_t)thread, (const char *)thread->tx_thread_name);
}

/**
 * @brief Create and start all application threads.
 *
 */
void ThreadInit(void)
{
	uint8_t status;
	status = 0;
	char err_msg[20] = "FailSP\r\n";

	// SUPERVISOR THREAD
	if (tx_thread_create(&g_threads[supervisor_e].thread_ptr, "led_thread1", ld1_ThreadEntry, 0, g_threads[supervisor_e].thread_Stack, THREAD_STACK_SIZE,
	10, 10, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);

	// SRF08 ULTRASONIC SENSOR THREAD
//	if (tx_thread_create(&g_threads[ultrasonic_sensor_e].thread_ptr, "ultrasonicS_thread", UltrasonicEntry, 0, g_threads[ultrasonic_sensor_e].thread_Stack, THREAD_STACK_SIZE,
//	1, 1, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
//		status = TX_THREAD_ERROR;
//	if (status == TX_THREAD_ERROR)
//	{
//		sprintf(err_msg, "FailUS\r\n");
//		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);
//	}

	// DC MOTOR THREAD
	if (tx_thread_create(&g_threads[dc_motor_e].thread_ptr, "motor_thread", DcMotor, 0, g_threads[dc_motor_e].thread_Stack, THREAD_STACK_SIZE,
	4, 4, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailDCmt\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);
	}

	// SERVO MOTOR THREAD
	if (tx_thread_create(&g_threads[servo_motor_e].thread_ptr, "servo_thread", ServoMotor, 0, g_threads[servo_motor_e].thread_Stack, THREAD_STACK_SIZE,
	5, 5, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "Failservmt\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);
	}

	// SPEED SENSOR THREAD
	if (tx_thread_create(&g_threads[speed_sensor_e].thread_ptr, "speedS_thread", SpeedSensor, 0, g_threads[speed_sensor_e].thread_Stack, THREAD_STACK_SIZE,
	6, 6, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailSS\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);
	}

	// CAN TX THREAD
	if (tx_thread_create(&g_threads[can_tx_e].thread_ptr, "Can TX", CanTx, 0, g_threads[can_tx_e].thread_Stack, THREAD_STACK_SIZE,
	7, 7, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailcanTX\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);
	}

	// CAN RX THREAD
	if (tx_thread_create(&g_threads[can_rx_e].thread_ptr, "Can RX", CanRx, 0, g_threads[can_rx_e].thread_Stack, THREAD_STACK_SIZE,
	2, 2, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailcanRX\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);
	}

	// HTS221 SENSOR THREAD
	if (tx_thread_create(&g_threads[sensor_hts221_e].thread_ptr, "HTS221", SensorHTS221Thread, 0, g_threads[sensor_hts221_e].thread_Stack, THREAD_STACK_SIZE,
	8, 8, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailHTS221\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);
	}

	// BATTERY SENSOR THREAD
	if (tx_thread_create(&g_threads[sensor_battery_e].thread_ptr, "Battery", SensorBatteryThread, 0, g_threads[sensor_battery_e].thread_Stack, THREAD_STACK_SIZE,
	8, 8, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailBattery\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), UART_INIT_TIMEOUT_MS);
	}

	for (uint8_t idx = supervisor_e; idx <= ultrasonic_sensor_e; idx++)
		sysview_register_thread(&g_threads[idx].thread_ptr);
}

