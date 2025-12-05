/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : pca9685.h
  * @brief          : PCA9685 PWM driver header
  ******************************************************************************
  */
/* USER CODE END Header */

#ifndef __PCA9685_H
#define __PCA9685_H

#ifdef __cplusplus
extern "C" {
#endif

#include "main.h"
#include <stdint.h>

#define MODE1 0x00
#define MODE2 0x01
#define PRESCALE 0xFE
#define LED0_ON_L 0x06

#define I2C_TIMEOUT 1000

#define PCA9685_COUNTS 4096u

HAL_StatusTypeDef PCA9685_Init_Device(I2C_HandleTypeDef *hi2c, uint8_t addr7, const char* name);
HAL_StatusTypeDef PCA9685_SetPWM(I2C_HandleTypeDef *hi2c, uint16_t addr, uint8_t channel, uint16_t on, uint16_t off);
HAL_StatusTypeDef PCA9685_SetFrequency(I2C_HandleTypeDef *hi2c, uint8_t addr7, double freq);
HAL_StatusTypeDef PCA9685_Sleep(I2C_HandleTypeDef *hi2c, uint16_t addr);
void              PCA9685_Init_All_Devices(void);
void              UART_Print(const char* msg);


extern I2C_HandleTypeDef hi2c3;
extern uint8_t i2c_debug;

#ifdef __cplusplus
}
#endif

#endif
