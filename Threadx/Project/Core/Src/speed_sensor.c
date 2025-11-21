#include "app_threadx.h"

float read_speed_sensor(void)
{
	return 1;
}

VOID speed_sensor(ULONG initial_input)
{
	ULONG actual_flags;
	
	tx_event_flags_get(&event_flags, FLAG_SENSOR_UPDATE,
	TX_OR_CLEAR, &actual_flags, TX_WAIT_FOREVER);

	float current_speed = read_speed_sensor();

	tx_mutex_get(&speed_data_mutex, TX_WAIT_FOREVER);
	g_vehicle_speed = current_speed;
	tx_mutex_put(&speed_data_mutex);

	// Notify CAN TX thread that new data is ready
	tx_event_flags_set(&event_flags, FLAG_SENSOR_UPDATE, TX_OR);
}