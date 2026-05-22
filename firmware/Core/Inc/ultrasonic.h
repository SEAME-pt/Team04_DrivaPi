#ifndef __ULTRASONIC_H
#define __ULTRASONIC_H

#include "app_threadx.h"

#define SRF08_I2C_ADDR        0xE0
#define SRF08_CMD_REG         0x00
#define SRF08_ECHO_HIGH_REG   0x02
#define SRF08_RANGING_CM      0x51

extern I2C_HandleTypeDef hi2c3;

// Safety Thresholds
#define BRAKE_THRESHOLD_CM  17   // Hard Stop
#define TTC_THRESHOLD_MS    450 // Predictive Stop
#define DT_SECONDS          0.057f
#define BACKSPIN_THRESHOLD	70


#endif /* __ULTRASONIC_H */
