/**
  ******************************************************************************
  * @file           : pca9685.h
  * @brief          : PCA9685 PWM driver header
  ******************************************************************************
  */

#ifndef __PCA9685_H
#define __PCA9685_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdarg.h>
#include "main.h"

#define MODE1 0x00
#define MODE2 0x01
#define PRESCALE 0xFE
#define LED0_ON_L 0x06

#define I2C_TIMEOUT 1000

#define PCA9685_COUNTS 4096u

#define SERVO_FREQ 0x79

#define MOTOR_L_PWM 7
#define MOTOR_L_A 5
#define MOTOR_L_B 6
#define MOTOR_R_PWM 0
#define MOTOR_R_A 1
#define MOTOR_R_B 2
#define PCA9685_ADDR_MOTOR 0x60

HAL_StatusTypeDef PCA9685_InitDevice(I2C_HandleTypeDef *hi2c, uint8_t addr7, const char* name);
HAL_StatusTypeDef PCA9685_SetPWM(uint16_t addr, uint8_t channel, uint16_t on, uint16_t off);
HAL_StatusTypeDef PCA9685_SetFrequency(uint8_t addr7, double freq);
HAL_StatusTypeDef PCA9685_Sleep( uint16_t addr);
void              PCA9685_InitAllDevices(void);


extern I2C_HandleTypeDef hi2c2;
extern I2C_HandleTypeDef hi2c3;
extern uint8_t g_i2cDebug;

#ifdef __cplusplus
}
#endif
#endif


