#include "app_threadx.h"
#include "speed_sensor_module_api.h"
#include "sensors_module_api.h"
#include "speed_sensor.h"
#include "sensors.h"

/*
 * Application-specific request dispatcher used by ThreadX modules.
 * This replaces the default TX_NOT_AVAILABLE stub in middleware.
 */
UINT _txm_module_manager_application_request(ULONG request_id, ALIGN_TYPE param_1, ALIGN_TYPE param_2, ALIGN_TYPE param_3)
{
    static UINT last_reported_gear = SPEED_SENSOR_MODULE_GEAR_NEUTRAL;
    static INT cached_hts_temp_x100 = 0;
    static INT cached_hts_hum_x100 = 0;
    static UINT cached_hts_valid = 0u;
    static ULONG cached_hts_tick = 0u;

    static INT cached_batt_mv = 0;
    static INT cached_batt_pct = 0;
    static UINT cached_batt_valid = 0u;
    static ULONG cached_batt_tick = 0u;

    t_can_message can_msg;
    (void)param_2;
    (void)param_3;

    /* Any successful callback from the module updates liveness heartbeat. */
    g_speed_module_last_tick = tx_time_get();

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

    case SPEED_SENSOR_MODULE_REQ_DEBUG_LOG:
    {
        UINT log_code = (UINT)param_1;

        if (log_code == SPEED_SENSOR_MODULE_LOG_RUNNING)
        {
            UartPrint("Speed sensor module is running\r\n");
            return TX_SUCCESS;
        }

        return TX_PTR_ERROR;
    }

    case SENSORS_MODULE_REQ_GET_TICKS:
        return (UINT)tx_time_get();

    case SENSORS_MODULE_REQ_GET_HTS221_TEMP_X100:
    {
        float temperature;
        float humidity;
        ULONG now = tx_time_get();

        if ((cached_hts_valid != 0u) && (cached_hts_tick == now))
        {
            return (UINT)cached_hts_temp_x100;
        }

        if (HTS221_ReadBoth(&hi2c2, &temperature, &humidity) != HAL_OK)
        {
            cached_hts_valid = 0u;
            return (UINT)SENSORS_MODULE_INVALID_SAMPLE;
        }

        cached_hts_temp_x100 = (INT)(temperature * 100.0f);
        cached_hts_hum_x100 = (INT)(humidity * 100.0f);
        cached_hts_valid = 1u;
        cached_hts_tick = now;
        return (UINT)cached_hts_temp_x100;
    }

    case SENSORS_MODULE_REQ_GET_HTS221_HUM_X100:
    {
        float temperature;
        float humidity;
        ULONG now = tx_time_get();

        if ((cached_hts_valid != 0u) && (cached_hts_tick == now))
        {
            return (UINT)cached_hts_hum_x100;
        }

        if (HTS221_ReadBoth(&hi2c2, &temperature, &humidity) != HAL_OK)
        {
            cached_hts_valid = 0u;
            return (UINT)SENSORS_MODULE_INVALID_SAMPLE;
        }

        cached_hts_temp_x100 = (INT)(temperature * 100.0f);
        cached_hts_hum_x100 = (INT)(humidity * 100.0f);
        cached_hts_valid = 1u;
        cached_hts_tick = now;
        return (UINT)cached_hts_hum_x100;
    }

    case SENSORS_MODULE_REQ_GET_BATTERY_MV:
    {
        float voltage;
        uint8_t percentage;
        ULONG now = tx_time_get();

        if ((cached_batt_valid != 0u) && (cached_batt_tick == now))
        {
            return (UINT)cached_batt_mv;
        }

        if (Battery_Read(&hi2c3, &voltage, &percentage) != HAL_OK)
        {
            cached_batt_valid = 0u;
            return (UINT)SENSORS_MODULE_INVALID_SAMPLE;
        }

        cached_batt_mv = (INT)(voltage * 1000.0f);
        cached_batt_pct = (INT)percentage;
        cached_batt_valid = 1u;
        cached_batt_tick = now;
        return (UINT)cached_batt_mv;
    }

    case SENSORS_MODULE_REQ_GET_BATTERY_PERCENT:
    {
        float voltage;
        uint8_t percentage;
        ULONG now = tx_time_get();

        if ((cached_batt_valid != 0u) && (cached_batt_tick == now))
        {
            return (UINT)cached_batt_pct;
        }

        if (Battery_Read(&hi2c3, &voltage, &percentage) != HAL_OK)
        {
            cached_batt_valid = 0u;
            return (UINT)SENSORS_MODULE_INVALID_SAMPLE;
        }

        cached_batt_mv = (INT)(voltage * 1000.0f);
        cached_batt_pct = (INT)percentage;
        cached_batt_valid = 1u;
        cached_batt_tick = now;
        return (UINT)cached_batt_pct;
    }

    case SENSORS_MODULE_REQ_PUBLISH_HTS221:
    {
        INT temp_x100 = (INT)param_1;
        INT hum_x100 = (INT)param_2;

        if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) != TX_SUCCESS)
        {
            return TX_MUTEX_ERROR;
        }

        g_hts221_data.temperature = ((float)temp_x100) / 100.0f;
        g_hts221_data.humidity = ((float)hum_x100) / 100.0f;
        g_hts221_data.timestamp = tx_time_get();
        g_hts221_data.data_valid = 1u;
        tx_mutex_put(&g_sensorDataMutex);
        tx_event_flags_set(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR);
        return TX_SUCCESS;
    }

    case SENSORS_MODULE_REQ_PUBLISH_BATTERY:
    {
        INT batt_mv = (INT)param_1;
        INT batt_pct = (INT)param_2;

        if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) != TX_SUCCESS)
        {
            return TX_MUTEX_ERROR;
        }

        g_battery_data.voltage = ((float)batt_mv) / 1000.0f;
        g_battery_data.percentage = (uint8_t)batt_pct;
        g_battery_data.timestamp = tx_time_get();
        g_battery_data.data_valid = 1u;
        tx_mutex_put(&g_sensorDataMutex);
        tx_event_flags_set(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR);
        return TX_SUCCESS;
    }

    case SENSORS_MODULE_REQ_SET_HTS221_INVALID:
        if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) != TX_SUCCESS)
        {
            return TX_MUTEX_ERROR;
        }
        g_hts221_data.data_valid = 0u;
        tx_mutex_put(&g_sensorDataMutex);
        tx_event_flags_set(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR);
        return TX_SUCCESS;

    case SENSORS_MODULE_REQ_SET_BATTERY_INVALID:
        if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) != TX_SUCCESS)
        {
            return TX_MUTEX_ERROR;
        }
        g_battery_data.data_valid = 0u;
        tx_mutex_put(&g_sensorDataMutex);
        tx_event_flags_set(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR);
        return TX_SUCCESS;

    case SENSORS_MODULE_REQ_DEBUG_LOG:
        if ((UINT)param_1 == SENSORS_MODULE_LOG_RUNNING)
        {
            UartPrint("Sensors module is running\r\n");
            return TX_SUCCESS;
        }
        return TX_PTR_ERROR;

    default:
        return TX_NOT_AVAILABLE;
    }
}
