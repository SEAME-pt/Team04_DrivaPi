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

/**
 * @brief Set PWM values for left and right DC motors based on pulse counts
 * 
 * @param left_counts PWM pulse count for left motor (positive=forward, negative=reverse, 0=stop)
 * @param right_counts PWM pulse count for right motor (positive=forward, negative=reverse, 0=stop)
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
* @brief DC motor thread entry that consumes speed commands from CAN.
*
* @param initial_input ThreadX initial input (unused).
* @return VOID
*/
VOID DcMotor(ULONG initial_input)
{
	t_can_message 	msg;
	ULONG			actual_flags;

	while (1)
	{
		tx_event_flags_get(&g_eventFlags, FLAG_CAN_SPEED_CMD,
		TX_OR_CLEAR, &actual_flags, TX_WAIT_FOREVER);

		while (tx_queue_receive(&g_queueSpeedCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
		{
			int32_t left_count = 0;
			int32_t right_count = 0;

			memcpy(&left_count, msg.data, sizeof(int32_t));

			tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
			if(g_emergencyBrake && left_count > 0 )
			{
				tx_mutex_put(&g_emergencyMutex);
				tx_thread_sleep(5);
				continue ;
			}
			else
			{
				tx_mutex_put(&g_emergencyMutex);

				if (msg.len >= 8)
				{
					right_count = 0;
					memcpy(&left_count, msg.data, sizeof(int32_t));
					memcpy(&right_count, msg.data + sizeof(int32_t), sizeof(int32_t));

					tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
					MotorSetPWM(left_count, right_count);
					tx_mutex_put(&g_motorMutex);
				}
				else if (msg.len >= 4)
				{
					int32_t counts = 0;
					memcpy(&counts, msg.data, sizeof(int32_t));

					tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
					MotorSetPWM(counts, counts);
					tx_mutex_put(&g_motorMutex);
				}
			}
		}
		tx_thread_sleep(10);
	}
}
