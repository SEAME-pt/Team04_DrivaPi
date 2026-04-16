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
	uint8_t sensor_present = 0;
	int config_attempts = 0;
	while (!sensor_present && config_attempts < 10)
	{
		config_attempts++;
		Soft_I2C_Start();
		if (Soft_I2C_WriteByte(SRF08_ADDR) == 1)
		{
			Soft_I2C_WriteByte(0x02);
			Soft_I2C_WriteByte(0x46); // 3m Range
			sensor_present = 1;
		}
		Soft_I2C_Stop();
		tx_thread_sleep(5);
	}

	// Print Status and disable if sensor not detected
	if (sensor_present)
	{
		const char *msg = "[US] Ultrasonic: CONFIG OK\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);
		msg = "[US] Ultrasonic: runtime loop disabled for crash isolation\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);
		while (1)
		{
			tx_thread_sleep(TX_WAIT_FOREVER);
		}
	}
	else
	{
		const char *msg = "[US] Ultrasonic: Sensor not detected - retrying\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);
	}

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
			tx_thread_sleep(10);
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
			tx_thread_sleep(10);
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
		if (tx_mutex_get(&g_speedDataMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
		{
			current_speed = g_vehicleSpeed;
			tx_mutex_put(&g_speedDataMutex);
		}


		if (tx_mutex_get(&g_gearMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
		{
			current_gear = g_current_gear;
			tx_mutex_put(&g_gearMutex);
		}

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

			if (current_gear != GEAR_REVERSE && (ttc_ms < TTC_THRESHOLD_MS || range_cm < BRAKE_THRESHOLD_CM))
			{
				if (tx_mutex_get(&g_emergencyMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
				{
					g_emergencyBrake = true;
					tx_mutex_put(&g_emergencyMutex);
				}
				{
					const char *msg = "! STOPPING !\r\n";
					HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);
				}

				if (ttc_ms < TTC_THRESHOLD_MS && ttc_ms >= 200 && current_gear != GEAR_REVERSE)
				{
					if (tx_mutex_get(&g_motorMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
					{
						MotorSetPWM(0, 0);
						tx_mutex_put(&g_motorMutex);
					}
				}
				else if (ttc_ms < 200 && range_cm > BRAKE_THRESHOLD_CM && current_speed >= 0.2 && current_gear != GEAR_REVERSE)
				{
					for (int i = 1; i <= (BACKSPIN_THRESHOLD * current_speed); i++)
					{
						if (i % 2 == 0)
						{
							if (tx_mutex_get(&g_motorMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
							{
								MotorSetPWM(-4096, -4096);
								tx_mutex_put(&g_motorMutex);
							}

							{
								const char *msg = "! ABS !\r\n";
								HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);
							}
						}
						else if (i % 5 == 0)
						{
							if (tx_mutex_get(&g_motorMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
							{
								MotorSetPWM(0, 0);
								tx_mutex_put(&g_motorMutex);
							}
						}
					}
					if (tx_mutex_get(&g_motorMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
					{
						MotorSetPWM(0, 0);
						tx_mutex_put(&g_motorMutex);
					}
				}
				else if (range_cm <= BRAKE_THRESHOLD_CM && current_gear)
				{
					if (tx_mutex_get(&g_motorMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
					{
						MotorSetPWM(0, 0);
						tx_mutex_put(&g_motorMutex);
					}
				}
				else
				{
					const char *msg = "sike!\r\n";
					HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);
				}
			}
			else if (ttc_ms > TTC_THRESHOLD_MS && range_cm > BRAKE_THRESHOLD_CM)
			{
				if (tx_mutex_get(&g_emergencyMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
				{
					g_emergencyBrake = false;
					tx_mutex_put(&g_emergencyMutex);
				}
				{
					const char *msg = "brake free\r\n";
					HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);
				}
			}
			dist_old = range_cm;
		}

		tx_thread_sleep(100);
	}
}
