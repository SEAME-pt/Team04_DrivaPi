#include "app_threadx.h"
#include "speed_sensor.h"
#include "main.h"
#include <stdio.h>

/* External Handles */
extern TIM_HandleTypeDef htim1;
extern UART_HandleTypeDef huart1;

/* Config */
#define WHEEL_PERIMETER_M   0.212f
#define PULSES_PER_REV      30.0f
#define TIMER_PERIOD        65535

/* ThreadX Ticks per second (Default is 1000 for 1ms ticks) */
#ifndef TX_TIMER_TICKS_PER_SECOND
#define TX_TIMER_TICKS_PER_SECOND 1000
#endif

float read_speed_sensor(void)
{
    static ULONG last_time_ticks = 0;
    static uint32_t last_count = 0;
    static uint8_t is_first_run = 1;

    // 1. Use ThreadX Time, NOT HAL_GetTick
    ULONG current_time_ticks = tx_time_get();

    // 2. Direct Register Access (Bypasses HAL macros for safety)
    // If this is 0, the physical pin is not receiving pulses or timer is off
    uint32_t current_count = htim1.Instance->CNT;

    // Handle first run
    if (is_first_run)
    {
        last_count = current_count;
        last_time_ticks = current_time_ticks;
        is_first_run = 0;
        return 0.0f;
    }

    // 3. Calculate Delta Time (Seconds)
    ULONG delta_ticks = current_time_ticks - last_time_ticks;
    float dt = (float)delta_ticks / (float)TX_TIMER_TICKS_PER_SECOND;

    if (dt <= 0.001f) return 0.0f;

    // 4. Calculate Pulses (Handling 16-bit Overflow)
    uint32_t pulses = 0;
    if (current_count >= last_count)
    {
        pulses = current_count - last_count;
    }
    else
    {
        pulses = (TIMER_PERIOD - last_count) + current_count + 1;
    }

    // Update state
    last_count = current_count;
    last_time_ticks = current_time_ticks;

    // 5. Math
    float rotations = (float)pulses / PULSES_PER_REV;
    float distance_m = rotations * WHEEL_PERIMETER_M;
    float speed_mps = distance_m / dt;

    return speed_mps;
}

VOID speed_sensor(ULONG initial_input)
{
    ULONG actual_flags;
    char msg[64];

    /* ------------------------------------------------------------- */
    /* FORCE RE-INITIALIZATION                                       */
    /* Sometimes RTOS startup disables peripherals. We restart here. */
    /* ------------------------------------------------------------- */

    // 1. Stop to be safe
    HAL_TIM_Base_Stop(&htim1);

    // 2. Force Enable the Clock (Just in case)
    __HAL_RCC_TIM1_CLK_ENABLE();

    // 3. Start the timer in the correct External Clock mode
    // (This function relies on the setup done in MX_TIM1_Init in main.c)
    HAL_TIM_Base_Start(&htim1);

    while (1)
    {
        // Debug: Print Register State to verify Hardware is ON
        // CR1 Bit 0 (CEN) should be 1.
        uint32_t cr1_reg = htim1.Instance->CR1;
        uint32_t cnt_reg = htim1.Instance->CNT;

        // If CR1 is odd (e.g. 1, 3, 5), the timer is ENABLED.
        // If CNT is 0, it is enabled but waiting for pulses.
        snprintf(msg, sizeof(msg), "DEBUG: CR1=%lu | CNT=%lu\r\n", cr1_reg, cnt_reg);
        HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);

        // Wait 500ms
        tx_thread_sleep(500);

        // Read Speed
        float current_speed = read_speed_sensor();

        snprintf(msg, sizeof(msg), "Speed: %.2f m/s\r\n", current_speed);
        HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);

        // Update Shared Data
        tx_mutex_get(&speed_data_mutex, TX_WAIT_FOREVER);
        g_vehicle_speed = current_speed;
        tx_mutex_put(&speed_data_mutex);

        tx_event_flags_set(&event_flags, FLAG_SENSOR_UPDATE, TX_OR);
    }
}
