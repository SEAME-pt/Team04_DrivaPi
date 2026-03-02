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
 * @brief Set the Servo Angle object
 * 
 * @param channel 
 * @param angle_deg 
 * @return int 
 */
int SetServoAngle(uint8_t channel, uint16_t angle_deg)
{
	if (angle_deg > 180u)
		angle_deg = 180u;

	uint16_t range = SERVO_MAX_PULSE - SERVO_MIN_PULSE;
	uint16_t pulse = SERVO_MIN_PULSE + (range * angle_deg) / 180u;
	if (PCA9685_SetPWM(PCA9685_ADDR_SERVO, channel, 0, pulse) == HAL_OK)
	{
		return 1;
	}
	return 0;
}


/**
 * @brief Servo motor control thread that processes steering commands from CAN queue
 * 
 * @param initial_input
 * @return VOID
 */
void ServoMotor(ULONG initial_input)
{
	t_can_message msg;
	ULONG actual_flags;

	while (1)
	{
		tx_event_flags_get(&g_eventFlags, FLAG_CAN_STEER_CMD, TX_OR_CLEAR, &actual_flags, TX_NO_WAIT);
		while (tx_queue_receive(&g_queueSteerCmd, &msg, TX_NO_WAIT) == TX_SUCCESS)
		{
			float angle_f = *((float *)msg.data);
			uint16_t angle = (uint16_t)angle_f;
			SetServoAngle(SERVO_CH, angle);
		}
		tx_thread_sleep(10);
	}
}
