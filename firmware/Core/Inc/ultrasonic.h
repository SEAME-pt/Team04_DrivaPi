#ifndef __ULTRASONIC_H
#define __ULTRASONIC_H

#include "app_threadx.h"

// SRF08 Commands
#define SRF08_ADDR          0xE0
#define CMD_REG             0x00
#define RANGE_REG           0x02
#define CMD_CENTIMETERS     0x51

// Safety Thresholds
#define BRAKE_THRESHOLD_CM  17   // Hard Stop
#define TTC_THRESHOLD_MS    450 // Predictive Stop
#define DT_SECONDS          0.057f
#define BACKSPIN_THRESHOLD	70

#define ULTRASONIC_INVALID_SAMPLE  0x7FFFFFFFu

HAL_StatusTypeDef UltrasonicModuleInit(void);
HAL_StatusTypeDef UltrasonicReadRangeCm(int16_t *range_cm);


#endif /* __ULTRASONIC_H */
