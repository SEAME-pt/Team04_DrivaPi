#ifndef __MQTT_H
#define __MQTT_H

#ifdef __cplusplus
extern "C" {
#endif

#include "wifi_startup.h"
#include "MQTTClient.h"
#include "mx_address.h"

int stm32_mqtt_send(Network* n, unsigned char* buffer, int len, int timeout_ms);
int stm32_mqtt_recv(Network* n, unsigned char* buffer, int len, int timeout_ms);
void mqtt_thread_fc(ULONG thread_input);
void stm32_emergency_callback(MessageData* data);

#ifndef MX_WIFI_DEBUG
#define MX_WIFI_DEBUG	(0)
#endif

#ifndef EMERGENCY_VEHICLE
#define EMERGENCY_VEHICLE	 (1)
#endif

#ifdef __cplusplus
}
#endif

#endif /* __MQTT_H */
