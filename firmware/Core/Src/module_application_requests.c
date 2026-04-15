#include "app_threadx.h"
#include "speed_sensor_module_api.h"
#include "sensors_module_api.h"
#include "ultrasonic_module_api.h"
#include "dc_motor_module_api.h"
#include "servo_motor_module_api.h"
#include "health_module_api.h"
#include "speed_sensor.h"
#include "sensors.h"
#include "ultrasonic.h"
#include "dc_motor.h"
#include "servo_motor.h"

static VOID TouchHeartbeat(ULONG *tick_ptr)
{
    if (tick_ptr != TX_NULL)
    {
        *tick_ptr = tx_time_get();
    }
}

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

    switch (request_id)
    {
    case SPEED_SENSOR_MODULE_REQ_GET_ENCODER_COUNT:
        TouchHeartbeat(&g_speed_module_last_tick);
        return (UINT)(htim1.Instance->CNT);

    case SPEED_SENSOR_MODULE_REQ_GET_TICKS:
        TouchHeartbeat(&g_speed_module_last_tick);
        return (UINT)tx_time_get();

    case SPEED_SENSOR_MODULE_REQ_GET_PWM:
        TouchHeartbeat(&g_speed_module_last_tick);
        tx_mutex_get(&g_speedDataMutex, TX_WAIT_FOREVER);
        {
            INT pwm = (INT)g_current_pwm;
            tx_mutex_put(&g_speedDataMutex);
            return (UINT)pwm;
        }

    case SPEED_SENSOR_MODULE_REQ_PUBLISH_SPEED_MMPS:
        TouchHeartbeat(&g_speed_module_last_tick);
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
        TouchHeartbeat(&g_speed_module_last_tick);
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
        TouchHeartbeat(&g_speed_module_last_tick);
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
        TouchHeartbeat(&g_sensors_module_last_tick);
        return (UINT)tx_time_get();

    case SENSORS_MODULE_REQ_GET_HTS221_TEMP_X100:
        TouchHeartbeat(&g_sensors_module_last_tick);
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
        TouchHeartbeat(&g_sensors_module_last_tick);
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
        TouchHeartbeat(&g_sensors_module_last_tick);
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
        TouchHeartbeat(&g_sensors_module_last_tick);
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
        TouchHeartbeat(&g_sensors_module_last_tick);
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
        TouchHeartbeat(&g_sensors_module_last_tick);
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
        TouchHeartbeat(&g_sensors_module_last_tick);
        if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) != TX_SUCCESS)
        {
            return TX_MUTEX_ERROR;
        }
        g_hts221_data.data_valid = 0u;
        tx_mutex_put(&g_sensorDataMutex);
        tx_event_flags_set(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR);
        return TX_SUCCESS;

    case SENSORS_MODULE_REQ_SET_BATTERY_INVALID:
        TouchHeartbeat(&g_sensors_module_last_tick);
        if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) != TX_SUCCESS)
        {
            return TX_MUTEX_ERROR;
        }
        g_battery_data.data_valid = 0u;
        tx_mutex_put(&g_sensorDataMutex);
        tx_event_flags_set(&g_eventFlags, FLAG_SENSOR_UPDATE, TX_OR);
        return TX_SUCCESS;

    case SENSORS_MODULE_REQ_DEBUG_LOG:
        TouchHeartbeat(&g_sensors_module_last_tick);
        if ((UINT)param_1 == SENSORS_MODULE_LOG_RUNNING)
        {
            UartPrint("Sensors module is running\r\n");
            return TX_SUCCESS;
        }
        return TX_PTR_ERROR;

    case ULTRASONIC_MODULE_REQ_INIT:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        return (UltrasonicModuleInit() == HAL_OK) ? TX_SUCCESS : TX_PTR_ERROR;

    case ULTRASONIC_MODULE_REQ_GET_TICKS:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        return (UINT)tx_time_get();

    case ULTRASONIC_MODULE_REQ_GET_RANGE_CM:
    {
        int16_t range_cm = 0;

        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        if (UltrasonicReadRangeCm(&range_cm) != HAL_OK)
        {
            return (UINT)ULTRASONIC_MODULE_INVALID_SAMPLE;
        }

        return (UINT)range_cm;
    }

    case ULTRASONIC_MODULE_REQ_GET_CURRENT_SPEED_MMPS:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        return (UINT)((INT)(g_vehicleSpeed * 1000.0f));

    case ULTRASONIC_MODULE_REQ_GET_CURRENT_GEAR:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        return (UINT)g_current_gear;

    case ULTRASONIC_MODULE_REQ_SET_EMERGENCY_BRAKE:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
        g_emergencyBrake = true;
        tx_mutex_put(&g_emergencyMutex);
        return TX_SUCCESS;

    case ULTRASONIC_MODULE_REQ_CLEAR_EMERGENCY_BRAKE:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        tx_mutex_get(&g_emergencyMutex, TX_WAIT_FOREVER);
        g_emergencyBrake = false;
        tx_mutex_put(&g_emergencyMutex);
        return TX_SUCCESS;

    case ULTRASONIC_MODULE_REQ_MOTOR_STOP:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
        MotorSetPWM(0, 0);
        tx_mutex_put(&g_motorMutex);
        return TX_SUCCESS;

    case ULTRASONIC_MODULE_REQ_MOTOR_BACKSPIN:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
        MotorSetPWM(-4096, -4096);
        tx_mutex_put(&g_motorMutex);
        return TX_SUCCESS;

    case ULTRASONIC_MODULE_REQ_DEBUG_LOG:
        TouchHeartbeat(&g_ultrasonic_module_last_tick);
        if ((UINT)param_1 == ULTRASONIC_MODULE_LOG_RUNNING)
        {
            UartPrint("Ultrasonic module is running\r\n");
            return TX_SUCCESS;
        }
        return TX_PTR_ERROR;

    case DC_MOTOR_MODULE_REQ_GET_COMMAND_TICK:
        TouchHeartbeat(&g_dc_motor_module_last_tick);
        return (UINT)g_latest_speed_command_tick;

    case DC_MOTOR_MODULE_REQ_GET_COMMAND_VALID:
        TouchHeartbeat(&g_dc_motor_module_last_tick);
        return g_latest_speed_command_valid;

    case DC_MOTOR_MODULE_REQ_GET_LEFT_COUNTS:
        TouchHeartbeat(&g_dc_motor_module_last_tick);
        return (UINT)g_latest_speed_command_left;

    case DC_MOTOR_MODULE_REQ_GET_RIGHT_COUNTS:
        TouchHeartbeat(&g_dc_motor_module_last_tick);
        return (UINT)g_latest_speed_command_right;

    case DC_MOTOR_MODULE_REQ_APPLY_PWM:
        TouchHeartbeat(&g_dc_motor_module_last_tick);
        tx_mutex_get(&g_motorMutex, TX_WAIT_FOREVER);
        MotorSetPWM((int32_t)param_1, (int32_t)param_2);
        tx_mutex_put(&g_motorMutex);
        return TX_SUCCESS;

    case DC_MOTOR_MODULE_REQ_DEBUG_LOG:
        TouchHeartbeat(&g_dc_motor_module_last_tick);
        if ((UINT)param_1 == DC_MOTOR_MODULE_LOG_RUNNING)
        {
            UartPrint("DC motor module is running\r\n");
            return TX_SUCCESS;
        }
        return TX_PTR_ERROR;

    case SERVO_MOTOR_MODULE_REQ_GET_COMMAND_TICK:
        TouchHeartbeat(&g_servo_module_last_tick);
        return (UINT)g_latest_servo_command_tick;

    case SERVO_MOTOR_MODULE_REQ_GET_COMMAND_VALID:
        TouchHeartbeat(&g_servo_module_last_tick);
        return g_latest_servo_command_valid;

    case SERVO_MOTOR_MODULE_REQ_GET_ANGLE_DEG:
        TouchHeartbeat(&g_servo_module_last_tick);
        return (UINT)g_latest_servo_command_angle;

    case SERVO_MOTOR_MODULE_REQ_APPLY_ANGLE:
        TouchHeartbeat(&g_servo_module_last_tick);
        tx_mutex_get(&g_servoMutex, TX_WAIT_FOREVER);
        (void)SetServoAngle(SERVO_CH, (uint16_t)param_1);
        tx_mutex_put(&g_servoMutex);
        return TX_SUCCESS;

    case SERVO_MOTOR_MODULE_REQ_DEBUG_LOG:
        TouchHeartbeat(&g_servo_module_last_tick);
        if ((UINT)param_1 == SERVO_MOTOR_MODULE_LOG_RUNNING)
        {
            UartPrint("Servo module is running\r\n");
            return TX_SUCCESS;
        }
        return TX_PTR_ERROR;

    case HEALTH_MODULE_REQ_GET_SPEED_AGE_TICKS:
        TouchHeartbeat(&g_health_module_last_tick);
        return (UINT)(tx_time_get() - g_speed_module_last_tick);

    case HEALTH_MODULE_REQ_GET_SENSORS_AGE_TICKS:
        TouchHeartbeat(&g_health_module_last_tick);
        return (UINT)(tx_time_get() - g_sensors_module_last_tick);

    case HEALTH_MODULE_REQ_GET_ULTRASONIC_AGE_TICKS:
        TouchHeartbeat(&g_health_module_last_tick);
        return (UINT)(tx_time_get() - g_ultrasonic_module_last_tick);

    case HEALTH_MODULE_REQ_GET_DC_MOTOR_AGE_TICKS:
        TouchHeartbeat(&g_health_module_last_tick);
        return (UINT)(tx_time_get() - g_dc_motor_module_last_tick);

    case HEALTH_MODULE_REQ_GET_SERVO_AGE_TICKS:
        TouchHeartbeat(&g_health_module_last_tick);
        return (UINT)(tx_time_get() - g_servo_module_last_tick);

    case HEALTH_MODULE_REQ_DEBUG_LOG:
        TouchHeartbeat(&g_health_module_last_tick);
        if ((UINT)param_1 == HEALTH_MODULE_LOG_RUNNING)
        {
            UartPrint("Health module is running\r\n");
            return TX_SUCCESS;
        }
        if (param_1 != 0u)
        {
            UartPrint((const CHAR *)param_1);
            return TX_SUCCESS;
        }
        return TX_PTR_ERROR;

    default:
        return TX_NOT_AVAILABLE;
    }
}
