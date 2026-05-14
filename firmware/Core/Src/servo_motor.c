/**
  ******************************************************************************
  * @file    firmware/Core/Src/servo_motor.c
  * @author  DrivaPi Team
  * @brief   This file contains the servo motor control functions.
  ******************************************************************************
  * @attention
  *
  */

#include "servo_motor.h"

/**
  * @brief Maps physical angle (0-180) to Servo duty cycle (1ms to 2ms pulse)
  * Utilizing the TIM8 ARR of 19999.
	*
	* @param angle Requested servo angle in degrees.
	* @return void
  */
void SetServoAngle(uint8_t angle) {
    if (angle > 180)
    	angle = 180;

    // Maps 0 - 180 degrees to 1000 - 2000 pulse width ticks
    uint32_t compare_value = 1000 + ((uint32_t)angle * 1000 / 180);

    __HAL_TIM_SET_COMPARE(&htim8, TIM_CHANNEL_4, compare_value);
}

/**
 * @brief Servo motor thread entry that handles steering commands.
 *
 * @param initial_input ThreadX initial input (unused).
 * @return void
 */
void ServoMotor(ULONG initial_input)
{
	t_can_message	msg;
	ULONG			actual_flags;

	while (1)
	{
		tx_event_flags_get(&g_eventFlags, FLAG_CAN_STEER_CMD, TX_OR_CLEAR, &actual_flags, TX_WAIT_FOREVER);
		
		while (tx_queue_receive(&g_queueSteerCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
		{
			tx_mutex_get(&g_servoMutex, TX_WAIT_FOREVER);

			uint8_t angle_raw;
			memcpy(&angle_raw, msg.data, sizeof(uint8_t));

			SetServoAngle(angle);

			tx_mutex_put(&g_servoMutex);
		}
	}
}
