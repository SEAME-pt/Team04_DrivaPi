#include "stm32u5xx_hal.h"

#include "app_threadx.h"
#include "speed_sensor.h"

#include "stm32u5xx_hal.h"
#define HAL_TIM_MODULE_ENABLED

/* Import the timer handle from main.c or tim.c */
extern TIM_HandleTypeDef htim1;

/* Definitions from your main.c */
#define WHEEL_PERIMETER_M   0.212f
#define PULSES_PER_REV      30.0f
#define TIMER_PERIOD        65535   // 16-bit timer period

float read_speed_sensor(void)
{
    // Static variables preserve values between function calls
    static uint32_t last_count = 0;
    static uint32_t last_tick = 0;
    static uint8_t is_first_run = 1;

    uint32_t current_count = 0;
    uint32_t pulses = 0;
    uint32_t current_tick = HAL_GetTick();

    // 1. Read the Hardware Timer
    current_count = __HAL_TIM_GET_COUNTER(&htim1);

    // Handle first run initialization to prevent erratic speed spikes
    if (is_first_run)
    {
        last_count = current_count;
        last_tick = current_tick;
        is_first_run = 0;
        return 0.0f;
    }

    // 2. Calculate Time Elapsed (Delta T) in seconds
    // We calculate this dynamically because ThreadX threads might not run at exact fixed intervals
    float dt = (float)(current_tick - last_tick) / 1000.0f;

    // Safety check to avoid division by zero
    if (dt <= 0.001f)
    {
        return 0.0f;
    }

    // 3. Calculate Pulses (Handle 16-bit rollover 65535 -> 0)
    if (current_count >= last_count)
    {
        pulses = current_count - last_count;
    }
    else
    {
        // Timer overflowed
        pulses = (TIMER_PERIOD - last_count) + current_count + 1;
    }

    // Update state for next call
    last_count = current_count;
    last_tick = current_tick;

    // 4. Math Calculation
    float rotations = (float)pulses / PULSES_PER_REV;
    float distance_m = rotations * WHEEL_PERIMETER_M;

    // Calculate Speed: Speed = Distance / Time
    float speed_mps = distance_m / dt;

    return speed_mps;
}

VOID speed_sensor(ULONG initial_input)
{
	ULONG actual_flags;
	
	tx_event_flags_get(&event_flags, FLAG_SENSOR_UPDATE,
	TX_OR_CLEAR, &actual_flags, TX_WAIT_FOREVER);

	float current_speed = read_speed_sensor();

	tx_mutex_get(&speed_data_mutex, TX_WAIT_FOREVER);
	g_vehicle_speed = current_speed;
	tx_mutex_put(&speed_data_mutex);

	// Notify CAN TX thread that new data is ready
	tx_event_flags_set(&event_flags, FLAG_SENSOR_UPDATE, TX_OR);
}
