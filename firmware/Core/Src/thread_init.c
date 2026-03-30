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
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);

	// SRF08 ULTRASONIC SENSOR THREAD
	if (tx_thread_create(&g_threads[ultrasonic_sensor_e].thread_ptr, "ultrasonicS_thread", UltrasonicEntry, 0, g_threads[ultrasonic_sensor_e].thread_Stack, THREAD_STACK_SIZE,
	1, 1, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailUS\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

	// DC MOTOR THREAD
	if (tx_thread_create(&g_threads[dc_motor_e].thread_ptr, "motor_thread", DcMotor, 0, g_threads[dc_motor_e].thread_Stack, THREAD_STACK_SIZE,
	4, 4, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailDCmt\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

	// SERVO MOTOR THREAD
	if (tx_thread_create(&g_threads[servo_motor_e].thread_ptr, "servo_thread", ServoMotor, 0, g_threads[servo_motor_e].thread_Stack, THREAD_STACK_SIZE,
	5, 5, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "Failservmt\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

	// SPEED SENSOR THREAD
	if (tx_thread_create(&g_threads[speed_sensor_e].thread_ptr, "speedS_thread", SpeedSensor, 0, g_threads[speed_sensor_e].thread_Stack, THREAD_STACK_SIZE,
	6, 6, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailSS\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

	// CAN TX THREAD
	if (tx_thread_create(&g_threads[can_tx_e].thread_ptr, "Can TX", CanTx, 0, g_threads[can_tx_e].thread_Stack, THREAD_STACK_SIZE,
	7, 7, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailcanTX\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

	// CAN RX THREAD
	if (tx_thread_create(&g_threads[can_rx_e].thread_ptr, "Can RX", CanRx, 0, g_threads[can_rx_e].thread_Stack, THREAD_STACK_SIZE,
	2, 2, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailcanRX\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

	// HTS221 SENSOR THREAD
	if (tx_thread_create(&g_threads[sensor_hts221_e].thread_ptr, "HTS221", SensorHTS221Thread, 0, g_threads[sensor_hts221_e].thread_Stack, THREAD_STACK_SIZE,
	15, 15, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailHTS221\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

	// BATTERY SENSOR THREAD
	if (tx_thread_create(&g_threads[sensor_battery_e].thread_ptr, "Battery", SensorBatteryThread, 0, g_threads[sensor_battery_e].thread_Stack, THREAD_STACK_SIZE,
	15, 15, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailBattery\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t *)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}
}
