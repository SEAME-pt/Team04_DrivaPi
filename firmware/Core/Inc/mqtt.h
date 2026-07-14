#ifndef __MQTT_H
#define __MQTT_H

#ifdef __cplusplus
extern "C" {
#endif

#include <MX_WIFI/wifi_startup.h>
#include "MQTTClient.h"
#include "../../Middlewares/MX_WIFI/core/mx_address.h"

int		MqttSend(Network* n, unsigned char* buffer, int len, int timeout_ms);
int 	MqttRecv(Network* n, unsigned char* buffer, int len, int timeout_ms);
void	MqttThreadFc(ULONG thread_input);
void	stm32_emergency_callback(MessageData* data);

extern uint8_t 				g_emergency_cmd;
extern TIM_HandleTypeDef	htim3;
#ifndef MX_WIFI_DEBUG
#define MX_WIFI_DEBUG	(0)
#endif


#ifdef __cplusplus
}
#endif

#endif /* __MQTT_H */
