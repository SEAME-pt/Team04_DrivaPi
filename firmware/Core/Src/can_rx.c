/**
  ******************************************************************************
  * @file    firmware/Core/Src/can_rx.c
  * @author  DrivaPi Team
  * @brief   This file contains the CAN RX thread code. This thread is responsible
  *          for receiving CAN messages and dispatching them to the appropriate
  *          queues based on their IDs.
  ******************************************************************************
  * @attention
  *
*/
#include "app_threadx.h"

/**
* @brief Try to fetch a CAN message from RX FIFO0.
*
* @param msg Output message buffer to fill on success.
* @return uint8_t 1 when a message is read, 0 otherwise.
*/
uint8_t CanReceive(t_can_message *msg)
{
	FDCAN_RxHeaderTypeDef rx_header;
	uint8_t rx_data[8];

	if (HAL_FDCAN_GetRxFifoFillLevel(&hfdcan1, FDCAN_RX_FIFO0) > 0)
	{
		if (HAL_FDCAN_GetRxMessage(&hfdcan1, FDCAN_RX_FIFO0, &rx_header, rx_data) == HAL_OK)
		{
			msg->id = rx_header.Identifier;
			msg->len = 8;
			memcpy(msg->data, rx_data, msg->len);
			return 1; // Message received
		}
	}
	return 0;
}

/**
* @brief CAN RX thread entry that dispatches messages to queues.
*
* @param initial_input ThreadX initial input (unused).
* @return void
*/
void CanRx(ULONG initial_input)
{
	t_can_message msg;

	while (1)
	{
		tx_mutex_get(&g_canMutex, TX_WAIT_FOREVER);
		uint8_t received = CanReceive(&msg);
		tx_mutex_put(&g_canMutex);

		if (received)
		{
			if (msg.id == CMD_SPEED){
				tx_queue_send(&g_queueSpeedCmd, &msg, TX_NO_WAIT);
				tx_event_flags_set(&g_eventFlags, FLAG_CAN_SPEED_CMD, TX_OR);
			}
			if (msg.id == CMD_STEERING){
				tx_queue_send(&g_queueSteerCmd, &msg, TX_NO_WAIT);
				tx_event_flags_set(&g_eventFlags, FLAG_CAN_STEER_CMD, TX_OR);
			}
		}
		else
		{
			tx_thread_sleep(1);
		}
	}
}
