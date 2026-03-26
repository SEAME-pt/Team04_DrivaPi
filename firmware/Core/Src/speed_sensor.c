/**
  ******************************************************************************
  * @file    firmware/Core/Src/speed_sensor.c
  * @author  DrivaPi Team
  * @brief   This file contains the speed sensor reading functions.
  ******************************************************************************
  * @attention
  *
  */

#include "speed_sensor.h"

/**
 * @brief Determine R/N/D gear state based on speed and PWM direction.
 *
 * @param speed Current wheel speed.
 * @param pwm_value Signed PWM value.
 * @return RNDGear_t Derived gear state.
 */
RNDGear_t DetermineRNDGear(float speed, int16_t pwm_value)
{
	if (speed > RND_DEADZONE_POSITIVE)
	{
		if (pwm_value > 0)
		{
			return GEAR_DRIVE;
		}
		else if (pwm_value < 0)
		{
			return GEAR_REVERSE;
		}
	}
	return GEAR_NEUTRAL;
}

/**
* @brief Read wheel speed from the encoder timer.
*
* @return float Speed in meters per second.
*/
float ReadSpeedSensor(void)
{
	static ULONG last_time_ticks = 0;
	static uint32_t last_count = 0;
	static uint8_t is_first_run = 1;

	ULONG current_time_ticks = tx_time_get();
	uint32_t current_count = htim1.Instance->CNT;

	if (is_first_run)
	{
		last_count = current_count;
		last_time_ticks = current_time_ticks;
		is_first_run = 0;
		return 0.0f;
	}
	ULONG delta_ticks = current_time_ticks - last_time_ticks;
	float dt = (float)delta_ticks / (float)TX_TIMER_TICKS_PER_SECOND;
	if (dt <= 0.001f)
		return 0.0f;
	int32_t delta = (int32_t)current_count - (int32_t)last_count;
	if (delta > (TIMER_PERIOD / 2))
		delta -= (TIMER_PERIOD + 1);
	else if (delta < -(TIMER_PERIOD / 2))
		delta += (TIMER_PERIOD + 1);
	last_count = current_count;
	last_time_ticks = current_time_ticks;
	float rotations = (float)delta / (float)PULSES_PER_REV;
	float distance_m = rotations * WHEEL_PERIMETER_M;
	float speed_mps = distance_m / dt;
	return speed_mps;
}

/**
 * @brief Thread entry that samples speed sensor and updates CAN events.
 *
 * @param initial_input ThreadX initial input (unused).
 * @return VOID
 */
VOID SpeedSensor(ULONG initial_input)
{
	static RNDGear_t last_gear = GEAR_NEUTRAL;
	HAL_TIM_Base_Stop(&htim1);
	__HAL_RCC_TIM1_CLK_ENABLE();
	HAL_TIM_Base_Start(&htim1);

	while (1)
	{
		tx_thread_sleep(50);
		float current_speed = ReadSpeedSensor();

		tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
		g_vehicleSpeed = current_speed;
		g_current_speed = current_speed;
		tx_mutex_put(&g_speedDataMutex);

		tx_mutex_get(&g_gearMutex, TX_WAIT_FOREVER);
		g_current_gear = DetermineRNDGear(current_speed, g_current_pwm);
		RNDGear_t current_gear = g_current_gear;
		tx_mutex_put(&g_gearMutex);

		if (current_gear != last_gear)
		{
			t_can_message can_msg;
			memset(&can_msg, 0, sizeof(can_msg));
			can_msg.id = CAN_ID_RND_GEAR;
			can_msg.len = 1;
			can_msg.data[0] = (uint8_t)current_gear;
			CanSend(&can_msg);
			last_gear = current_gear;
		}
		tx_event_flags_set(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR);
	}
}
