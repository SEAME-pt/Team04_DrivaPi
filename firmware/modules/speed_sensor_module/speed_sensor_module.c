#include "txm_module.h"
#include "speed_sensor_module_api.h"

#define TIMER_PERIOD               65535L
#define PULSES_PER_REV             30L
#define WHEEL_PERIMETER_MM         212L

#define RND_DEADZONE_MMPS          200L

static UINT ModuleRequest(ULONG request, ALIGN_TYPE p1, ALIGN_TYPE p2, ALIGN_TYPE p3)
{
    return txm_module_application_request(request, p1, p2, p3);
}

static UINT DetermineGear(INT speed_mmps, INT pwm_value)
{
    if (speed_mmps > (INT)RND_DEADZONE_MMPS)
    {
        if (pwm_value > 0)
        {
            return SPEED_SENSOR_MODULE_GEAR_DRIVE;
        }
        if (pwm_value < 0)
        {
            return SPEED_SENSOR_MODULE_GEAR_REVERSE;
        }
    }

    if (speed_mmps < (INT)(-RND_DEADZONE_MMPS))
    {
        if (pwm_value > 0)
        {
            return SPEED_SENSOR_MODULE_GEAR_DRIVE;
        }
        if (pwm_value < 0)
        {
            return SPEED_SENSOR_MODULE_GEAR_REVERSE;
        }
    }

    return SPEED_SENSOR_MODULE_GEAR_NEUTRAL;
}

void speed_sensor_module_start(ULONG id)
{
    static ULONG last_ticks = 0u;
    static ULONG last_count = 0u;
    static UINT sample_initialized = 0u;

    TX_PARAMETER_NOT_USED(id);

    while (1)
    {
        ULONG current_ticks;
        ULONG current_count;
        INT pwm_value;
        INT delta_count;
        ULONG delta_ticks;
        INT speed_mmps;
        UINT gear;
        INT distance_mm;

        tx_thread_sleep(50u);

        current_count = (ULONG)ModuleRequest(SPEED_SENSOR_MODULE_REQ_GET_ENCODER_COUNT, 0u, 0u, 0u);
        current_ticks = (ULONG)ModuleRequest(SPEED_SENSOR_MODULE_REQ_GET_TICKS, 0u, 0u, 0u);
        pwm_value = (INT)ModuleRequest(SPEED_SENSOR_MODULE_REQ_GET_PWM, 0u, 0u, 0u);

        if (sample_initialized == 0u)
        {
            last_count = current_count;
            last_ticks = current_ticks;
            sample_initialized = 1u;
            (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_PUBLISH_SPEED_MMPS, 0u, 0u, 0u);
            (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_PUBLISH_GEAR, SPEED_SENSOR_MODULE_GEAR_NEUTRAL, 0u, 0u);
            (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_DEBUG_LOG, SPEED_SENSOR_MODULE_LOG_RUNNING, 0u, 0u);
            continue;
        }

        delta_ticks = current_ticks - last_ticks;
        if (delta_ticks == 0u)
        {
            continue;
        }

        delta_count = (INT)current_count - (INT)last_count;
        if (delta_count > (INT)(TIMER_PERIOD / 2L))
        {
            delta_count -= (INT)(TIMER_PERIOD + 1L);
        }
        else if (delta_count < (INT)(-(TIMER_PERIOD / 2L)))
        {
            delta_count += (INT)(TIMER_PERIOD + 1L);
        }

        last_count = current_count;
        last_ticks = current_ticks;

        distance_mm = (delta_count * (INT)WHEEL_PERIMETER_MM) / (INT)PULSES_PER_REV;
        speed_mmps = (distance_mm * (INT)TX_TIMER_TICKS_PER_SECOND) / (INT)delta_ticks;

        (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_PUBLISH_SPEED_MMPS, (ALIGN_TYPE)speed_mmps, 0u, 0u);

        gear = DetermineGear(speed_mmps, pwm_value);
        (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_PUBLISH_GEAR, (ALIGN_TYPE)gear, 0u, 0u);
    }
}
