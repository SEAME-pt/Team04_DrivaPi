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
 * @brief
 *
 * @param hi2c
 * @param addr7
 * @param channel
 * @param angle_deg
 * @param min_pulse
 * @param max_pulse
 * @return int
 */
int SetServoAngle(uint8_t channel, uint16_t angle_deg)
{
	if (angle_deg > 180u)
		angle_deg = 180u;

	uint16_t range = SERVO_MAX_PULSE - SERVO_MIN_PULSE;
	uint16_t pulse = SERVO_MIN_PULSE + (range * angle_deg) / 180u;
	PCA9685_SetPWM(PCA9685_ADDR_SERVO, channel, 0, pulse);
	return 1;
}

/**
 * @brief
 *
 * @param hi2c
 * @param addr7
 * @param channel
 * @param start_angle
 * @param end_angle
 * @param step_angle
 * @param delay_ms
 * @param min_pulse
 * @param max_pulse
 * @return int
 */
int ServoSweep(uint8_t channel, uint16_t start_angle, uint16_t end_angle,
uint16_t step_angle)
{
	if (step_angle == 0)
		step_angle = 1;

	if (start_angle <= end_angle)
	{
		for (uint16_t angle = start_angle; angle <= end_angle; angle += step_angle)
		{
			SetServoAngle(channel, angle);
			tx_thread_sleep(50);
			if (angle > UINT16_MAX - step_angle)
				break;
		}
	}
	else
	{
		for (int angle = (int)start_angle; angle >= (int)end_angle; angle -= (int)step_angle)
		{
			SetServoAngle(channel, (uint16_t)angle);
			tx_thread_sleep(10);
			if (angle - (int)step_angle > angle)
				break;
		}
	}
	const char *msg = "Servo_Sweep: complete\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t *)msg, strlen(msg), HAL_MAX_DELAY);
	return 0;
}

/**
 * @brief
 *
 * @param initial_input
 * @return void
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
