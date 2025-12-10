int main(void)
{
	//existing code
	MX_FDCAN1_Init();
	
	HAL_FDCAN_ActivateNotification(&hfdcan1, FDCAN_IT_RX_FIFO0_NEW_MESSAGE, 0);

	HAL_FDCAN_Start(&hfdcan1);

	while (1)   
	{
		HAL_Delay(1);
	}
	return 0;
}

void HAL_FDCAN_RxFifo0Callback(FDCAN_HandleTypeDef *hfdcan, uint32_t RxFifo0ITs)
{
	if (RxFifo0ITs & FDCAN_IT_RX_FIFO0_NEW_MESSAGE)
	{
		FDCAN_RxHeaderTypeDef rxHeader;
		uint8_t rxData[8];

		if (HAL_FDCAN_GetRxMessage(hfdcan, FDCAN_RX_FIFO0, &rxHeader, rxData) == HAL_OK)
		{
			// Optional: toggle LED or UART print
			// HAL_GPIO_TogglePin(LED_RED_GPIO_Port, LED_RED_Pin);

			// Echo back immediately
			FDCAN_TxHeaderTypeDef txHeader;
			txHeader.Identifier = rxHeader.Identifier;
			txHeader.IdType = rxHeader.IdType;
			txHeader.TxFrameType = FDCAN_DATA_FRAME;
			txHeader.DataLength = rxHeader.DataLength;
			txHeader.ErrorStateIndicator = FDCAN_ESI_ACTIVE;
			txHeader.BitRateSwitch = FDCAN_BRS_OFF;
			txHeader.FDFormat = FDCAN_CLASSIC_CAN;
			txHeader.TxEventFifoControl = FDCAN_NO_TX_EVENTS;
			txHeader.MessageMarker = 0;

			HAL_FDCAN_AddMessageToTxFifoQ(hfdcan, &txHeader, rxData);
		}
	}
}