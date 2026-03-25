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
		HAL_UART_Transmit(&huart1, (uint8_t *)"BANANA3\n", (uint16_t)8, 20);
		tx_thread_sleep(50);
	}
}
