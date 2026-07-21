/**
 * @file mqtt_app.c
 * @brief MQTT and TLS application handling for emergency vehicle telemetry.
 * @date 2026-07-13
 *
 */

#include "mqtt.h"
#include "app_threadx.h"
#include <stdio.h>
#include <string.h>

/**
 * @def htons(x)
 * @brief Macro to convert a 16-bit integer from host byte order to network byte order.
 */
#define htons(x) ( ((x)<<8 & 0xFF00) | ((x)>>8 & 0x00FF) )

/** @brief Global buffers and MQTT communication handles */
static unsigned char send_buf[512];
static unsigned char recv_buf[512];
static MQTTClient    client;
static Network       n;
int32_t              mqtt_tls_id = 0;

/* Private Helper Function Prototypes */
static int PublishEmergencyStatus(uint8_t status);

/**
 * @brief Initializes the Wi-Fi module, establishes a TLS connection, and connects to the MQTT broker.
 *
 * @return int 0 on success, negative value on failure.
 */
int MqttInit(void)
{
    MX_WIFIObject_t* wifi_ptr = WIFI_Get_Object();

    if (wifi_ptr == NULL)
    {
        if (MX_WIFI_DEBUG) 
            UartPrint("[FATAL] Wi-Fi Object is NULL\r\n");
        return -1;
    }

    if (MX_WIFI_DEBUG) 
        UartPrint("[TLS] Connecting to secure broker...\r\n");

    struct mx_sockaddr addr;
    memset(&addr, 0, sizeof(addr));
    addr.sa_family = MX_AF_INET;
    addr.sa_len = sizeof(addr);

    uint16_t port = htons(8883);
    memcpy(&addr.sa_data[0], &port, 2);

    addr.sa_data[2] = MQTT_BROKER_IP_0;
    addr.sa_data[3] = MQTT_BROKER_IP_1;
    addr.sa_data[4] = MQTT_BROKER_IP_2;
    addr.sa_data[5] = MQTT_BROKER_IP_3;

    mqtt_tls_id = MX_WIFI_TLS_connect(wifi_ptr, MX_AF_INET, MX_SOCK_STREAM, MX_IPPROTO_TCP, &addr, sizeof(addr), NULL, 0);

    if (mqtt_tls_id < 0)
    {
        if (MX_WIFI_DEBUG)
            UartPrint("[ERROR] TLS connection failed\r\n");
        return -2;
    }

    if (MX_WIFI_DEBUG) 
        UartPrint("[TLS] Connection & Handshake OK\r\n");
    tx_thread_sleep(500);

    /* Bind low-level network operations */
    n.mqttread = MqttRecv;
    n.mqttwrite = MqttSend;
    n.my_socket = mqtt_tls_id;

    MQTTClientInit(&client, &n, 15000, send_buf, sizeof(send_buf), recv_buf, sizeof(recv_buf));

    MQTTPacket_connectData data = MQTTPacket_connectData_initializer;
    data.MQTTVersion = 4;
    data.clientID.cstring = "STM32_Client_02";
    data.keepAliveInterval = 60;
    data.cleansession = 1;
    data.username.cstring = MQTT_USERNAME;
    data.password.cstring = MQTT_PASSWORD;

    if (MX_WIFI_DEBUG)
        UartPrint("[MQTT] Connecting to broker...\r\n");

    int rc = MQTTConnect(&client, &data);
    if (MX_WIFI_DEBUG) 
        UartPrintf("MQTT Connect return code: %d\r\n", rc);
        
    if (rc != 0)
    {
        if (MX_WIFI_DEBUG) 
            UartPrint("[ERROR]MQTT connection failed.\r\n");
        return -3;
    }

    if (MX_WIFI_DEBUG) 
        UartPrint("[MQTT] OK\r\n");
    return 0;
}

/**
 * @brief ThreadX task handling CAN messaging queues, processing alarms, and publishing states over MQTT.
 *
 * @param thread_input Unused ThreadX initialization input parameter.
 */
void MqttThreadFc(ULONG thread_input)
{
    ULONG          actual_flags;
    t_can_message  msg;
    g_emergency_cmd = 0;

    while (WIFIStartup() != 0)
        tx_thread_sleep(500);

    if (MX_WIFI_DEBUG)
        UartPrint("\r\n===== MQTT APPLICATION START =====\r\n");
    tx_thread_sleep(500);

    while (MqttInit() != 0)
        tx_thread_sleep(500);

    while (1)
    {
        if (tx_event_flags_get(&g_eventFlags, FLAG_CAN_EMERGENCY_CMD, TX_OR_CLEAR, &actual_flags, TX_NO_WAIT) == TX_SUCCESS)
        {
            while (tx_queue_receive(&g_queueEmergencyCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
            {
                if (MX_WIFI_DEBUG)
                    UartPrintf("[DEBUG CAN] Raw Queue Value: %d\r\n", msg.data[0]);
                memcpy(&g_emergency_cmd, msg.data, sizeof(uint8_t));
            }
        }

        if (!MQTTIsConnected(&client))
        {
            if (MX_WIFI_DEBUG)
                UartPrint("[MQTT] Disconnected! Attempting to reconnect...\r\n");
            tx_thread_sleep(500);
            continue;
        }

        if (MX_WIFI_DEBUG)
            UartPrintf("emergency%d\r\n", g_emergency_cmd);

        if (g_emergency_cmd == 1)
        {
            PublishEmergencyStatus(1);

            __HAL_TIM_SET_AUTORELOAD(&htim3, 1040);
            __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_3, 520);
            HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_3);
            tx_thread_sleep(40);

            __HAL_TIM_SET_AUTORELOAD(&htim3, 1538);
            __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_3, 769);
            HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_3);
            tx_thread_sleep(40);
        }
        else
        {
            HAL_TIM_PWM_Stop(&htim3, TIM_CHANNEL_3);
            PublishEmergencyStatus(0);
            tx_thread_sleep(50);
        }
    }
}

/**
 * @brief Sends packet data over the established secure TLS tunnel.
 *
 * @param n Pointer to the network configuration structure.
 * @param buffer Array containing data bytes to transfer.
 * @param len Size of data chunk to send.
 * @param timeout_ms Connection timeout duration.
 * @return int Total bytes transmitted, or negative error code.
 */
int MqttSend(Network* net, unsigned char* buffer, int len, int timeout_ms)
{
    return MX_WIFI_TLS_send(WIFI_Get_Object(), (mtls_t)(intptr_t)net->my_socket, buffer, len);
}

/**
 * @brief Non-blocking read operations with explicit timeout tracking over TLS.
 *
 * @param n Pointer to the network configuration structure.
 * @param buffer Data payload arrival storage layout.
 * @param len Desired payload constraint size targets.
 * @param timeout_ms Maximum time to wait for data arrival.
 * @return int Total bytes successfully read into the buffer.
 */
int MqttRecv(Network* net, unsigned char* buffer, int len, int timeout_ms)
{
    int			bytes_read = 0;
    uint32_t	start_time = tx_time_get();

    while (bytes_read < len)
    {
        uint32_t elapsed = ((tx_time_get() - start_time) * 1000) / TX_TIMER_TICKS_PER_SECOND;

        if (elapsed >= (uint32_t)timeout_ms)
        {
            if (MX_WIFI_DEBUG)
                UartPrint("[RECV] Timeout reached.\r\n");
            break;
        }

        int rc = MX_WIFI_TLS_recv(WIFI_Get_Object(), (mtls_t)(intptr_t)net->my_socket, buffer + bytes_read, len - bytes_read);

        if (rc > 0)
        {
            bytes_read += rc;
            if (MX_WIFI_DEBUG)
                UartPrintf("[RECV] Read %d bytes. (%d/%d)\r\n", rc, bytes_read, len);
        }
        else if (rc < 0)
        {
            break;
        }
        else
        {
            tx_thread_sleep(2);
        }
    }

    return bytes_read;
}

/**
 * @brief Helper function to format and execute MQTT emergency telemetry updates.
 *
 * @param status Binary integer representing active (1) or inactive (0) states.
 * @return int Return code of the MQTT Publish function.
 */
static int PublishEmergencyStatus(uint8_t status)
{
    MQTTMessage msg;
    char 		payload[64];

    snprintf(payload, sizeof(payload), status == 1 ? "EMERGENCY_ACTIVE" : "EMERGENCY_N_ACTIVE");

    msg.qos = 1;
    msg.retained = 0;
    msg.dup = 0;
    msg.payload = payload;
    msg.payloadlen = strlen(payload);

    if (MX_WIFI_DEBUG)
        UartPrint("[MQTT] Publishing emergency alarm...\r\n");

    int rc = MQTTPublish(&client, "vehicles/emergency", &msg);

    if (MX_WIFI_DEBUG)
    {
        if (rc != 0)
            UartPrintf("[MQTT] Emergency publish fail (rc=%d)\r\n", rc);
        else
            UartPrintf("Success Send: %s\r\n", payload);
    }

    return rc;
}
