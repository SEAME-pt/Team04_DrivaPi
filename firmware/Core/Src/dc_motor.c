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
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, 0);
		g_current_pwm = 0;
	}
//	else
//	{
//		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
//		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
//		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, max);
//		g_current_pwm = 0;
//	}

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
		g_current_pwm = 0;
	}
//	else
//	{
//		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
//		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
//		PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, max);
//	}
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
				int32_t direction = 0;  // 1 = forward, 0 = backward
				
				memcpy(&speed_magnitude, msg.data, sizeof(int32_t));
				memcpy(&direction, msg.data + sizeof(int32_t), sizeof(int32_t));
				
				// Debug print
				char debug_buf[80];
				sprintf(debug_buf, "CAN: Speed=%ld, Dir=%ld (%s)\r\n", 
				        speed_magnitude, direction, (direction == 1) ? "FWD" : "BWD");
				UartPrint(debug_buf);
				
				// Convert to signed speed: positive for forward, negative for backward
				if (direction == 1)
				{
					g_motorPidState.target_speed = (float)speed_magnitude;
				}
				else  // direction == 0 (backward)
				{
					g_motorPidState.target_speed = -(float)speed_magnitude;
				}
				
				sprintf(debug_buf, "Target: %d hm/h\r\n", (int)g_motorPidState.target_speed);
				UartPrint(debug_buf);
			}
		}
		
		// Run PID control EVERY loop iteration (100ms)
		MotorPIDUpdate(&g_motorPidState, g_current_speed);
		
		// Print current speed every 10 iterations (1 second)
		if (++debug_counter >= 10)
		{
			debug_counter = 0;
			char speed_buf[80];
			int current_hm = (int)(g_current_speed * 36.0f);
			sprintf(speed_buf, "Curr: %d hm/h, Target: %d, PWM: %d\r\n", 
			        current_hm, (int)g_motorPidState.target_speed, (int)g_motorPidState.pwm_raw);
			UartPrint(speed_buf);
		}
		
		tx_thread_sleep(10);  // 100ms loop
	}
}
