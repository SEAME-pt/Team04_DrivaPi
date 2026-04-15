/**
 * @file ultrasonic_module.c
 * @brief ThreadX module that evaluates obstacle risk and controls emergency braking behavior.
 */

#include "txm_module.h"
#include "ultrasonic_module_api.h"

#define ULTRASONIC_SAMPLE_PERIOD_TICKS        1u
#define ULTRASONIC_HEARTBEAT_TICKS            3000u
#define ULTRASONIC_BRAKE_THRESHOLD_CM         17u
#define ULTRASONIC_TTC_THRESHOLD_MS           450u
#define ULTRASONIC_MIN_TTC_BACKSPIN_MS        200u
#define ULTRASONIC_DT_SECONDS                 0.057f

/**
 * @brief Sends an application request from the ultrasonic module to the module manager.
 * @param request Request identifier defined in the ultrasonic module API.
 * @param p1 First request argument.
 * @param p2 Second request argument.
 * @param p3 Third request argument.
 * @return Module manager request status/result value.
 */
static UINT ModuleRequest(ULONG request, ALIGN_TYPE p1, ALIGN_TYPE p2, ALIGN_TYPE p3)
{
    return txm_module_application_request(request, p1, p2, p3);
}

/**
 * @brief Main entry point for the ultrasonic module execution loop.
 * @param id ThreadX module instance identifier (unused by this module).
 * @return None.
 */
void ultrasonic_module_start(ULONG id)
{
    static INT last_distance_cm = -1;
    static ULONG last_publish_tick = 0u;
    static UINT init_done = 0u;

    TX_PARAMETER_NOT_USED(id);

    (void)ModuleRequest(ULTRASONIC_MODULE_REQ_DEBUG_LOG, ULTRASONIC_MODULE_LOG_RUNNING, 0u, 0u);

    while (1)
    {
        INT distance_cm;
        INT speed_mmps;
        UINT gear;
        ULONG now_tick;
        float velocity_cm_s;
        float ttc_ms;
        INT delta_cm;

        tx_thread_sleep(ULTRASONIC_SAMPLE_PERIOD_TICKS);

        if (init_done == 0u)
        {
            (void)ModuleRequest(ULTRASONIC_MODULE_REQ_INIT, 0u, 0u, 0u);
            init_done = 1u;
        }

        now_tick = (ULONG)ModuleRequest(ULTRASONIC_MODULE_REQ_GET_TICKS, 0u, 0u, 0u);
        distance_cm = (INT)ModuleRequest(ULTRASONIC_MODULE_REQ_GET_RANGE_CM, 0u, 0u, 0u);
        speed_mmps = (INT)ModuleRequest(ULTRASONIC_MODULE_REQ_GET_CURRENT_SPEED_MMPS, 0u, 0u, 0u);
        gear = (UINT)ModuleRequest(ULTRASONIC_MODULE_REQ_GET_CURRENT_GEAR, 0u, 0u, 0u);

        if ((UINT)distance_cm == ULTRASONIC_MODULE_INVALID_SAMPLE)
        {
            (void)ModuleRequest(ULTRASONIC_MODULE_REQ_SET_EMERGENCY_BRAKE, 0u, 0u, 0u);
            continue;
        }

        if (last_distance_cm < 0)
        {
            last_distance_cm = distance_cm;
            last_publish_tick = now_tick;
            continue;
        }

        delta_cm = last_distance_cm - distance_cm;
        if (delta_cm > 1 || delta_cm < -1)
            velocity_cm_s = (float)delta_cm / ULTRASONIC_DT_SECONDS;
        else
            velocity_cm_s = 0.0f;

        if (velocity_cm_s > 10.0f)
            ttc_ms = ((float)distance_cm / velocity_cm_s) * 1000.0f;
        else
            ttc_ms = 9999.0f;
        
        if ((gear != ULTRASONIC_MODULE_GEAR_REVERSE) && ((ttc_ms < (float)ULTRASONIC_TTC_THRESHOLD_MS) || (distance_cm < (INT)ULTRASONIC_BRAKE_THRESHOLD_CM)))
        {
            (void)ModuleRequest(ULTRASONIC_MODULE_REQ_SET_EMERGENCY_BRAKE, 0u, 0u, 0u);

            if ((ttc_ms < (float)ULTRASONIC_TTC_THRESHOLD_MS) && (ttc_ms >= (float)ULTRASONIC_MIN_TTC_BACKSPIN_MS))
                (void)ModuleRequest(ULTRASONIC_MODULE_REQ_MOTOR_STOP, 0u, 0u, 0u);
            else if ((ttc_ms < (float)ULTRASONIC_MIN_TTC_BACKSPIN_MS) && (distance_cm > (INT)ULTRASONIC_BRAKE_THRESHOLD_CM) && (speed_mmps >= 200) && (gear != ULTRASONIC_MODULE_GEAR_REVERSE))
                (void)ModuleRequest(ULTRASONIC_MODULE_REQ_MOTOR_BACKSPIN, 0u, 0u, 0u);
            else if ((distance_cm <= (INT)ULTRASONIC_BRAKE_THRESHOLD_CM) && (gear != ULTRASONIC_MODULE_GEAR_REVERSE))
                (void)ModuleRequest(ULTRASONIC_MODULE_REQ_MOTOR_STOP, 0u, 0u, 0u);
        }
        else if ((ttc_ms > (float)ULTRASONIC_TTC_THRESHOLD_MS) && (distance_cm > (INT)ULTRASONIC_BRAKE_THRESHOLD_CM))
            (void)ModuleRequest(ULTRASONIC_MODULE_REQ_CLEAR_EMERGENCY_BRAKE, 0u, 0u, 0u);

        last_distance_cm = distance_cm;

        if ((now_tick - last_publish_tick) >= ULTRASONIC_HEARTBEAT_TICKS)
            last_publish_tick = now_tick;
    }
}
