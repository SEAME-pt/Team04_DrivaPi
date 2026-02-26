/**
  ******************************************************************************
  * @file    firmware/Core/Src/dc_motor.c
  * @author  DrivaPi Team
  * @brief   This file contains the DC motor control functions.
  ******************************************************************************
  * @attention
  *
*/
#include "dc_motor.h"
#include "speed_sensor.h"

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

/**
* @brief
*
* @param value
*/
void SetMotor(double value)
{
	const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);
	uint16_t pwm_val = ClampU16((int32_t)(fabs(value) * (double)max + 0.5));

	if (fabs(value) < 1e-6)
	{
		MotorStop();
		return;
	}

	if (value > 0.0)
	{
		// Forward
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
	}
	else 
	{
		// Backward
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);
	}
}

/**
* @brief
*
* @param left_counts
* @param right_counts
*/
void MotorSetPWM(int32_t left_counts, int32_t right_counts)
{
	const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);

	/* Left motor */
	if (left_counts > 0)
	{
		uint16_t pwm = ClampU16(left_counts);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm);
		g_current_pwm = (int16_t)pwm;
	}
	else if (left_counts < 0)
	{
		uint16_t pwm = ClampU16(-left_counts);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm);
		g_current_pwm = -(int16_t)pwm;
	}
	else
	{
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, max);
		g_current_pwm = 0;
	}

	/* Right motor */
	if (right_counts > 0)
	{
		uint16_t pwm = ClampU16(right_counts);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm);
	}
	else if (right_counts < 0)
	{
		uint16_t pwm = ClampU16(-right_counts);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm);
	}
	else
	{
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, max);
	}
}

/**
* @brief
*
* @param initial_input
* @return VOID
*/
VOID DcMotor(ULONG initial_input)
{
	t_can_message 	msg;
	ULONG			actual_flags;

	while (1)
	{
		tx_event_flags_get(&g_eventFlags, FLAG_CAN_SPEED_CMD,
		TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);

		while (tx_queue_receive(&g_queueSpeedCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
		{

			if (msg.len >= 8)
			{
				int32_t left_count = 0;
				int32_t right_count = 0;
				memcpy(&left_count, msg.data, sizeof(int32_t));
				memcpy(&right_count, msg.data + sizeof(int32_t), sizeof(int32_t));
				MotorSetPWM(left_count, right_count);
			} 
			else if (msg.len >= 4)
			{
				int32_t counts = 0;
				memcpy(&counts, msg.data, sizeof(int32_t));
				MotorSetPWM(counts, counts);
			}
		}
		tx_thread_sleep(10);
	}
}
