#include "txm_module.h"
#include "sensors_module_api.h"

#define SENSORS_SAMPLE_PERIOD_TICKS      1000u
#define SENSORS_HEARTBEAT_INTERVAL_TICKS 3000u

static UINT ModuleRequest(ULONG request, ALIGN_TYPE p1, ALIGN_TYPE p2, ALIGN_TYPE p3)
{
    return txm_module_application_request(request, p1, p2, p3);
}

void sensors_module_start(ULONG id)
{
    static INT last_temp_x100 = 0;
    static INT last_hum_x100 = 0;
    static UINT hts_initialized = 0u;
    static ULONG last_hts_publish_tick = 0u;

    static INT last_batt_mv = 0;
    static INT last_batt_pct = 0;
    static UINT batt_initialized = 0u;
    static ULONG last_batt_publish_tick = 0u;

    TX_PARAMETER_NOT_USED(id);

    (void)ModuleRequest(SENSORS_MODULE_REQ_DEBUG_LOG, SENSORS_MODULE_LOG_RUNNING, 0u, 0u);

    while (1)
    {
        INT temp_x100;
        INT hum_x100;
        INT batt_mv;
        INT batt_pct;
        ULONG now;

        tx_thread_sleep(SENSORS_SAMPLE_PERIOD_TICKS);

        now = (ULONG)ModuleRequest(SENSORS_MODULE_REQ_GET_TICKS, 0u, 0u, 0u);

        temp_x100 = (INT)ModuleRequest(SENSORS_MODULE_REQ_GET_HTS221_TEMP_X100, 0u, 0u, 0u);
        hum_x100 = (INT)ModuleRequest(SENSORS_MODULE_REQ_GET_HTS221_HUM_X100, 0u, 0u, 0u);

        if ((UINT)temp_x100 == SENSORS_MODULE_INVALID_SAMPLE ||
            (UINT)hum_x100 == SENSORS_MODULE_INVALID_SAMPLE)
        {
            (void)ModuleRequest(SENSORS_MODULE_REQ_SET_HTS221_INVALID, 0u, 0u, 0u);
        }
        else if ((hts_initialized == 0u) ||
                 (temp_x100 != last_temp_x100) ||
                 (hum_x100 != last_hum_x100) ||
                 ((now - last_hts_publish_tick) >= SENSORS_HEARTBEAT_INTERVAL_TICKS))
        {
            (void)ModuleRequest(SENSORS_MODULE_REQ_PUBLISH_HTS221,
                                (ALIGN_TYPE)temp_x100,
                                (ALIGN_TYPE)hum_x100,
                                0u);
            last_temp_x100 = temp_x100;
            last_hum_x100 = hum_x100;
            last_hts_publish_tick = now;
            hts_initialized = 1u;
        }

        batt_mv = (INT)ModuleRequest(SENSORS_MODULE_REQ_GET_BATTERY_MV, 0u, 0u, 0u);
        batt_pct = (INT)ModuleRequest(SENSORS_MODULE_REQ_GET_BATTERY_PERCENT, 0u, 0u, 0u);

        if ((UINT)batt_mv == SENSORS_MODULE_INVALID_SAMPLE ||
            (UINT)batt_pct == SENSORS_MODULE_INVALID_SAMPLE)
        {
            (void)ModuleRequest(SENSORS_MODULE_REQ_SET_BATTERY_INVALID, 0u, 0u, 0u);
        }
        else if ((batt_initialized == 0u) ||
                 (batt_mv != last_batt_mv) ||
                 (batt_pct != last_batt_pct) ||
                 ((now - last_batt_publish_tick) >= SENSORS_HEARTBEAT_INTERVAL_TICKS))
        {
            (void)ModuleRequest(SENSORS_MODULE_REQ_PUBLISH_BATTERY,
                                (ALIGN_TYPE)batt_mv,
                                (ALIGN_TYPE)batt_pct,
                                0u);
            last_batt_mv = batt_mv;
            last_batt_pct = batt_pct;
            last_batt_publish_tick = now;
            batt_initialized = 1u;
        }
    }
}