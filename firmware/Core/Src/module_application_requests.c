#include "app_threadx.h"
#include "speed_sensor_module_api.h"
#include "speed_sensor.h"

/*
 * Application-specific request dispatcher used by ThreadX modules.
 * This replaces the default TX_NOT_AVAILABLE stub in middleware.
 */
UINT _txm_module_manager_application_request(ULONG request_id, ALIGN_TYPE param_1, ALIGN_TYPE param_2, ALIGN_TYPE param_3)
{
    static UINT last_reported_gear = SPEED_SENSOR_MODULE_GEAR_NEUTRAL;
    t_can_message can_msg;
    (void)param_2;
    (void)param_3;

    switch (request_id)
    {
    case SPEED_SENSOR_MODULE_REQ_GET_ENCODER_COUNT:
        return (UINT)(htim1.Instance->CNT);

    case SPEED_SENSOR_MODULE_REQ_GET_TICKS:
        return (UINT)tx_time_get();

    case SPEED_SENSOR_MODULE_REQ_GET_PWM:
        tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
        {
            INT pwm = (INT)g_current_pwm;
            tx_mutex_put(&g_speedDataMutex);
            return (UINT)pwm;
        }

    case SPEED_SENSOR_MODULE_REQ_PUBLISH_SPEED_MMPS:
    {
        INT speed_mmps = (INT)param_1;
        float speed_mps = ((float)speed_mmps) / 1000.0f;

        tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
        g_vehicleSpeed = speed_mps;
        g_current_speed = speed_mps;
        tx_mutex_put(&g_speedDataMutex);

        tx_event_flags_set(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR);
        return TX_SUCCESS;
    }

    case SPEED_SENSOR_MODULE_REQ_PUBLISH_GEAR:
    {
        UINT requested_gear = (UINT)param_1;

        if (requested_gear > SPEED_SENSOR_MODULE_GEAR_DRIVE)
        {
            return TX_PTR_ERROR;
        }

        tx_mutex_get(&g_gearMutex, TX_WAIT_FOREVER);
        g_current_gear = (RNDGear_t)requested_gear;
        tx_mutex_put(&g_gearMutex);

        if (requested_gear != last_reported_gear)
        {
            memset(&can_msg, 0, sizeof(can_msg));
            can_msg.id = CAN_ID_RND_GEAR;
            can_msg.len = 1;
            can_msg.data[0] = (uint8_t)requested_gear;
            (void)CanSend(&can_msg);
            last_reported_gear = requested_gear;
        }

        return TX_SUCCESS;
    }

    default:
        return TX_NOT_AVAILABLE;
    }
}
