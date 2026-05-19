/**
 ******************************************************************************
 * @file    can_tx.c
 * @author  DrivaPi Team
 * @brief   This file contains the CAN TX thread function. This thread is responsible
 * for sending CAN messages based on the vehicle's speed data.
 ******************************************************************************
 * @attention
 *
*/
#include "app_threadx.h"

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
* @brief Build and send a CAN message with the current speed.
*
* @param msg Message container to populate.
* @param speed Vehicle speed value to transmit.
*/
void CraftSpeedMessage(t_can_message *msg, float speed)
{
	msg->id = 0x100;
	msg->len = 4;
	memcpy(msg->data, &speed, 4);
	CanSend(msg);
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
	uint8_t attempt;

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

	for (attempt = 0; attempt < 3; ++attempt)
	{
		if (HAL_FDCAN_AddMessageToTxFifoQ(&hfdcan1, &tx_header, (uint8_t*)msg->data) == HAL_OK)
			return 0;
		tx_thread_sleep(1);
	}

	return 1;
}

/**
* @brief Build and send Battery and INA231 CAN messages.
* @note Expects g_canMutex to be held by the caller.
*/
static void PublishBatteryAndInaData(void)
{
	t_can_message batt_msg;
	t_can_message ina_msg;
	t_can_message ina_cur_msg;
#if DEBUG_DIAGNOSTICS
	static uint32_t ina_dbg_count = 0u;
#endif

	float stm_voltage = 0.0f;
	uint8_t stm_percentage = 0xFFu;
	uint8_t stm_valid = 0u;
	float voltage = 0.0f;
	float current = 0.0f;
	uint8_t percentage = 0xFFu;
	uint8_t ina_valid = 0u;

	memset(&batt_msg, 0, sizeof(batt_msg));
	batt_msg.id = CAN_ID_BATTERY_DATA;
	batt_msg.len = 5;

	memset(&ina_msg, 0, sizeof(ina_msg));
	ina_msg.id = CAN_ID_INA231_DATA;
	ina_msg.len = 5;

	memset(&ina_cur_msg, 0, sizeof(ina_cur_msg));
	ina_cur_msg.id = CAN_ID_INA231_CURRENT;
	ina_cur_msg.len = 4;

	if (tx_mutex_get(&g_sensorDataMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
	{
		if (g_batteryData.data_valid)
		{
			stm_voltage = g_batteryData.voltage;
			stm_percentage = g_batteryData.percentage;
			stm_valid = 1u;
		}
		if (g_ina231Data.data_valid)
		{
			voltage = g_ina231Data.voltage;
			current = g_ina231Data.current;
			percentage = g_ina231Data.percentage;
			ina_valid = 1u;
		}
		tx_mutex_put(&g_sensorDataMutex);
	}

	if (stm_valid)
	{
		batt_msg.data[0] = stm_percentage;
		memcpy(&batt_msg.data[1], &stm_voltage, 4);
		(void)CanSend(&batt_msg);
	}

	if (ina_valid)
	{
#if DEBUG_DIAGNOSTICS
		uint32_t current_bits = 0u;
#endif
		ina_msg.data[0] = percentage;
		memcpy(&ina_msg.data[1], &voltage, 4);
		memcpy(&ina_cur_msg.data[0], &current, 4);
		(void)CanSend(&ina_msg);
		(void)CanSend(&ina_cur_msg);
#if DEBUG_DIAGNOSTICS
		memcpy(&current_bits, &current, sizeof(current_bits));
		ina_dbg_count++;
		if ((ina_dbg_count % 10u) == 0u)
		{
			UartPrintf("[CAN 0x211] bits=0x%08lX bytes=%02X %02X %02X %02X\r\n", (unsigned long)current_bits, (unsigned int)ina_cur_msg.data[0], (unsigned int)ina_cur_msg.data[1], (unsigned int)ina_cur_msg.data[2], (unsigned int)ina_cur_msg.data[3]);
		}
#endif
	}
}

/**
* @brief Build and send HTS221 CAN message.
* @note Expects g_canMutex to be held by the caller.
*/
static void PublishHtsData(void)
{
	t_can_message hts_msg;
	float temperature = 0.0f;
	float humidity = 0.0f;
	uint8_t hts_valid = 0u;

	memset(&hts_msg, 0, sizeof(hts_msg));
	hts_msg.id = CAN_ID_HTS221_DATA;
	hts_msg.len = 8;

	if (tx_mutex_get(&g_sensorDataMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
	{
		if (g_hts221Data.data_valid)
		{
			temperature = g_hts221Data.temperature;
			humidity = g_hts221Data.humidity;
			hts_valid = 1u;
		}
		tx_mutex_put(&g_sensorDataMutex);
	}

	if (hts_valid)
	{
		memcpy(&hts_msg.data[0], &temperature, 4);
		memcpy(&hts_msg.data[4], &humidity, 4);
		(void)CanSend(&hts_msg);
	}
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
	ULONG last_ina_send = tx_time_get();
	ULONG last_hts_send = tx_time_get();
	const ULONG ina_send_ticks = 100; /* 1 second @ 100Hz tick */
	const ULONG hts_send_ticks = 500; /* 5 seconds @ 100Hz tick */

	while (1)
	{
		ULONG now = tx_time_get();
		tx_event_flags_get(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);

		float speed = 0.0f;
		if (tx_mutex_get(&g_speedDataMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
			speed = g_vehicleSpeed;
		else
		{
			tx_thread_sleep(1);
			continue;
		}
		tx_mutex_put(&g_speedDataMutex);

		if (tx_mutex_get(&g_canMutex, 5) == TX_SUCCESS)
		{
			CraftSpeedMessage(&msg, speed);

			if ((now - last_ina_send) >= ina_send_ticks)
			{
				PublishBatteryAndInaData();
				last_ina_send = now;
			}

			if ((now - last_hts_send) >= hts_send_ticks)
			{
				PublishHtsData();
				last_hts_send = now;
			}
			tx_mutex_put(&g_canMutex);
		}
		tx_thread_sleep(100);
	}
}
