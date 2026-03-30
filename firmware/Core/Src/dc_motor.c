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

	if (g_motorControlState.direction == 2)
	{
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, max);

		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, max);	
	}

	/* Left motor */
	if (left_counts > 0)
	{
		uint16_t pwm = ClampU16(left_counts);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm);
		g_currentPWM = (int16_t)pwm;
	}
	else if (left_counts < 0)
	{
		uint16_t pwm = ClampU16(-left_counts);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm);
		g_currentPWM = -(int16_t)pwm;
	}
	else
	{
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, 0);
		g_currentPWM = 0;
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
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, 0);
		g_currentPWM = 0;
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
	static uint8_t debug_counter = 0;

	while (1)
	{
		// Check for new CAN messages (non-blocking)
		if (tx_event_flags_get(&g_eventFlags, FLAG_CAN_SPEED_CMD,
		    TX_OR_CLEAR, &actual_flags, TX_NO_WAIT) == TX_SUCCESS)
		{
			// Process all pending CAN messages
			while (tx_queue_receive(&g_queueSpeedCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
			{
				// Parse as two int32_t values (speed magnitude and direction)
				int32_t speed_magnitude = 0;
				g_motorControlState.direction = 0;  // 1 = forward, 0 = backward, 2 = brake
				
				memcpy(&speed_magnitude, msg.data, sizeof(int32_t));
				memcpy(&g_motorControlState.direction, msg.data + sizeof(int32_t), sizeof(int32_t));
				
				// Convert to signed speed: positive for forward, negative for backward
				if (g_motorControlState.direction == 1)
				{
					g_motorControlState.target_speed = (float)speed_magnitude;
				}
				else  // direction == 0 (backward)
				{
					g_motorControlState.target_speed = (float)speed_magnitude;
				}
				

			}
		}
		tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
		if(g_emergencyBrake && g_motorControlState.direction == 1 )
		{
			tx_mutex_put(&g_emergencyMutex);
			tx_thread_sleep(10);
			continue ;
		}
		tx_mutex_put(&g_emergencyMutex);

		if (g_motorControlState.direction == 0)
			MotorControlUpdate(&g_motorControlState, g_currentSpeed);
		else if (g_motorControlState.direction == 2)
		{
			tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
		    MotorSetPWM(0, 0);
		    tx_mutex_put(&g_motorMutex);
		}
		
		
		tx_thread_sleep(10);
	}
}
