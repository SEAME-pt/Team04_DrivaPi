/**
 * @file ultrasonic.c
 * @brief SRF08 ultrasonic sensor handling and collision safety thread.
 *
 * Provides helpers to trigger and read SRF08 ranging over I2C and the
 * `UltrasonicEntry` thread that computes velocity, time-to-collision and
 * controls emergency braking logic.
 */
#include "ultrasonic.h"
#include "main.h"

/**
 * @brief Issue a ranging command to the SRF08 sensor.
 *
 * Sends the command to start a single measurement in centimeters.
 *
 * @return HAL_OK on success, otherwise an HAL error code.
 */
static HAL_StatusTypeDef SRF08_StartRanging(void)
{
	uint8_t cmd = SRF08_RANGING_CM;
	return HAL_I2C_Mem_Write(&hi2c3, SRF08_I2C_ADDR, SRF08_CMD_REG, I2C_MEMADD_SIZE_8BIT, &cmd, 1, 200);
}

/**
 * @brief Read the last distance measurement from SRF08.
 *
 * Reads two bytes from the SRF08 echo registers and converts them to a
 * 16-bit distance in centimeters.
 *
 * @return Distance in centimeters on success, or -1 on I2C error.
 */
static int32_t SRF08_ReadDistanceCm(void)
{
	uint8_t data[2] = {0};
	if (HAL_I2C_Mem_Read(&hi2c3, SRF08_I2C_ADDR, SRF08_ECHO_HIGH_REG, I2C_MEMADD_SIZE_8BIT, data, 2, 200) != HAL_OK)
		return -1;
	int32_t dist = ((int32_t)data[0] << 8) | data[1];
	return dist;
}

/**
 * @brief Ultrasonic sensor thread entry using SRF08 over soft I2C.
 *
 * @param initial_input ThreadX initial input (unused).
 */
void UltrasonicEntry(ULONG initial_input)
{
    // --- VARIABLES ---
    int32_t 	range_cm = 0;
    int32_t 	dist_old = -1;
    float 		velocity_cm_s = 0;
    float 		ttc_ms = 9999;
    float 		current_speed = 0;
    RNDGear_t	current_gear = GEAR_NEUTRAL;

    tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
    g_emergencyBrake = false;
    tx_mutex_put(&g_emergencyMutex);
    
    while(1)
    {
        bool sensor_ok = false;
        if (SRF08_StartRanging() == HAL_OK)
        {
            tx_thread_sleep(20); 
            
            range_cm = SRF08_ReadDistanceCm();
            if (range_cm >= 0)
                sensor_ok = true;
        }

        if (!sensor_ok)
        {
            tx_thread_sleep(100);
            
            tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
            g_emergencyBrake = false;
            tx_mutex_put(&g_emergencyMutex);
            
            dist_old = -1;
            continue;
        }
        
        tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
        current_speed = g_vehicleSpeed;
        tx_mutex_put(&g_speedDataMutex);

        tx_mutex_get(&g_gearMutex, TX_WAIT_FOREVER);
        current_gear = g_currentGear;
        tx_mutex_put(&g_gearMutex);

        if (range_cm <= 80) 
        {
            if (dist_old != -1)
            {
                int16_t delta = dist_old - range_cm;
                if (abs(delta) > 1)
                    velocity_cm_s = (float)delta / DT_SECONDS;
                else
                    velocity_cm_s = 0;
            }
            else
            {
                velocity_cm_s = 0;
            }

            if (velocity_cm_s > 10.0f)
                ttc_ms = ((float)range_cm / velocity_cm_s) * 1000.0f;
            else
                ttc_ms = 9999.0f;

            if (current_gear != GEAR_REVERSE && (ttc_ms < TTC_THRESHOLD_MS || range_cm < BRAKE_THRESHOLD_CM))
            {
                tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
                g_emergencyBrake = true;
                tx_mutex_put(&g_emergencyMutex);
				if (ULTRASONIC_DEBUG)
					UartPrintf("! STOPPING ! %d\r\n", (int32_t)ttc_ms );

                if (ttc_ms < TTC_THRESHOLD_MS && ttc_ms >= 200 && current_gear != GEAR_REVERSE)
                {
                    tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
                    StopMotors();
                    tx_mutex_put(&g_motorMutex);
                }
                else if (ttc_ms < 200 && range_cm > BRAKE_THRESHOLD_CM && current_speed >= 0.2 && current_gear != GEAR_REVERSE)
                {
                    for (int i = 1; i <= (BACKSPIN_THRESHOLD * current_speed); i++)
                    {
                        if (i % 2 == 0)
                        {
                            tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
                            MoveMotors(665, false);
                            tx_mutex_put(&g_motorMutex);      
							if (ULTRASONIC_DEBUG)
								UartPrintf("! ABS !\r\n");
                        }
                        else if (i % 5 == 0)
                        {
                            tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
                            StopMotors();
                            tx_mutex_put(&g_motorMutex);
                        }
                    }
                    tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
                    StopMotors();
                    tx_mutex_put(&g_motorMutex);
                }
                else if (range_cm <= BRAKE_THRESHOLD_CM && current_gear)
                {
                    tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
                    StopMotors();
                    tx_mutex_put(&g_motorMutex);
                }
                else
				{	
					if (ULTRASONIC_DEBUG)
						UartPrintf("sike!\r\n");
				}
            }
            else if (ttc_ms > TTC_THRESHOLD_MS && range_cm > BRAKE_THRESHOLD_CM)
            {
                tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
                g_emergencyBrake = false;
                tx_mutex_put(&g_emergencyMutex);
            }
            
            dist_old = range_cm;
        }

        tx_thread_sleep(20);
    }
}
