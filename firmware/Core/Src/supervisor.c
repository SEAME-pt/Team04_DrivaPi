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
    UartPrint("Supervisor thread is running\r\n");
		tx_thread_sleep(50);
	}
}
