
#include "wifi_startup.h"

static const char 			*ssid = WIFI_SSID;
static const char			*password = WIFI_PASSWORD;

static volatile uint32_t	g_wifi_notify_irq_count = 0;
static volatile uint32_t	g_wifi_flow_irq_count = 0;
MX_WIFIObject_t				*g_wifi_obj = NULL;


MX_WIFIObject_t* WIFI_Get_Object(void)
{
    return g_wifi_obj;
}

void WIFIStartup(void)
{
	MX_WIFIObject_t     *wifi_obj = NULL;
	MX_WIFI_STATUS_T    status;
	uint8_t             ip_check[4] = {0};
	mwifi_ip_attr_t     static_ip = {
		.localip  = WIFI_STATIC_IP,
        .netmask  = WIFI_NETMASK,
        .gateway  = WIFI_GATEWAY,
        .dnserver = WIFI_DNS_SERVER

	};
	void                *ll_drv_context = NULL;
	char                status_msg[64];
	uint8_t             flow_seen_high = 0;
	uint8_t             notify_seen_high = 0;

	/* Board-specific rail enable used during Wi-Fi bring-up. */
	HAL_GPIO_WritePin(UCPD_PWR_GPIO_Port, UCPD_PWR_Pin, GPIO_PIN_SET);
	tx_thread_sleep(50);
	snprintf(status_msg, sizeof(status_msg), "[GPIO] UCPD_PWR=%d", (int)HAL_GPIO_ReadPin(UCPD_PWR_GPIO_Port, UCPD_PWR_Pin));
	if (MX_WIFI_DEBUG)
    	UartPrint(status_msg);

	/* WKUP_B is module-driven: keep MCU pin as input (Hi-Z). */
	{
		GPIO_InitTypeDef gpio_cfg = {0};
		gpio_cfg.Pin = WRLS_WKUP_B_Pin;
		gpio_cfg.Mode = GPIO_MODE_INPUT;
		gpio_cfg.Pull = GPIO_NOPULL;
		HAL_GPIO_Init(WRLS_WKUP_B_GPIO_Port, &gpio_cfg);
	}
	if (MX_WIFI_DEBUG)
    	UartPrint("[GPIO] WKUP_B set to input (Hi-Z)");

	/* Keep module awake before probe/init handshakes. */
	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] Enabling WiFi wake pin (WKUP_W=1)...");
	HAL_GPIO_WritePin(WRLS_WKUP_W_GPIO_Port, WRLS_WKUP_W_Pin, GPIO_PIN_SET);
	tx_thread_sleep(20);
	snprintf(status_msg, sizeof(status_msg), "[GPIO] WKUP_W=%d", (int)HAL_GPIO_ReadPin(WRLS_WKUP_W_GPIO_Port, WRLS_WKUP_W_Pin));
	if (MX_WIFI_DEBUG)
    	UartPrint(status_msg);

	{
		GPIO_InitTypeDef gpio_cfg = {0};
		gpio_cfg.Mode = GPIO_MODE_INPUT;
		gpio_cfg.Pull = GPIO_NOPULL;
		gpio_cfg.Speed = GPIO_SPEED_FREQ_LOW;

		gpio_cfg.Pin = WRLS_FLOW_Pin;
		HAL_GPIO_Init(WRLS_FLOW_GPIO_Port, &gpio_cfg);

		gpio_cfg.Pin = WRLS_NOTIFY_Pin;
		HAL_GPIO_Init(WRLS_NOTIFY_GPIO_Port, &gpio_cfg);
	}

	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] Probing WiFi...");
	if (mxwifi_probe(&ll_drv_context) != 0)
	{
		if (MX_WIFI_DEBUG)
			UartPrint("[INIT] Probe FAILED!");
		return;
	}
	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] Probe OK");

	wifi_obj = (MX_WIFIObject_t *)ll_drv_context;
	if (wifi_obj == NULL)
	{
		if (MX_WIFI_DEBUG)
			UartPrint("[INIT] ERROR: wifi_obj is NULL");
		return;
	}

	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] Hard resetting module...");
	status = MX_WIFI_HardResetModule(wifi_obj);
	if (status != MX_WIFI_STATUS_OK)
	{
		if (MX_WIFI_DEBUG)
			UartPrint("[INIT] Hard reset FAILED!");
		return;
	}
	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] Hard reset OK");

	HAL_GPIO_WritePin(WRLS_WKUP_W_GPIO_Port, WRLS_WKUP_W_Pin, GPIO_PIN_SET);
	tx_thread_sleep(50);
	snprintf(status_msg, sizeof(status_msg), "[GPIO] WKUP_W=%d FLOW=%d NOTIFY=%d",
	(int)HAL_GPIO_ReadPin(WRLS_WKUP_W_GPIO_Port, WRLS_WKUP_W_Pin),
	(int)HAL_GPIO_ReadPin(WRLS_FLOW_GPIO_Port, WRLS_FLOW_Pin),
    (int)HAL_GPIO_ReadPin(WRLS_NOTIFY_GPIO_Port, WRLS_NOTIFY_Pin));
	if (MX_WIFI_DEBUG)
    	UartPrint(status_msg);
	tx_thread_sleep(100);

	snprintf(status_msg, sizeof(status_msg), "[GPIO] WKUP_W=%d FLOW=%d NOTIFY=%d (after delay)",
	(int)HAL_GPIO_ReadPin(WRLS_WKUP_W_GPIO_Port, WRLS_WKUP_W_Pin),
	(int)HAL_GPIO_ReadPin(WRLS_FLOW_GPIO_Port, WRLS_FLOW_Pin),
	(int)HAL_GPIO_ReadPin(WRLS_NOTIFY_GPIO_Port, WRLS_NOTIFY_Pin));
	if (MX_WIFI_DEBUG)
    	UartPrint(status_msg);

	for (uint32_t i = 0; i < 200; ++i)
	{
		if (HAL_GPIO_ReadPin(WRLS_FLOW_GPIO_Port, WRLS_FLOW_Pin) == GPIO_PIN_SET)
			flow_seen_high = 1;
		if (HAL_GPIO_ReadPin(WRLS_NOTIFY_GPIO_Port, WRLS_NOTIFY_Pin) == GPIO_PIN_SET)
			notify_seen_high = 1;
		tx_thread_sleep(1);
	}
	snprintf(status_msg, sizeof(status_msg), "[GPIO] FLOW_high=%d NOTIFY_high=%d",
	(int)flow_seen_high, (int)notify_seen_high);
	if (MX_WIFI_DEBUG)
    	UartPrint(status_msg);
	snprintf(status_msg, sizeof(status_msg), "[IRQ] FLOW=%lu NOTIFY=%lu", (unsigned long)g_wifi_flow_irq_count,
	(unsigned long)g_wifi_notify_irq_count);
	if (MX_WIFI_DEBUG)
    	UartPrint(status_msg);

	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] Calling MX_WIFI_Init...");
	status = MX_WIFI_Init(wifi_obj);
	if (status != MX_WIFI_STATUS_OK)
	{
		snprintf(status_msg, sizeof(status_msg), "[INIT] MX_WIFI_Init status=%d", (int)status);
		if (MX_WIFI_DEBUG)
			UartPrint(status_msg);
		snprintf(status_msg, sizeof(status_msg), "[INIT] step=%ld mipc=%ld",
        (long)g_mx_wifi_init_step, (long)g_mx_wifi_init_mipc_ret);
		if (MX_WIFI_DEBUG)
			UartPrint(status_msg);
		if ((g_mx_wifi_init_step == -60) && (flow_seen_high == 0U) && (notify_seen_high == 0U))
		{
			GPIO_InitTypeDef gpio_cfg = {0};

			/* Recovery path for modules that do not toggle handshake lines. */
			if (MX_WIFI_DEBUG)
				UartPrint("[INIT] Fallback: force WKUP_B high and retry");
			gpio_cfg.Pin = WRLS_WKUP_B_Pin;
			gpio_cfg.Mode = GPIO_MODE_OUTPUT_PP;
			gpio_cfg.Pull = GPIO_NOPULL;
			gpio_cfg.Speed = GPIO_SPEED_FREQ_LOW;
			HAL_GPIO_Init(WRLS_WKUP_B_GPIO_Port, &gpio_cfg);
			HAL_GPIO_WritePin(WRLS_WKUP_B_GPIO_Port, WRLS_WKUP_B_Pin, GPIO_PIN_SET);
			tx_thread_sleep(20);

			status = MX_WIFI_HardResetModule(wifi_obj);
			if (status == MX_WIFI_STATUS_OK)
				status = MX_WIFI_Init(wifi_obj);

			if (status == MX_WIFI_STATUS_OK)
			{
				if (MX_WIFI_DEBUG)
						UartPrint("[INIT] Fallback retry succeeded");
			}
			else
			{
				snprintf(status_msg, sizeof(status_msg), "[INIT] Retry step=%ld mipc=%ld",
				(long)g_mx_wifi_init_step, (long)g_mx_wifi_init_mipc_ret);
				if (MX_WIFI_DEBUG)
					UartPrint(status_msg);
			}
		}
		if (status != MX_WIFI_STATUS_OK)
		{
			if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] MX_WIFI_Init FAILED!");
			return;
		}
	}
	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] MX_WIFI_Init OK");

 	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] Connecting to AP...");
	status = MX_WIFI_Connect(wifi_obj, ssid, password, MX_WIFI_SEC_AUTO);
	if (status != MX_WIFI_STATUS_OK)
	{
		snprintf(status_msg, sizeof(status_msg), "[INIT] MX_WIFI_Connect status=%d", (int)status);
		if (MX_WIFI_DEBUG)
			UartPrint(status_msg);
		if (MX_WIFI_DEBUG)
			UartPrint("[INIT] WiFi connect FAILED!");
		return;
	}
	if (MX_WIFI_DEBUG)
    	UartPrint("[INIT] WiFi connected");

	if ((MX_WIFI_GetIPAddress(wifi_obj, ip_check, MC_STATION) != MX_WIFI_STATUS_OK) ||
			((ip_check[0] == 0U) && (ip_check[1] == 0U) && (ip_check[2] == 0U) && (ip_check[3] == 0U)))
	{
		if (MX_WIFI_DEBUG)
			UartPrint("[INIT] DHCP did not provide IP, trying static IP fallback...");
		(void)MX_WIFI_Disconnect(wifi_obj);
		tx_thread_sleep(200);

		status = MX_WIFI_Connect_Adv(wifi_obj, ssid, password, NULL, &static_ip);
		if (status != MX_WIFI_STATUS_OK)
		{
			snprintf(status_msg, sizeof(status_msg), "[INIT] MX_WIFI_Connect_Adv status=%d", (int)status);
			if (MX_WIFI_DEBUG)
				UartPrint(status_msg);
			if (MX_WIFI_DEBUG)
				UartPrint("[INIT] Static IP fallback FAILED");
			return;
		}
		if (MX_WIFI_DEBUG)
			UartPrint("[INIT] Static IP fallback connected");
	 }
	g_wifi_obj = wifi_obj;
}


void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
	if (GPIO_Pin == WRLS_NOTIFY_Pin)
	{
		g_wifi_notify_irq_count++;
		mxchip_WIFI_ISR(GPIO_Pin);
	}
	else if (GPIO_Pin == WRLS_FLOW_Pin)
	{
		g_wifi_flow_irq_count++;
		mxchip_WIFI_ISR(GPIO_Pin);
	}
}

void HAL_GPIO_EXTI_Rising_Callback(uint16_t GPIO_Pin)
{
	HAL_GPIO_EXTI_Callback(GPIO_Pin);
}
