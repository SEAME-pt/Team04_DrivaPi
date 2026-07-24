/*
 * MQTT_STM32.h
 *
 *  Created on: Jun 6, 2026
 *      Author: hugofslopes
 */

#ifndef MQTT_STM32_H
#define MQTT_STM32_H

#include "main.h"
#include "tx_api.h"

// 1. Definição da estrutura Timer
typedef struct {
    uint32_t systick_period;
    uint32_t end_time;
} Timer;

// 2. Definição da estrutura Network
typedef struct Network {
    int my_socket;
    int (*mqttread) (struct Network*, unsigned char*, int, int);
    int (*mqttwrite)(struct Network*, unsigned char*, int, int);
} Network;

// Protótipos das funções que tens de implementar
void TimerInit(Timer*);
char TimerIsExpired(Timer*);
void TimerCountdownMS(Timer*, unsigned int);
void TimerCountdown(Timer*, unsigned int);
int TimerLeftMS(Timer*);

#endif

