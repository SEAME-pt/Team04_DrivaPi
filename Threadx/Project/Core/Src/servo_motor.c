#include "app_threadx.h"

VOID servo_motor(ULONG initial_input)
{
	t_can_message msg;
    ULONG actual_flags;

    while (1)
    {
        // Wait until a steering command event is set
        tx_event_flags_get(&event_flags, FLAG_CAN_STEER_CMD,
        TX_OR_CLEAR, &actual_flags, TX_WAIT_FOREVER);

        while (tx_queue_receive(&queue_steer_cmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
        {
			//call steer function!!
        }
    }
}