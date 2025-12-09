int main()
{
    while (1)

 	  FDCAN_TxHeaderTypeDef txHeader;
	  uint8_t txData[8];

	  txHeader.Identifier = 0x123;
	  txHeader.IdType = FDCAN_STANDARD_ID;
	  txHeader.TxFrameType = FDCAN_DATA_FRAME;
	  txHeader.DataLength = FDCAN_DLC_BYTES_8;
	  txHeader.ErrorStateIndicator = FDCAN_ESI_ACTIVE;
	  txHeader.BitRateSwitch = FDCAN_BRS_OFF;
	  txHeader.FDFormat = FDCAN_CLASSIC_CAN;
	  txHeader.TxEventFifoControl = FDCAN_NO_TX_EVENTS;
	  txHeader.MessageMarker = 0;

	  // Store timestamp (cycle counter)
	  t_send = DWT->CYCCNT;
	  memcpy(txData, &t_send, 4);
	  memset(txData + 4, 0, 4);

	  HAL_FDCAN_AddMessageToTxFifoQ(&hfdcan1, &txHeader, txData);

	  HAL_Delay(10);
  }   // Main loop does nothing, all action happens in interrupts


void HAL_FDCAN_RxFifo0Callback(FDCAN_HandleTypeDef *hfdcan, uint32_t RxFifo0ITs)
{
    if (RxFifo0ITs & FDCAN_IT_RX_FIFO0_NEW_MESSAGE)
    {
        FDCAN_RxHeaderTypeDef rxHeader;
        uint8_t rxData[8];

        if (HAL_FDCAN_GetRxMessage(hfdcan, FDCAN_RX_FIFO0, &rxHeader, rxData) == HAL_OK)
        {
            uint32_t t_recv = DWT->CYCCNT;   // cycles at RX interrupt
            uint32_t sent_cycles = *((uint32_t*)rxData);
            uint32_t latency_cycles = t_recv - sent_cycles;

            float latency_us = latency_cycles / (SystemCoreClock / 1e6f);

            char msg[64];
            uint32_t latency_us_i = (uint32_t) latency_us;
            sprintf(msg, "%lu\r\n", latency_us_i);
            HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
        }
    }
}