/**
 * @file servo_motor_module.c
 * @brief ThreadX module that applies servo angle commands from shared state.
 */

#include <stdint.h>
#include "tx_api.h"
#include "servo_motor_module_api.h"

#define SERVO_MOTOR_SAMPLE_PERIOD_TICKS 20u

extern UINT txm_module_application_request(ULONG request, ULONG p1, ULONG p2, ULONG p3);

/**
 * @brief Sends an application request from the servo motor module to the module manager.
 * @param request Request identifier defined in the servo motor module API.
 * @param p1 First request argument.
 * @param p2 Second request argument.
 * @param p3 Third request argument.
 * @return Module manager request status/result value.
 */
static UINT ModuleRequest(ULONG request, ULONG p1, ULONG p2, ULONG p3)
{
    return txm_module_application_request(request, p1, p2, p3);
}

/**
 * @brief Main entry point for the servo motor module execution loop.
 * @param id ThreadX module instance identifier (unused by this module).
 * @return None.
 */
void servo_motor_module_start(ULONG id)
{
    static ULONG       last_command_tick = 0u;
    static uint16_t    last_angle_deg = 0u;
    static UINT        initialized = 0u;

    (void)id;
    (void)ModuleRequest(SERVO_MOTOR_MODULE_REQ_DEBUG_LOG, SERVO_MOTOR_MODULE_LOG_RUNNING, 0u, 0u);

    ULONG       command_tick;
    uint16_t    angle_deg;

    while (1)
    {
        tx_thread_sleep(SERVO_MOTOR_SAMPLE_PERIOD_TICKS);

        if ((UINT)ModuleRequest(SERVO_MOTOR_MODULE_REQ_GET_COMMAND_VALID, 0u, 0u, 0u) == 0u)
            continue;

        command_tick = (ULONG)ModuleRequest(SERVO_MOTOR_MODULE_REQ_GET_COMMAND_TICK, 0u, 0u, 0u);
        if ((initialized != 0u) && (command_tick == last_command_tick))
            continue;

        angle_deg = (uint16_t)ModuleRequest(SERVO_MOTOR_MODULE_REQ_GET_ANGLE_DEG, 0u, 0u, 0u);
        (void)ModuleRequest(SERVO_MOTOR_MODULE_REQ_APPLY_ANGLE, (ULONG)angle_deg, 0u, 0u);

        last_command_tick = command_tick;
        last_angle_deg = angle_deg;
        initialized = 1u;
    }
}
