#include "app_threadx.h"

VOID servo_motor(ULONG initial_input)
{
	t_can_message	msg;
    ULONG 			actual_flags;

	const char *msg_tick = "Smotor\r\n";

    while (1)
    {
    	HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), HAL_MAX_DELAY);
        // Wait until a steering command event is set
        tx_event_flags_get(&event_flags, FLAG_CAN_STEER_CMD,
        TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);

        while (tx_queue_receive(&queue_steer_cmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
        {
			//call steer function!!
        }
        tx_thread_sleep(50);
   }
}
