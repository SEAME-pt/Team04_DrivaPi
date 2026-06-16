/*
 * MQTT_STM32.c
 *
 *  Created on: Jun 6, 2026
 *      Author: hugofslopes
 */


#include "MQTT_STM32.h"

void TimerInit(Timer* timer) {
    timer->end_time = 0;
}

char TimerIsExpired(Timer* timer) {
    return (tx_time_get() >= timer->end_time);
}

void TimerCountdownMS(Timer* timer, unsigned int timeout_ms) {
    timer->end_time = tx_time_get() + timeout_ms;
}

void TimerCountdown(Timer* timer, unsigned int timeout) {
    TimerCountdownMS(timer, timeout * 1000);
}

int TimerLeftMS(Timer* timer) {
    uint32_t now = tx_time_get();
    if (timer->end_time <= now) return 0;
    return (int)(timer->end_time - now);
}
