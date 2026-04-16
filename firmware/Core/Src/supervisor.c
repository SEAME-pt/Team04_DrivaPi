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
	ULONG last_send = tx_time_get();
	const ULONG heartbeat_ticks = 100;
	uint8_t seq = 0u;

	(void)initial_input;

	while (1)
	{
		ULONG now = tx_time_get();
		if ((now - last_send) >= heartbeat_ticks)
		{
			t_can_message msg;
			memset(&msg, 0, sizeof(msg));
			msg.id = CAN_ID_SYSTEM_WATCHDOG;
			msg.len = 2;
			msg.data[0] = 0xA5u;
			msg.data[1] = seq++;

			if (tx_mutex_get(&g_canMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
			{
				CanSend(&msg);
				tx_mutex_put(&g_canMutex);
			}

			last_send = now;
		}

		tx_thread_sleep(50);
	}
}
