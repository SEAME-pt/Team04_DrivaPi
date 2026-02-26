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

/**
* @brief
*
* @param buffer
* @param number
* @param precision
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
* @brief
*
* @param msg
* @param speed
*/
void CraftSpeedMessage(t_can_message *msg, float speed)
{
	msg->id = 0x100;
	msg->len = 4;
	memcpy(msg->data, &speed, 4);
	CanSend(msg);
}

/**
* @brief
*
* @param msg
* @return int
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
	{
		/* FIFO full or error - just skip this message */
		return 1;
	}
	return 0;
}

/**
* @brief 
*
* @param initial_input
* @return VOID
*/
VOID CanTx(ULONG initial_input)
{
	t_can_message msg;
	ULONG actual_flags;

	while (1)
	{
		tx_event_flags_get(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);

		tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
		float speed = g_vehicleSpeed;
		tx_mutex_put(&g_speedDataMutex);

		CraftSpeedMessage(&msg, speed);

		/* Sleep for 1 second to avoid CAN bus saturation */
		tx_thread_sleep(10);
	}
}
