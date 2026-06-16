#include "mqtt.h"

#define htons(x) ( ((x)<<8 & 0xFF00) | ((x)>>8 & 0x00FF) )
static unsigned char	send_buf[512];
static unsigned char	recv_buf[512];
static MQTTClient 		client;
static Network			n;
static int 				mqtt_sock_id = 0;


void mqtt_thread_fc(ULONG thread_input)
{
    WIFIStartup();

    if (MX_WIFI_DEBUG)
        UartPrint("\r\n===== MQTT START =====");
    tx_thread_sleep(500);

    MX_WIFIObject_t* wifi_ptr = WIFI_Get_Object();

    if (wifi_ptr == NULL)
    {
        if (MX_WIFI_DEBUG)
        UartPrint("[FATAL] WIFI NULL");
        Error_Handler();
    }

    /* ---------------- SOCKET ---------------- */
    mqtt_sock_id = MX_WIFI_Socket_create(wifi_ptr, MX_AF_INET, MX_SOCK_STREAM, MX_IPPROTO_TCP);

    if (mqtt_sock_id < 0)
    {
        if (MX_WIFI_DEBUG)
            UartPrint("[ERROR] socket fail");
        Error_Handler();
    }

    /* ---------------- SERVER ---------------- */
    struct mx_sockaddr addr;
    memset(&addr, 0, sizeof(addr));

    addr.sa_family = MX_AF_INET;
    addr.sa_len = sizeof(addr);

    uint16_t port = htons(1883);
    memcpy(&addr.sa_data[0], &port, 2);

    addr.sa_data[2] = MQTT_BROKER_IP_0;
    addr.sa_data[3] = MQTT_BROKER_IP_1;
    addr.sa_data[4] = MQTT_BROKER_IP_2;
    addr.sa_data[5] = MQTT_BROKER_IP_3;

    /* ---------------- TCP CONNECT ---------------- */
    if (MX_WIFI_DEBUG)
        UartPrint("[TCP] connecting...");

    int status = MX_WIFI_Socket_connect(wifi_ptr, mqtt_sock_id, &addr, sizeof(addr));

    if (status != 0)
    {
        if (MX_WIFI_DEBUG)
            UartPrint("[ERROR] TCP fail");
    }

    if (MX_WIFI_DEBUG)
        UartPrint("[TCP] OK");
    tx_thread_sleep(500);

    /* ---------------- MQTT INIT ---------------- */
    n.mqttread = stm32_mqtt_recv;
    n.mqttwrite = stm32_mqtt_send;
    n.my_socket = mqtt_sock_id;

    MQTTClientInit(&client, &n, 15000, send_buf, sizeof(send_buf), recv_buf, sizeof(recv_buf));

    MQTTPacket_connectData data = MQTTPacket_connectData_initializer;

    data.MQTTVersion = 4;
    data.clientID.cstring = "STM32_Client_02";
    data.keepAliveInterval = 60;
    data.cleansession = 1;

    if (MX_WIFI_DEBUG)
        UartPrint("[MQTT] connect...");

    int rc = MQTTConnect(&client, &data);

    if (MX_WIFI_DEBUG)
        UartPrintf("Rc %d\r\n", rc);
        
    if (rc != 0)
    {
        if (MX_WIFI_DEBUG)
                UartPrint("[ERROR] MQTT fail. Halting execution here to prevent invalid publishes.");
    }
    else
        if (MX_WIFI_DEBUG)
            UartPrint("[MQTT] OK");


    while (1)
    {
        static uint32_t last = 0;

        last = tx_time_get();
        if (MX_WIFI_DEBUG)
            UartPrintf("Time = %lu\r\n", last);
        if (MX_WIFI_DEBUG)
            UartPrintf("Conected %d\r\n", MQTTIsConnected(&client));

        MQTTMessage msg;
        char payload[64];

        sprintf(payload, "STM32 %lu", tx_time_get());

        msg.qos = 0;
        msg.retained = 0;
        msg.dup = 0;
        msg.payload = payload;
        msg.payloadlen = strlen(payload);

        int rc = MQTTPublish(&client, "test/topic", &msg);

        if (rc != 0)
        {
            if (MX_WIFI_DEBUG)
                UartPrint("[MQTT] publish fail");
        }
        else
            UartPrintf("Success %s\r\n",payload);

        tx_thread_sleep(200);
    }
}


int stm32_mqtt_send(Network* n, unsigned char* buffer, int len, int timeout_ms)
{
    return MX_WIFI_Socket_send(WIFI_Get_Object(), mqtt_sock_id, buffer, len, timeout_ms);
}

int stm32_mqtt_recv(Network* n, unsigned char* buffer, int len, int timeout_ms)
{
    int bytes_read = 0;
    uint32_t start_time = tx_time_get();

    while (bytes_read < len)
    {
        uint32_t elapsed = ((tx_time_get() - start_time) * 1000) / TX_TIMER_TICKS_PER_SECOND;

        if (elapsed >= (uint32_t)timeout_ms)
        {
            if (MX_WIFI_DEBUG)
                UartPrint("[RECV] Timeout reached without receiving requested data.\r\n");
            break;
        }

        uint32_t remaining_timeout = timeout_ms - elapsed;

        int rc = MX_WIFI_Socket_recv(WIFI_Get_Object(), n->my_socket, buffer + bytes_read, len - bytes_read, remaining_timeout);

        if (rc > 0)
        {
            bytes_read += rc;
            if (MX_WIFI_DEBUG)
                UartPrintf("[RECV] Successfully read %d bytes. Progress: %d/%d\r\n", rc, bytes_read, len);
        }
        else
            tx_thread_sleep(2);
    }

    return bytes_read;
}

