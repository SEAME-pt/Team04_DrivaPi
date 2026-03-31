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
  ULONG loop_counter = 0u;
  ULONG now_ticks;
  ULONG age_ticks;
  const ULONG stale_threshold_ticks = (ULONG)(2u * TX_TIMER_TICKS_PER_SECOND);

  TX_PARAMETER_NOT_USED(initial_input);

	while (1)
	{
    if ((loop_counter % 20u) == 0u)
    {
      now_ticks = tx_time_get();
      age_ticks = now_ticks - g_speed_module_last_tick;

      if ((g_speed_module_last_tick != 0u) && (age_ticks <= stale_threshold_ticks))
      {
        UartPrint("Supervisor: speed module heartbeat OK\r\n");
      }
      else
      {
        UartPrint("Supervisor: speed module heartbeat STALE\r\n");
      }
    }

    loop_counter++;
		tx_thread_sleep(50);
	}
}
