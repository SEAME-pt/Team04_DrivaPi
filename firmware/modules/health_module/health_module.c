#include "tx_api.h"
#include "health_module_api.h"

#define HEALTH_SAMPLE_PERIOD_TICKS       1000u
#define HEALTH_STALE_THRESHOLD_TICKS     2000u

extern UINT txm_module_application_request(ULONG request, ULONG p1, ULONG p2, ULONG p3);

static UINT ModuleRequest(ULONG request, ULONG p1, ULONG p2, ULONG p3)
{
    return txm_module_application_request(request, p1, p2, p3);
}

static VOID HealthLogLine(const char *ok_line, const char *stale_line, ULONG age_ticks)
{
    if (age_ticks > HEALTH_STALE_THRESHOLD_TICKS)
        (void)ModuleRequest(HEALTH_MODULE_REQ_DEBUG_LOG, (ULONG)stale_line, 0u, 0u);
    else
        (void)ModuleRequest(HEALTH_MODULE_REQ_DEBUG_LOG, (ULONG)ok_line, 0u, 0u);
}

void health_module_start(ULONG id)
{
    (void)id;
    (void)ModuleRequest(HEALTH_MODULE_REQ_DEBUG_LOG, HEALTH_MODULE_LOG_RUNNING, 0u, 0u);

    while (1)
    {
        ULONG speed_age;
        ULONG sensors_age;
        ULONG ultrasonic_age;
        ULONG dc_motor_age;
        ULONG servo_age;

        tx_thread_sleep(HEALTH_SAMPLE_PERIOD_TICKS);

        speed_age = (ULONG)ModuleRequest(HEALTH_MODULE_REQ_GET_SPEED_AGE_TICKS, 0u, 0u, 0u);
        sensors_age = (ULONG)ModuleRequest(HEALTH_MODULE_REQ_GET_SENSORS_AGE_TICKS, 0u, 0u, 0u);
        ultrasonic_age = (ULONG)ModuleRequest(HEALTH_MODULE_REQ_GET_ULTRASONIC_AGE_TICKS, 0u, 0u, 0u);
        dc_motor_age = (ULONG)ModuleRequest(HEALTH_MODULE_REQ_GET_DC_MOTOR_AGE_TICKS, 0u, 0u, 0u);
        servo_age = (ULONG)ModuleRequest(HEALTH_MODULE_REQ_GET_SERVO_AGE_TICKS, 0u, 0u, 0u);

        HealthLogLine("Health: speed OK\r\n", "Health: speed STALE\r\n", speed_age);
        HealthLogLine("Health: sensors OK\r\n", "Health: sensors STALE\r\n", sensors_age);
        HealthLogLine("Health: ultrasonic OK\r\n", "Health: ultrasonic STALE\r\n", ultrasonic_age);
        HealthLogLine("Health: dc_motor OK\r\n", "Health: dc_motor STALE\r\n", dc_motor_age);
        HealthLogLine("Health: servo OK\r\n", "Health: servo STALE\r\n", servo_age);
    }
}
