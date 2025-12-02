#include "app_threadx.h"

VOID dc_motor(ULONG initial_input)
{
	t_can_message 	msg;
    ULONG			actual_flags;

	//const char *msg_tick = "DCmotor\r\n";


    while (1)
    {
    	//HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), HAL_MAX_DELAY);
        // Wait until a speed command event is set
        tx_event_flags_get(&event_flags, FLAG_CAN_SPEED_CMD,
        TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);

        // Process queued messages
        while (tx_queue_receive(&queue_speed_cmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
        {
			//CALL DC MOTOR SET!!
		}
        tx_thread_sleep(50);
	}
}
