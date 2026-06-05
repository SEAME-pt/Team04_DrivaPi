/* 
 * Copyright (c) Microsoft
 * Copyright (c) 2024 Eclipse Foundation
 * 
 *  This program and the accompanying materials are made available 
 *  under the terms of the MIT license which is available at
 *  https://opensource.org/license/mit.
 * 
 *  SPDX-License-Identifier: MIT
 * 
 *  Contributors: 
 *     Microsoft         - Initial version
 *     Frédéric Desbiens - 2024 version.
 */

#include <stdio.h>

#include "tx_api.h"

#include "board_init.h"
#include "cmsis_utils.h"
#include "screen.h"
#include "sntp_client.h"
#include "wwd_networking.h"
#include "nxd_mqtt_client.h"


#include "cloud_config.h"

#define ECLIPSETX_THREAD_STACK_SIZE 4096
#define ECLIPSETX_THREAD_PRIORITY   4

TX_THREAD eclipsetx_thread;
TX_THREAD eclipsetx_thread2;
ULONG eclipsetx_thread_stack[ECLIPSETX_THREAD_STACK_SIZE / sizeof(ULONG)];
ULONG eclipsetx_thread_stack2[ECLIPSETX_THREAD_STACK_SIZE / sizeof(ULONG)];

NXD_MQTT_CLIENT mqtt_client;
UCHAR mqtt_buffer[512];
#define MQTT_THREAD_STACK_SIZE 2048
UCHAR mqtt_thread_stack[MQTT_THREAD_STACK_SIZE];


static void eclipsetx_thread_entry(ULONG parameter)
{
    UINT status = 0;
    NXD_ADDRESS broker_address;

    printf("DEBUG: Attempting to connect to SSID: '%s'\r\n", WIFI_SSID);
    if ((status = wwd_network_init(WIFI_SSID, WIFI_PASSWORD, WIFI_MODE)))
        printf("ERROR: Network init (0x%08x)\r\n", status);
    // ... (Network init code) ...
    wwd_network_connect();
    if (status != NX_SUCCESS)
        printf("ERROR: Network init failed (0x%02x)\r\n", status);

    status = nxd_mqtt_client_create(&mqtt_client, "MQTT Client", "unique_client_id", strlen("unique_client_id"),
    &nx_ip, &nx_pool[1], mqtt_thread_stack, MQTT_THREAD_STACK_SIZE, 4, mqtt_buffer, sizeof(mqtt_buffer));
    if (status != NX_SUCCESS)
        printf("ERROR: MQTT Create failed (0x%02x)\r\n", status);

    // Connection call (6 arguments)
    broker_address.nxd_ip_version = NX_IP_VERSION_V4;
    broker_address.nxd_ip_address.v4 = IP_ADDRESS(10, 21, 220, 164);

    status = nxd_mqtt_client_connect(&mqtt_client, &broker_address, 1883, 60, 1, NX_WAIT_FOREVER);
    if (status != NX_SUCCESS)
        printf("ERROR: MQTT Connect failed (0x%02x)\r\n", status);

    // Publish call (8 arguments)
    while (1)
    {
        status = nxd_mqtt_client_publish(&mqtt_client, "test/topic", strlen("test/topic"), "Hello, MQTT!", 
        strlen("Hello, MQTT!"), 0, 0, NX_WAIT_FOREVER);
        if (status != NX_SUCCESS)
            printf("ERROR: MQTT Publish failed (0x%02x)\r\n", status);
        screen_print("publish", 1);
        tx_thread_sleep(100);
    }
}

void tx_application_define(void* first_unused_memory)
{
    systick_interval_set(TX_TIMER_TICKS_PER_SECOND);

    // Create ThreadX thread
    UINT status = tx_thread_create(&eclipsetx_thread, "Eclipse ThreadX Thread", eclipsetx_thread_entry,
    0, eclipsetx_thread_stack, ECLIPSETX_THREAD_STACK_SIZE, ECLIPSETX_THREAD_PRIORITY,
    ECLIPSETX_THREAD_PRIORITY, TX_NO_TIME_SLICE, TX_AUTO_START);

    if (status != TX_SUCCESS)
        printf("ERROR: Eclipse ThreadX thread creation failed\r\n");
}

int main(void)
{
    // Initialize the board
    board_init();

    // Enter the ThreadX kernel
    tx_kernel_enter();

    return 0;
}
