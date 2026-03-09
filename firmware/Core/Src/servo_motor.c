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
 * @brief Set a servo angle using PCA9685 PWM output.
 *
 * @param channel PWM channel index.
 * @param angle_deg Target angle in degrees.
 * @return int 1 on success.
 */
int SetServoAngle(uint8_t channel, uint16_t angle_deg)
{
	if (angle_deg > 180u)
		angle_deg = 180u;

	uint16_t range = SERVO_MAX_PULSE - SERVO_MIN_PULSE;
	uint16_t pulse = SERVO_MIN_PULSE + (range * angle_deg) / 180u;
	HAL_StatusTypeDef status = PCA9685_SetPWM(PCA9685_ADDR_SERVO, channel, 0, pulse);
	if (status == HAL_OK)
		return 1;
	else
		return 0;
}

/**
 * @brief Servo motor thread entry that handles steering commands.
 *
 * @param initial_input ThreadX initial input (unused).
 * @return void
 */
void ServoMotor(ULONG initial_input)
{
	t_can_message msg;
	ULONG actual_flags;

	while (1)
	{
		tx_event_flags_get(&g_eventFlags, FLAG_CAN_STEER_CMD, TX_OR_CLEAR, &actual_flags, TX_WAIT_FOREVER);
		
		while (tx_queue_receive(&g_queueSteerCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
		{
			tx_mutex_get(&g_servoMutex, TX_WAIT_FOREVER);
			float angle_f = *((float *)msg.data);
			uint16_t angle = (uint16_t)angle_f;
			SetServoAngle(SERVO_CH, angle);
			tx_mutex_put(&g_servoMutex);
		}
	}
}
