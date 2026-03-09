/**
 ******************************************************************************
* @file    firmware/Core/Src/supervisor.c
* @author  DrivaPi Team
* @brief   This file contains the supervisor thread function.
******************************************************************************
* @attention
*
*/

#include "app_threadx.h"

void DumpTraceBufferUART(void)
{
	HAL_UART_Transmit(&huart1, (uint8_t*)trace_buffer, TRACE_BUFFER_SIZE, HAL_MAX_DELAY);
}
	

/**
 * @brief
 *
 * @param initial_input
 * @return VOID
 */
void ld1_ThreadEntry(ULONG initial_input)
{
	while (1)
	{
		DumpTraceBufferUART();
		tx_thread_sleep(5000);
	}
}
