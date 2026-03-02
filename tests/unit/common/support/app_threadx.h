#ifndef __APP_THREADX_H
#define __APP_THREADX_H

#ifdef __cplusplus
extern "C" {
#endif

#include "tx_api.h"
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <math.h>
#include "stm32u5xx_hal.h"

#ifndef can_message_s
typedef struct can_message_s {
    uint32_t id;	
    uint8_t  data[8];
    uint8_t  len;
} t_can_message;
#endif

/* Event flags */
#define FLAG_CAN_SPEED_CMD    (1 << 0)
#define FLAG_CAN_STEER_CMD    (1 << 1)
#define FLAG_SENSOR_UPDATE    (1 << 2)
#define THREAD_STACK_SIZE     1024
#define QUEUE_SIZE            10

/* Function declarations */
int CanSend(t_can_message* msg);

#ifdef __cplusplus
}
#endif

#endif /* __APP_THREADX_H */
