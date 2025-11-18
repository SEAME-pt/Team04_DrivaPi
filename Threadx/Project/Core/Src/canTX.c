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
    FDCAN_TxHeaderTypeDef TxHeader;
    TxHeader.Identifier = msg->id;
    TxHeader.IdType = FDCAN_STANDARD_ID;
    TxHeader.TxFrameType = FDCAN_DATA_FRAME;
    TxHeader.DataLength = msg->len; // assuming len <= 8
    TxHeader.ErrorStateIndicator = FDCAN_ESI_ACTIVE;
    TxHeader.BitRateSwitch = FDCAN_BRS_OFF;
    TxHeader.FDFormat = FDCAN_CLASSIC_CAN;
    TxHeader.TxEventFifoControl = FDCAN_NO_TX_EVENTS;
    TxHeader.MessageMarker = 0;

    if (HAL_FDCAN_AddMessageToTxFifoQ(&hfdcan1, &TxHeader, msg->data) != HAL_OK)
    {
        char err_msg[20] = "FailTransmitCAN!\r\n";
        HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), HAL_MAX_DELAY);
    }
}

VOID canTX(ULONG initial_input)
{
    t_can_message msg;
    ULONG actual_flags;

    while (1)
    {
        // Wait until sensor thread signals new data
        tx_event_flags_get(&event_flags, FLAG_SENSOR_UPDATE, TX_OR_CLEAR, &actual_flags, TX_WAIT_FOREVER);

        // Read speed safely with mutex
        tx_mutex_get(&speed_data_mutex, TX_WAIT_FOREVER);
        float speed = g_vehicle_speed;
        tx_mutex_put(&speed_data_mutex);

        // Build CAN message and send
        make_speed_status_msg(&msg, speed);
        can_send(&msg);

        // Optional: send additional periodic messages
        tx_thread_sleep(1); // Sleep for a tick (ThreadX)
    }
}
