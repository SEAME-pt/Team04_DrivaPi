/**
 * @file pca9685.h
 * @brief PCA9685 header for CMock mocking (matches real firmware signature)
 */

#ifndef __PCA9685_H
#define __PCA9685_H

#include "stm32u5xx_hal.h"

/* Constants */
#define MODE1 0x00
#define MODE2 0x01
#define PRESCALE 0xFE
#define LED0_ON_L 0x06
#define I2C_TIMEOUT 1000
#define PCA9685_COUNTS 4096u

/* Function to mock - matches real firmware signature */
HAL_StatusTypeDef PCA9685_SetPWM(uint16_t addr, uint8_t channel, uint16_t on, uint16_t off);

#endif /* __PCA9685_H */
