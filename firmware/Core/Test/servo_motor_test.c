#include "servo_motor.h"

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
