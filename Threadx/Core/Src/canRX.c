#include "app_threadx.h"

uint8_t can_receive(t_can_message *msg)
{
    FDCAN_RxHeaderTypeDef rxHeader;
    uint8_t rxData[8];

    if (HAL_FDCAN_GetRxFifoFillLevel(&hfdcan1, FDCAN_RX_FIFO0) > 0)
    {
        if (HAL_FDCAN_GetRxMessage(&hfdcan1, FDCAN_RX_FIFO0, &rxHeader, rxData) == HAL_OK)
        {
            msg->id = rxHeader.Identifier;
            msg->len = (rxHeader.DataLength <= 8) ? rxHeader.DataLength : 8;
            memcpy(msg->data, rxData, msg->len);
            return 1; // message received
        }
    }
    return 0;   
}

VOID canRX(ULONG initial_input)
{
    t_can_message msg;

    const char *msg_tick = "RX\r\n";
    while (1)
    {
    	HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), 10);
        if (can_receive(&msg))
        {
            switch (msg.id)
            {
                case CMD_SPEED:
                    tx_queue_send(&queue_speed_cmd, &msg, TX_NO_WAIT);
                    tx_event_flags_set(&event_flags, FLAG_CAN_SPEED_CMD, TX_OR);

                case CMD_STEERING:
                    tx_queue_send(&queue_steer_cmd, &msg, TX_NO_WAIT);
                    tx_event_flags_set(&event_flags, FLAG_CAN_STEER_CMD, TX_OR);
            }
        }

        tx_thread_sleep(50);
    }
}
