#include "ultrasonic.h"

/**
 * @brief Ultrasonic sensor thread entry using SRF08 over soft I2C.
 *
 * @param initial_input ThreadX initial input (unused).
 */
void UltrasonicEntry(ULONG initial_input)
{
	// --- INIT ---
	Soft_I2C_Init();
	tx_thread_sleep(10);

	// --- CONFIGURATION ---
	uint8_t	verify_range = 0;
	int		config_attempts = 0;
	while (verify_range != 0x46 && config_attempts < 10)
	{
		config_attempts++;
		Soft_I2C_Start();
		if (Soft_I2C_WriteByte(SRF08_ADDR) == 1)
		{
			Soft_I2C_WriteByte(0x02);
			Soft_I2C_WriteByte(0x46); // 3m Range
		}
		Soft_I2C_Stop();
		tx_thread_sleep(5);

		// Verify
		Soft_I2C_Start();
		if (Soft_I2C_WriteByte(SRF08_ADDR) == 1)
		{
			Soft_I2C_WriteByte(0x02);
			Soft_I2C_Stop();
			Soft_I2C_Start();
			Soft_I2C_WriteByte(SRF08_ADDR|1);
			verify_range = Soft_I2C_ReadByte(0);
		}
		Soft_I2C_Stop();
		tx_thread_sleep(5);
	}

	// Print Status
	if (verify_range == 0x46)
		HAL_UART_Transmit(&huart1, (uint8_t*)"[US] CONFIG OK\r\n", 16, 100);
	else
		HAL_UART_Transmit(&huart1, (uint8_t*)"[US] CONFIG FAIL\r\n", 18, 100);

	// --- VARIABLES ---
	uint8_t high_byte, low_byte;
	int16_t range_cm = 0;
	int16_t dist_old = 0;
	float velocity_cm_s = 0;
	float ttc_ms = 9999;
	float current_speed = 0;
	RNDGear_t current_gear = GEAR_NEUTRAL;

	while(1)
	{
		// 1. PING
		Soft_I2C_Start();
		if (Soft_I2C_WriteByte(SRF08_ADDR) == 0)
		{
			Soft_I2C_Stop();
			tx_thread_sleep(1);
			continue;
		}
		Soft_I2C_WriteByte(CMD_REG);
		Soft_I2C_WriteByte(CMD_CENTIMETERS);
		Soft_I2C_Stop();

		// 2. WAIT
		tx_thread_sleep(6);

		// 3. READ
		Soft_I2C_Start();
		if (Soft_I2C_WriteByte(SRF08_ADDR) == 0)
		{
			Soft_I2C_Stop();
			continue;
		}
		Soft_I2C_WriteByte(RANGE_REG);
		Soft_I2C_Stop();

		Soft_I2C_Start();
		Soft_I2C_WriteByte(SRF08_ADDR | 1);
		high_byte = Soft_I2C_ReadByte(1);
		low_byte  = Soft_I2C_ReadByte(0);
		Soft_I2C_Stop();

		range_cm = (high_byte << 8) | low_byte;

		// Get current speed locally so we don't need to use the mutex every time we try to access it
		tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
		current_speed = g_vehicleSpeed;
		tx_mutex_put(&g_speedDataMutex);


		tx_mutex_get(&g_gearMutex, TX_WAIT_FOREVER);
		current_gear = g_current_gear;
		tx_mutex_put(&g_gearMutex);

		// 4. PHYSICS & SAFETY
		if (range_cm >= 0 && range_cm <= 80)
		{
			// Velocity
			int16_t delta = dist_old - range_cm;
			if (abs(delta) > 1)
				velocity_cm_s = (float)delta / DT_SECONDS;
			else
				velocity_cm_s = 0;

			// TTC
			if (velocity_cm_s > 10.0f)
				ttc_ms = ((float)range_cm / velocity_cm_s) * 1000.0f;
			else
				ttc_ms = 9999.0f;

			// Log
			char msg[64];
			snprintf(msg, sizeof(msg), "D:%d cm | TTC:%.0f ms\r\n", range_cm, ttc_ms);
			HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 10);

			if (current_gear != GEAR_REVERSE && (ttc_ms < TTC_THRESHOLD_MS || range_cm < BRAKE_THRESHOLD_CM))
			{
				tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
				g_emergencyBrake = true;
				tx_mutex_put(&g_emergencyMutex);
				HAL_UART_Transmit(&huart1, (uint8_t*)"! STOPPING !\r\n", 24, 100);

				if (ttc_ms < TTC_THRESHOLD_MS && ttc_ms >= 200 && current_gear != GEAR_REVERSE)
				{
					tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
					MotorSetPWM(0, 0);
					tx_mutex_put(&g_motorMutex);
				}
				else if (ttc_ms < 200 && range_cm > BRAKE_THRESHOLD_CM && current_speed >= 0.2 && current_gear != GEAR_REVERSE)
				{
					for (int i = 1; i <= (BACKSPIN_THRESHOLD * current_speed); i++)
					{
						if (i % 2 == 0)
						{
							tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
							MotorSetPWM(-4096, -4096);
							tx_mutex_put(&g_motorMutex);

							HAL_UART_Transmit(&huart1, (uint8_t*)"! ABS !\r\n", 24, 100);
						}
						else if (i % 5 == 0)
						{
							tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
							MotorSetPWM(0, 0);
							tx_mutex_put(&g_motorMutex);
						}
					}
					tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
					MotorSetPWM(0, 0);
					tx_mutex_put(&g_motorMutex);
				}
				else if (range_cm <= BRAKE_THRESHOLD_CM && current_gear)
				{
					tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
					MotorSetPWM(0, 0);
					tx_mutex_put(&g_motorMutex);
				}
				else
					HAL_UART_Transmit(&huart1, (uint8_t*)"sike!\r\n", 24, 100);
			}
			else if (ttc_ms > TTC_THRESHOLD_MS && range_cm > BRAKE_THRESHOLD_CM)
			{
				tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
				g_emergencyBrake = false;
				tx_mutex_put(&g_emergencyMutex);
				HAL_UART_Transmit(&huart1, (uint8_t*)"brake free\r\n", 24, 100);
			}
			dist_old = range_cm;
		}

		tx_thread_sleep(1);
	}
}
