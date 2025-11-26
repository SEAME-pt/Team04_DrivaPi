
#include "app_threadx.h"

VOID ld1_thread_entry(ULONG initial_input)
{
	const char *msg_tick = "Tick\r\n";
	while (1)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), HAL_MAX_DELAY);
		tx_thread_sleep(100);
	}
}