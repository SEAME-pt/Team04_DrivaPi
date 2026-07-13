/*
 * wifi_debug.h
 *
 *  Created on: Apr 2, 2026
 *      Author: TeamDrivaPi
 */

#ifndef WIFI_STARTUP_H_
#define WIFI_STARTUP_H_

#include "main.h"
#include "tx_api.h"
#include "mx_wifi_io.h"
#include "wifi_credentials.h"
#include "app_threadx.h"

int 				WIFIStartup(void);
MX_WIFIObject_t*	WIFI_Get_Object(void);

extern UART_HandleTypeDef	huart1;
extern volatile int32_t		g_mx_wifi_init_step;
extern volatile int32_t		g_mx_wifi_init_mipc_ret;

#endif /* WIFI_DEBUG_H_ */
