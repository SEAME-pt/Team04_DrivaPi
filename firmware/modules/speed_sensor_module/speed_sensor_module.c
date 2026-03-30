#include "txm_module.h"
#include "speed_sensor_module_api.h"

#define TIMER_PERIOD               65535.0f
#define PULSES_PER_REV             30.0f
#define WHEEL_PERIMETER_M          0.212f

#define RND_DEADZONE_POSITIVE      0.2f
#define RND_DEADZONE_NEGATIVE     -0.2f

static UINT ModuleRequest(ULONG request, ALIGN_TYPE p1, ALIGN_TYPE p2, ALIGN_TYPE p3)
{
    return txm_module_application_request(request, p1, p2, p3);
}

static UINT DetermineGear(float speed_mps, INT pwm_value)
{
    if (speed_mps > RND_DEADZONE_POSITIVE)
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

    if (speed_mps < RND_DEADZONE_NEGATIVE)
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
    static UINT first_sample = 1u;

    TX_PARAMETER_NOT_USED(id);

    (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_DEBUG_LOG, SPEED_SENSOR_MODULE_LOG_RUNNING, 0u, 0u);

    while (1)
    {
        ULONG current_ticks;
        ULONG current_count;
        INT pwm_value;
        INT delta_count;
        ULONG delta_ticks;
        float dt;
        float rotations;
        float distance_m;
        float speed_mps;
        INT speed_mmps;
        UINT gear;

        tx_thread_sleep(50u);

        current_count = (ULONG)ModuleRequest(SPEED_SENSOR_MODULE_REQ_GET_ENCODER_COUNT, 0u, 0u, 0u);
        current_ticks = (ULONG)ModuleRequest(SPEED_SENSOR_MODULE_REQ_GET_TICKS, 0u, 0u, 0u);
        pwm_value = (INT)ModuleRequest(SPEED_SENSOR_MODULE_REQ_GET_PWM, 0u, 0u, 0u);

        if (first_sample)
        {
            last_count = current_count;
            last_ticks = current_ticks;
            first_sample = 0u;
            (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_PUBLISH_SPEED_MMPS, 0u, 0u, 0u);
            (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_PUBLISH_GEAR, SPEED_SENSOR_MODULE_GEAR_NEUTRAL, 0u, 0u);
            continue;
        }

        delta_ticks = current_ticks - last_ticks;
        if (delta_ticks == 0u)
        {
            continue;
        }

        delta_count = (INT)current_count - (INT)last_count;
        if (delta_count > (INT)(TIMER_PERIOD / 2.0f))
        {
            delta_count -= (INT)(TIMER_PERIOD + 1.0f);
        }
        else if (delta_count < (INT)(-(TIMER_PERIOD / 2.0f)))
        {
            delta_count += (INT)(TIMER_PERIOD + 1.0f);
        }

        last_count = current_count;
        last_ticks = current_ticks;

        dt = (float)delta_ticks / (float)TX_TIMER_TICKS_PER_SECOND;
        if (dt <= 0.001f)
        {
            continue;
        }

        rotations = (float)delta_count / PULSES_PER_REV;
        distance_m = rotations * WHEEL_PERIMETER_M;
        speed_mps = distance_m / dt;
        speed_mmps = (INT)(speed_mps * 1000.0f);

        (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_PUBLISH_SPEED_MMPS, (ALIGN_TYPE)speed_mmps, 0u, 0u);

        gear = DetermineGear(speed_mps, pwm_value);
        (void)ModuleRequest(SPEED_SENSOR_MODULE_REQ_PUBLISH_GEAR, (ALIGN_TYPE)gear, 0u, 0u);
    }
}
