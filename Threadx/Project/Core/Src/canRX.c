#include "app_threadx.h"

uint8_t can_receive(t_can_message *msg)
{
	return (1);
}

VOID canRX(ULONG initial_input)
{
	t_can_message msg;

	while (1)
    {
        if (can_receive(&msg))
        {
            if (msg.id == CMD_SPEED)
            {
                tx_queue_send(&queue_speed_cmd, &msg, TX_NO_WAIT);
                tx_event_flags_set(&event_flags, FLAG_CAN_SPEED_CMD, TX_OR);
            }
            else if (msg.id == CMD_STEERING)
            {
                tx_queue_send(&queue_steer_cmd, &msg, TX_NO_WAIT);
                tx_event_flags_set(&event_flags, FLAG_CAN_STEER_CMD, TX_OR);
            }
        }
    }
}