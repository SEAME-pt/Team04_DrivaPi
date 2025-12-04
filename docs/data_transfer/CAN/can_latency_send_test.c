#include "main.h"
#include <stdint.h>
#include <string.h>

uint32_t millis(void) {
    return HAL_GetTick();  // Returns milliseconds since startup
}

void send_can_message(void) {
    CAN_TxHeaderTypeDef txHeader;
    uint8_t data[8] = {0};
    uint32_t txMailbox;

    // Fill CAN header
    txHeader.StdId = 0x123;
    txHeader.IDE = CAN_ID_STD;
    txHeader.RTR = CAN_RTR_DATA;
    txHeader.DLC = 4;  // 4 bytes for timestamp

    uint32_t timestamp = millis();
    memcpy(data, &timestamp, sizeof(timestamp));

    HAL_CAN_AddTxMessage(&hcan, &txHeader, data, &txMailbox);
}
