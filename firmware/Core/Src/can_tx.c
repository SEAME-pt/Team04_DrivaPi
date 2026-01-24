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
	HAL_UART_Transmit(&huart1, (uint8_t*)msg->data, 4, 100);
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
	tx_header.Identifier = msg->id;
	tx_header.IdType = FDCAN_STANDARD_ID;
	tx_header.TxFrameType = FDCAN_DATA_FRAME;
	tx_header.DataLength = FDCAN_DLC_BYTES_4;
	tx_header.ErrorStateIndicator = FDCAN_ESI_ACTIVE;
	tx_header.BitRateSwitch = FDCAN_BRS_OFF;
	tx_header.FDFormat = FDCAN_CLASSIC_CAN;
	tx_header.TxEventFifoControl = FDCAN_NO_TX_EVENTS;
	tx_header.MessageMarker = 0;

	char wake_up_message[20] = "TransCan!\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)wake_up_message, strlen(wake_up_message), 10);

	if (HAL_FDCAN_AddMessageToTxFifoQ(&hfdcan1, &tx_header, (uint8_t*)msg->data) != HAL_OK)
	{
		char err_msg[20] = "FailTransmitCAN!\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), 10);
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

	const char *msg_tick = "TX\r\n";

	while (1)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), 10);

		tx_event_flags_get(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);


		tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
		float speed = g_vehicleSpeed;
		tx_mutex_put(&g_speedDataMutex);

		CraftSpeedMessage(&msg, speed);

		tx_thread_sleep(10);
	}
}