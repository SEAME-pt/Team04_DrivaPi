#include "mqtt.h"

#define htons(x) ( ((x)<<8 & 0xFF00) | ((x)>>8 & 0x00FF) )
static unsigned char	send_buf[512];
static unsigned char	recv_buf[512];
static MQTTClient 		client;
static Network			n;
uint8_t sub_done = 0;
//static int 				mqtt_sock_id = 0;

int32_t mqtt_tls_id = 0;


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
    // mqtt_sock_id = MX_WIFI_Socket_create(wifi_ptr, MX_AF_INET, MX_SOCK_STREAM, MX_IPPROTO_TCP);

    // if (mqtt_sock_id < 0)
    // {
    //     if (MX_WIFI_DEBUG)
    //         UartPrint("[ERROR] socket fail");
    //     Error_Handler();
    // }

    // /* ---------------- SERVER ---------------- */
    // struct mx_sockaddr addr;
    // memset(&addr, 0, sizeof(addr));

    // addr.sa_family = MX_AF_INET;
    // addr.sa_len = sizeof(addr);

    // uint16_t port = htons(1883);
    // memcpy(&addr.sa_data[0], &port, 2);

    // addr.sa_data[2] = MQTT_BROKER_IP_0;
    // addr.sa_data[3] = MQTT_BROKER_IP_1;
    // addr.sa_data[4] = MQTT_BROKER_IP_2;
    // addr.sa_data[5] = MQTT_BROKER_IP_3;

/* ---------------- SOCKET (Com TLS) ---------------- */
    if (MX_WIFI_DEBUG)
            UartPrint("[TLS] Connecting to secure broker...");

        struct mx_sockaddr addr;
        memset(&addr, 0, sizeof(addr));
        addr.sa_family = MX_AF_INET;
        addr.sa_len = sizeof(addr);

        // Porto Seguro 8883
        uint16_t port = htons(8883);
        memcpy(&addr.sa_data[0], &port, 2);

        addr.sa_data[2] = MQTT_BROKER_IP_0;
        addr.sa_data[3] = MQTT_BROKER_IP_1;
        addr.sa_data[4] = MQTT_BROKER_IP_2;
        addr.sa_data[5] = MQTT_BROKER_IP_3;

        // A função MX_WIFI_TLS_connect faz o socket TCP e o Handshake TLS tudo de uma vez!
        // Passamos NULL e 0 no fim para contornar a validação estrita da CA (Modo Insecure)
        mqtt_tls_id = MX_WIFI_TLS_connect(wifi_ptr, MX_AF_INET, MX_SOCK_STREAM, MX_IPPROTO_TCP,
                                          &addr, sizeof(addr), NULL, 0);

        if (mqtt_tls_id < 0)
        {
            if (MX_WIFI_DEBUG)
                UartPrint("[ERROR] TLS connection failed");
            Error_Handler();
        }

        if (MX_WIFI_DEBUG)
            UartPrint("[TLS] Connection & Handshake OK");
        tx_thread_sleep(500);

    /* ---------------- MQTT INIT ---------------- */
    n.mqttread = stm32_mqtt_recv;
    n.mqttwrite = stm32_mqtt_send;
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
    	// 1. Validar se continuamos ligados ao Broker
    	        if (!MQTTIsConnected(&client))
    	        {
    	            if (MX_WIFI_DEBUG)
    	                UartPrint("[MQTT] Disconnected! Trying to reconnect...\r\n");

    	            // Aqui idealmente chamarias o teu código de reconnect,
    	            // e fazes reset à flag de subscrição se caíres
    	            sub_done = 0;
    	            tx_thread_sleep(500);
    	            continue;
    	        }

    	        /* ---------------- MODO A: VEÍCULO DE EMERGÊNCIA ---------------- */
    	        if (EMERGENCY_VEHICLE)
    	        {
    	            // Se mudámos de modo, limpamos o estado de subscritor do modo B
    	            sub_done = 0;

    	            MQTTMessage msg;
    	            char payload[64];

    	            // Criar o payload de alerta
    	            sprintf(payload, "EMERGENCY ALERT from STM32 at %lu", tx_time_get());

    	            msg.qos = 1; // Recomendado QoS 1 para mensagens críticas de emergência
    	            msg.retained = 0;
    	            msg.dup = 0;
    	            msg.payload = payload;
    	            msg.payloadlen = strlen(payload);

    	            // Publica num canal específico de emergências
    	            if (MX_WIFI_DEBUG)
    	                UartPrint("[MQTT] Publishing emergency alarm...\r\n");

    	            int rc = MQTTPublish(&client, "vehicles/emergency", &msg);

    	            if (rc != 0)
    	            {
    	                if (MX_WIFI_DEBUG)
    	                    UartPrintf("[MQTT] Emergency publish fail (rc=%d)\r\n", rc);
    	            }
    	            else
    	            {
    	                UartPrintf("Success Send: %s\r\n", payload);
    	            }

    	            // Publica o aviso a cada 2 segundos (ajusta conforme necessário)
    	            tx_thread_sleep(200);
    	        }

    	        /* ---------------- MODO B: VEÍCULO NORMAL (SUBSCRIÇÃO) ---------------- */
    	        else
    	        {
    	            // Passo 1: Subscrever o canal de emergência (Apenas uma vez quando entra neste modo)
    	            if (!sub_done)
    	            {
    	                if (MX_WIFI_DEBUG)
    	                    UartPrint("[MQTT] Subscribing to vehicles/emergency...\r\n");

    	                // stm32_emergency_callback é a função que vai processar as mensagens recebidas
    	                int rc = MQTTSubscribe(&client, "vehicles/emergency", QOS1, stm32_emergency_callback);

    	                if (rc == 0)
    	                {
    	                    sub_done = 1;
    	                    if (MX_WIFI_DEBUG)
    	                        UartPrint("[MQTT] Subscription Successful!\r\n");
    	                }
    	                else
    	                {
    	                    if (MX_WIFI_DEBUG)
    	                        UartPrintf("[ERROR] Subscribe fail (rc=%d)\r\n", rc);
    	                    tx_thread_sleep(100); // Espera um pouco antes de tentar novamente no próximo loop
    	                    continue;
    	                }
    	            }

    	            // Passo 2: O segredo do Keep-Alive!
    	            // O MQTTYield guarda 200ms para verificar se chegaram dados do Wi-Fi.
    	            // Se não chegar nada, ele envia automaticamente o Ping do Keep-Alive quando necessário.
    	            int rc = MQTTYield(&client, 200);
    	            if (rc != 0)
    	            {
    	                if (MX_WIFI_DEBUG)
    	                    UartPrint("[MQTT] Yield error (connection lost?)\r\n");
    	            }

    	            // Pequena folga para a thread do Azure RTOS (ThreadX) respirar
    	            tx_thread_sleep(10);
    	        }
    }
}


//int stm32_mqtt_send(Network* n, unsigned char* buffer, int len, int timeout_ms)
//{
//    return MX_WIFI_Socket_send(WIFI_Get_Object(), mqtt_sock_id, buffer, len, timeout_ms);
//}
//
//int stm32_mqtt_recv(Network* n, unsigned char* buffer, int len, int timeout_ms)
//{
//    int bytes_read = 0;
//    uint32_t start_time = tx_time_get();
//
//    while (bytes_read < len)
//    {
//        uint32_t elapsed = ((tx_time_get() - start_time) * 1000) / TX_TIMER_TICKS_PER_SECOND;
//
//        if (elapsed >= (uint32_t)timeout_ms)
//        {
//            if (MX_WIFI_DEBUG)
//                UartPrint("[RECV] Timeout reached without receiving requested data.\r\n");
//            break;
//        }
//
//        uint32_t remaining_timeout = timeout_ms - elapsed;
//
//        int rc = MX_WIFI_Socket_recv(WIFI_Get_Object(), n->my_socket, buffer + bytes_read, len - bytes_read, remaining_timeout);
//
//        if (rc > 0)
//        {
//            bytes_read += rc;
//            if (MX_WIFI_DEBUG)
//                UartPrintf("[RECV] Successfully read %d bytes. Progress: %d/%d\r\n", rc, bytes_read, len);
//        }
//        else
//            tx_thread_sleep(2);
//    }
//
//    return bytes_read;
//}
int stm32_mqtt_send(Network* n, unsigned char* buffer, int len, int timeout_ms)
{
    // Adicionado o cast (mtls_t) para converter o int em ponteiro
    return MX_WIFI_TLS_send(WIFI_Get_Object(), (mtls_t)(intptr_t)n->my_socket, buffer, len);
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

        // Adicionado o cast (mtls_t) aqui também
        int rc = MX_WIFI_TLS_recv(WIFI_Get_Object(), (mtls_t)(intptr_t)n->my_socket, buffer + bytes_read, len - bytes_read);

        if (rc > 0)
        {
            bytes_read += rc;
            if (MX_WIFI_DEBUG)
                UartPrintf("[RECV] Successfully read %d bytes. Progress: %d/%d\r\n", rc, bytes_read, len);
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

// Função que é executada automaticamente pelo MQTTYield sempre que chega uma mensagem
void stm32_emergency_callback(MessageData* data)
{
    MQTTMessage* msg = data->message;

    // Aloca um buffer temporário para garantir que a string tem o terminador '\0'
    char received_payload[64];
    int len = (msg->payloadlen < 63) ? msg->payloadlen : 63;
    memcpy(received_payload, msg->payload, len);
    received_payload[len] = '\0';

    // Imprime o aviso no terminal da STM32!
    UartPrintf("\r\n⚠️ [ALERT RECEIVED] Topic: %.*s | Msg: %s\r\n",
               data->topicName->lenstring.len,
               data->topicName->lenstring.data,
               received_payload);

    // Aqui podes ligar um LED na placa, tocar um buzzer, etc.
}
