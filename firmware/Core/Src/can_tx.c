/**
  ******************************************************************************
  * @file    can_tx.c
  * @author  DrivaPi Team
  * @brief   This file contains the CAN TX thread function. This thread is responsible
  *          for sending CAN messages based on the vehicle's speed data.
  ******************************************************************************
  * @attention
  *
*/
#include "app_threadx.h"

static UINT QueueCanMessage(const t_can_message *msg)
{
	if (msg == NULL)
	{
		return TX_PTR_ERROR;
	}

	return tx_queue_send(&g_queueCanTx, (VOID *)msg, TX_NO_WAIT);
}

static VOID QueueHts221Telemetry(VOID)
{
	HTS221_Data_t data;
	t_can_message msg;
	static int16_t last_temp_int = -99;
	static int16_t last_hum_int = -99;
	static ULONG last_send_time = 0u;
	const ULONG heartbeat_interval = 3000u;

	if (SensorsGetHts221Data(&data) != TX_SUCCESS)
	{
		return;
	}

	if (data.data_valid == 0u)
	{
		return;
	}

	int16_t temp_int = (int16_t)data.temperature;
	int16_t hum_int = (int16_t)data.humidity;
	ULONG current_time = tx_time_get();

	if ((temp_int == last_temp_int) &&
		(hum_int == last_hum_int) &&
		((current_time - last_send_time) < heartbeat_interval))
	{
		return;
	}

	memset(&msg, 0, sizeof(msg));
	msg.id = CAN_ID_HTS221_DATA;
	msg.len = 8;
	memcpy(&msg.data[0], &data.temperature, 4);
	memcpy(&msg.data[4], &data.humidity, 4);

	if (QueueCanMessage(&msg) == TX_SUCCESS)
	{
		last_temp_int = temp_int;
		last_hum_int = hum_int;
		last_send_time = current_time;
	}
}

static VOID QueueBatteryTelemetry(VOID)
{
	Battery_Data_t data;
	t_can_message msg;
	static uint8_t last_percentage = 0xFFu;
	static float last_voltage = -1.0f;
	static ULONG last_send_time = 0u;
	const ULONG heartbeat_interval = 3000u;

	if (SensorsGetBatteryData(&data) != TX_SUCCESS)
	{
		return;
	}

	if (data.data_valid == 0u)
	{
		return;
	}

	ULONG current_time = tx_time_get();
	if ((data.percentage == last_percentage) &&
		(fabsf(data.voltage - last_voltage) <= BATTERY_VOLTAGE_EPSILON) &&
		((current_time - last_send_time) < heartbeat_interval))
	{
		return;
	}

	memset(&msg, 0, sizeof(msg));
	msg.id = CAN_ID_BATTERY_DATA;
	msg.len = 5;
	msg.data[0] = data.percentage;
	memcpy(&msg.data[1], &data.voltage, 4);

	if (QueueCanMessage(&msg) == TX_SUCCESS)
	{
		last_percentage = data.percentage;
		last_voltage = data.voltage;
		last_send_time = current_time;
	}
}

/**
* @brief Format a float into a fixed-precision ASCII buffer.
*
* @param buffer Destination buffer for the formatted string.
* @param number Value to convert.
* @param precision Number of decimal places.
*/
void FloatToUint8(uint8_t* buffer, float number, int precision)
{
	float val = (number < 0) ? -number : number;
	int int_part = (int)val;
	float remainder = val - int_part;
	int dec_part = (int)(remainder * pow(10, precision));
	sprintf((char*)buffer, "%d.%0*d", int_part, precision, dec_part);
}

/**
* @brief Build a CAN message with the current speed.
*
* @param msg Message container to populate.
* @param speed Vehicle speed value to transmit.
*/
void CraftSpeedMessage(t_can_message *msg, float speed)
{
	msg->id = 0x100;
	msg->len = 4;
	memcpy(msg->data, &speed, 4);
}

/**
* @brief Send a CAN message through FDCAN1 TX FIFO.
*
* @param msg Message to send.
* @return int 0 on success, 1 on failure.
*/
int CanSend(t_can_message* msg)
{
	FDCAN_TxHeaderTypeDef tx_header;
	
	const uint32_t dlc_map[] = {
		FDCAN_DLC_BYTES_0,
		FDCAN_DLC_BYTES_1,
		FDCAN_DLC_BYTES_2,
		FDCAN_DLC_BYTES_3,
		FDCAN_DLC_BYTES_4,
		FDCAN_DLC_BYTES_5,
		FDCAN_DLC_BYTES_6,
		FDCAN_DLC_BYTES_7,
		FDCAN_DLC_BYTES_8
	};
	tx_header.Identifier = msg->id;
	tx_header.IdType = FDCAN_STANDARD_ID;
	tx_header.TxFrameType = FDCAN_DATA_FRAME;
	tx_header.DataLength = (msg->len <= 8) ? dlc_map[msg->len] : FDCAN_DLC_BYTES_8;
	tx_header.ErrorStateIndicator = FDCAN_ESI_ACTIVE;
	tx_header.BitRateSwitch = FDCAN_BRS_OFF;
	tx_header.FDFormat = FDCAN_CLASSIC_CAN;
	tx_header.TxEventFifoControl = FDCAN_NO_TX_EVENTS;
	tx_header.MessageMarker = 0;

	if (HAL_FDCAN_AddMessageToTxFifoQ(&hfdcan1, &tx_header, (uint8_t*)msg->data) != HAL_OK)
		return 1;
	return 0;
}

/**
* @brief CAN TX thread entry that publishes periodic speed data.
*
* @param initial_input ThreadX initial input (unused).
* @return VOID
*/
VOID CanTx(ULONG initial_input)
{
	t_can_message msg;
	ULONG actual_flags;

	TX_PARAMETER_NOT_USED(initial_input);

	while (1)
	{
		tx_event_flags_get(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);

		tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
		float speed = g_vehicleSpeed;
		tx_mutex_put(&g_speedDataMutex);

		memset(&msg, 0, sizeof(msg));
		CraftSpeedMessage(&msg, speed);
		(void)QueueCanMessage(&msg);

		QueueHts221Telemetry();
		QueueBatteryTelemetry();

		while (tx_queue_receive(&g_queueCanTx, &msg, TX_NO_WAIT) == TX_SUCCESS)
		{
			tx_mutex_get(&g_canMutex, TX_WAIT_FOREVER);
			(void)CanSend(&msg);
			tx_mutex_put(&g_canMutex);
		}

		tx_thread_sleep(20);
	}
}
