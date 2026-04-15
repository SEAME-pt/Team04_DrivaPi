#include <stdint.h>
#include "tx_api.h"
#include "dc_motor_module_api.h"

#define DC_MOTOR_SAMPLE_PERIOD_TICKS 20u

extern UINT txm_module_application_request(ULONG request, ULONG p1, ULONG p2, ULONG p3);

static UINT ModuleRequest(ULONG request, ULONG p1, ULONG p2, ULONG p3)
{
    return txm_module_application_request(request, p1, p2, p3);
}

void dc_motor_module_start(ULONG id)
{
    static ULONG    last_command_tick = 0u;
    static int32_t  last_left_counts = 0;
    static int32_t  last_right_counts = 0;
    static UINT     initialized = 0u;

    (void)id;
    (void)ModuleRequest(DC_MOTOR_MODULE_REQ_DEBUG_LOG, DC_MOTOR_MODULE_LOG_RUNNING, 0u, 0u);
    ULONG   command_tick;
    int32_t left_counts;
    int32_t right_counts;

    while (1)
    {
        tx_thread_sleep(DC_MOTOR_SAMPLE_PERIOD_TICKS);

        if ((UINT)ModuleRequest(DC_MOTOR_MODULE_REQ_GET_COMMAND_VALID, 0u, 0u, 0u) == 0u)
            continue;

        command_tick = (ULONG)ModuleRequest(DC_MOTOR_MODULE_REQ_GET_COMMAND_TICK, 0u, 0u, 0u);
        if ((initialized != 0u) && (command_tick == last_command_tick))
            continue;

        left_counts = (int32_t)ModuleRequest(DC_MOTOR_MODULE_REQ_GET_LEFT_COUNTS, 0u, 0u, 0u);
        right_counts = (int32_t)ModuleRequest(DC_MOTOR_MODULE_REQ_GET_RIGHT_COUNTS, 0u, 0u, 0u);

        (void)ModuleRequest(DC_MOTOR_MODULE_REQ_APPLY_PWM, (ULONG)left_counts,
            (ULONG)right_counts, 0u);

        last_command_tick = command_tick;
        last_left_counts = left_counts;
        last_right_counts = right_counts;
        initialized = 1u;
    }
}
