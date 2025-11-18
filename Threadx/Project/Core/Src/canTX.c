#include "app_threadx.h"

void make_speed_status_msg(t_can_message *msg, float speed)
{
	msg->id = 0x201; // Example ID for speed status
	msg->len = 4;
	// Assuming speed is a float, we copy its byte representation
	memcpy(msg->data, &speed, sizeof(float));
}

void can_send(t_can_message* msg)
{
	// Placeholder for CAN send implementation
}

VOID canTX(ULONG initial_input)
{
    t_can_message	msg;
    ULONG 			actual_flags;

    while (1)
    {
        // Wait until sensor thread signals new data
        tx_event_flags_get(&event_flags, FLAG_SENSOR_UPDATE,
        TX_OR_CLEAR, &actual_flags, TX_WAIT_FOREVER);

        tx_mutex_get(&speed_data_mutex, TX_WAIT_FOREVER);
        float speed = g_vehicle_speed;
        tx_mutex_put(&speed_data_mutex);

        make_speed_status_msg(&msg, speed);
        can_send(&msg);
    }
}