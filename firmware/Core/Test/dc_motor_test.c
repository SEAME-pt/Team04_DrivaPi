/**
  ******************************************************************************
  * @file    dc_motor_test.c
  * @author  Team04 DrivaPi
  * @brief   This file contains the implementation of DC motor test functions.
  ******************************************************************************
  * @attention
  *
*/
#include "dc_motor_test.h"

/**
 * @brief
 *
 * @param speed
 */
void MotorTestHigh(double speed) {

    UartPrint("-> FORWARD (1.5s)...\r\n");
    MotorForward(speed);
    tx_thread_sleep(150);
    tx_thread_sleep(30);

    UartPrint("-> BACKWARD (1.5s)...\r\n");
    MotorBackward(speed);
    tx_thread_sleep(150);
    MotorStop();
    tx_thread_sleep(30);

    UartPrint("-> LEFT (1.2s)...\r\n");
    MotorLeft(speed);
    tx_thread_sleep(120);
    MotorStop();
    tx_thread_sleep(30);

    UartPrint("-> RIGHT (1.2s)...\r\n");
    MotorRight(speed);
    tx_thread_sleep(120);
    MotorStop();

    UartPrint("Motor_Test_High: complete\r\n");
}


/**
* @brief
*
*/
void MotorStop(void)
{
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, 0);

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, 0);
}

/**
* @brief
*
* @param speed
*/
void MotorForward(double speed)
{
	uint16_t max = 4095;
	uint16_t pwm_value = (uint16_t)(speed * max);

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_value);

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_value);
}

/**
* @brief
*
* @param speed
*/
void MotorBackward(double speed)
{
	uint16_t max = 4095;
	uint16_t pwm_val = (uint16_t)(speed * max);

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
}

/**
* @brief
*
* @param speed
*/
void MotorLeft(double speed)
{
	const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);
	uint16_t pwm_val = ClampU16((int32_t)(speed * (double)max + 0.5));

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
}

/**
* @brief
*
* @param speed
*/
void MotorRight(double speed)
{
	const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);
	uint16_t pwm_val = ClampU16((int32_t)(speed * (double)max + 0.5));

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
	PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
}
