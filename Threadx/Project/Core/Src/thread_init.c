#include "app_threadx.h"

void thread_init(void)
{	
    uint8_t status;
	status = 0;
	char err_msg[20] = "FailSP\r\n";

										//SUPERVISOR THREAD
	if (tx_thread_create(&threads[supervisor_e].thread_ptr, "led_thread1", ld1_thread_entry, 0, threads[supervisor_e].thread_Stack, THREAD_STACK_SIZE,
	10, 10, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
		HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), HAL_MAX_DELAY);

										//DC MOTOR THREAD
	if (tx_thread_create(&threads[dc_motor_e].thread_ptr, "motor_thread", dc_motor, 0, threads[dc_motor_e].thread_Stack, THREAD_STACK_SIZE,
	4, 4, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailDCmt\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

										//SERVO MOTOR THREAD
	if (tx_thread_create(&threads[servo_motor_e].thread_ptr, "servo_thread", servo_motor, 0, threads[servo_motor_e].thread_Stack, THREAD_STACK_SIZE,
	5, 5, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{   
		sprintf(err_msg, "Failservmt\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

										//SPEED SENSOR THREAD
	if (tx_thread_create(&threads[speed_sensor_e].thread_ptr, "speedS_thread", ld1_thread_entry, 0, threads[speed_sensor_e].thread_Stack, THREAD_STACK_SIZE,
	6, 6, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailSS\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

										//CAN TX THREAD
	if (tx_thread_create(&threads[can_tx_e].thread_ptr, "Can TX", canTX, 0, threads[can_tx_e].thread_Stack, THREAD_STACK_SIZE,
	7, 7, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailcanTX\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}

										//CAN RX THREAD
	if (tx_thread_create(&threads[can_rx_e].thread_ptr, "Can RX", canRX, 0, threads[can_rx_e].thread_Stack, THREAD_STACK_SIZE,
	2, 2, TX_NO_TIME_SLICE, TX_AUTO_START) != TX_SUCCESS)
		status = TX_THREAD_ERROR;
	if (status == TX_THREAD_ERROR)
	{
		sprintf(err_msg, "FailcanRX\r\n");
		HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), HAL_MAX_DELAY);
	}
}