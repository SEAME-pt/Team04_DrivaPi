#include "app_threadx.h"
int can_send(t_can_message* msg);

void FloatToUint8(uint8_t* buffer, float number, int precision) {
    // 1. Handle negative numbers
    float val = (number < 0) ? -number : number;

    // 2. Extract the integer part
    int intPart = (int)val;

    // 3. Extract the decimal part
    // We multiply by 10^precision to turn decimals into an integer
    // e.g., 0.456 * 100 = 45.6 -> (int)45
    float remainder = val - intPart;
    int decPart = (int)(remainder * pow(10, precision));

    // 4. Format into the buffer
    // %c = sign, %d = integer, . = dot, %0*d = decimal part with leading zeros
    // The "0*d" ensures that 3.05 prints as "3.05" not "3.5"
    sprintf((char*)buffer, "%d.%0*d", intPart, precision, decPart);
}

void make_speed_status_msg(t_can_message *msg, float speed)
{
    msg->id = 0x100;
    msg->len = 4;

    // Copy float bytes to CAN data

    // --- DEBUG PRINTING ---
    // uint8_t TxData[8];

    // FloatToUint8(TxData, speed, 2);

    // 1. Extract the float back from the data bytes (safe against alignment issues)
    //memcpy(TxData, &speed, 4);

    // 2. Format to string (%.2f limits to 2 decimal places)

    // 3. Transmit

    memcpy(msg->data, &speed, 4);

    HAL_UART_Transmit(&huart1, (uint8_t*)msg->data, 4, 100);

    can_send(msg);

}

int can_send(t_can_message* msg)
{
    FDCAN_TxHeaderTypeDef TxHeader;
    TxHeader.Identifier = msg->id;
    TxHeader.IdType = FDCAN_STANDARD_ID;
    TxHeader.TxFrameType = FDCAN_DATA_FRAME;
    TxHeader.DataLength = FDCAN_DLC_BYTES_4;
    TxHeader.ErrorStateIndicator = FDCAN_ESI_ACTIVE;
    TxHeader.BitRateSwitch = FDCAN_BRS_OFF;
    TxHeader.FDFormat = FDCAN_CLASSIC_CAN;
    TxHeader.TxEventFifoControl = FDCAN_NO_TX_EVENTS;
    TxHeader.MessageMarker = 0;

    char err_msg[20] = "TransCan!\r\n";
    HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), 10);

    if (HAL_FDCAN_AddMessageToTxFifoQ(&hfdcan1, &TxHeader, (uint8_t*)msg->data) != HAL_OK)
    {
        char err_msg[20] = "FailTransmitCAN!\r\n";
        HAL_UART_Transmit(&huart1, (uint8_t*)err_msg, strlen(err_msg), 10);
        return 1;
    }
    return 0;
}

VOID canTX(ULONG initial_input)
{
    t_can_message msg;
    ULONG actual_flags;

	const char *msg_tick = "TX\r\n";

    while (1)
    {
    	HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), 10);
        // Wait until sensor thread signals new data
        tx_event_flags_get(&event_flags, FLAG_SENSOR_UPDATE, TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);

        // Read speed safely with mutex
        tx_mutex_get(&speed_data_mutex, TX_WAIT_FOREVER);
        float speed = g_vehicle_speed;
        tx_mutex_put(&speed_data_mutex);

        // Build CAN message and send
        make_speed_status_msg(&msg, speed);

        // Optional: send additional periodic messages
        tx_thread_sleep(10);
     // Sleep for a tick (ThreadX)
    }
}
