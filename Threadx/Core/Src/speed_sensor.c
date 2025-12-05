#include "app_threadx.h"
#include "speed_sensor.h"
#include "main.h"
#include <stdio.h>


extern TIM_HandleTypeDef htim1;
extern UART_HandleTypeDef huart1;


#define WHEEL_PERIMETER_M   0.212f
#define PULSES_PER_REV      30.0f
#define TIMER_PERIOD        65535


#ifndef TX_TIMER_TICKS_PER_SECOND
#define TX_TIMER_TICKS_PER_SECOND 1000
#endif

float read_speed_sensor(void)
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

    if (dt <= 0.001f) return 0.0f;


    uint32_t pulses = 0;
    if (current_count >= last_count)
    {
        pulses = current_count - last_count;
    }
    else
    {
        pulses = (TIMER_PERIOD - last_count) + current_count + 1;
    }


    last_count = current_count;
    last_time_ticks = current_time_ticks;


    float rotations = (float)pulses / PULSES_PER_REV;
    float distance_m = rotations * WHEEL_PERIMETER_M;
    float speed_mps = distance_m / dt;

    return speed_mps;
}

VOID speed_sensor(ULONG initial_input)
{
    char msg[64];

    HAL_TIM_Base_Stop(&htim1);


    __HAL_RCC_TIM1_CLK_ENABLE();

    HAL_TIM_Base_Start(&htim1);

    while (1)
    {

        uint32_t cr1_reg = htim1.Instance->CR1;
        uint32_t cnt_reg = htim1.Instance->CNT;


        snprintf(msg, sizeof(msg), "DEBUG: CR1=%lu | CNT=%lu\r\n", cr1_reg, cnt_reg);
        HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);


        tx_thread_sleep(100);


        float current_speed = read_speed_sensor();

        snprintf(msg, sizeof(msg), "Speed: %.2f m/s\r\n", current_speed);
        HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), 100);


        tx_mutex_get(&speed_data_mutex, TX_WAIT_FOREVER);
        g_vehicle_speed = current_speed;
        tx_mutex_put(&speed_data_mutex);

        tx_event_flags_set(&event_flags, FLAG_SENSOR_UPDATE, TX_OR);
    }
}
