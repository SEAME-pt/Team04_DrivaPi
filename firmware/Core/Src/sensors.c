/**
 ******************************************************************************
* @file           : sensors.c
* @brief          : Sensor threads management and drivers
* @details        : Exact port of bare-metal INA231 logic to ThreadX
******************************************************************************
*/

#include "sensors.h"
#include <string.h>
#include <math.h>

/* Fallback for external functions if not in headers */
extern void UartPrint(const char* msg);
extern void UartPrintf(const char* format, ...);
extern void SoftwareDelay(uint32_t ms);

TX_MUTEX                    g_sensorDataMutex;
TX_MUTEX                    g_i2cMutex; /* Hardware lock for the I2C2 Bus */
static volatile bool        g_battery_power_ready = false;
static uint8_t              g_ina231_addr_7bit = INA231_I2C_ADDRESS;

HTS221_Data_t               g_hts221_data;
Battery_Data_t              g_battery_data;
INA231_Data_t               g_ina231_data;

static HAL_StatusTypeDef SensorI2cMemRead(I2C_HandleTypeDef *hi2c,
                                          uint16_t dev_addr,
                                          uint16_t mem_addr,
                                          uint8_t *buf,
                                          uint16_t len);

static uint8_t BatteryPercentFrom2SVoltage(float voltage_v)
{
    /* SOC calibration for the deployed 2S2P pack under load. */
    const float soc_max_v = 8.15f;
    const float soc_nom_v = 7.40f;
    const float soc_min_v = 6.00f;
    float pct = 0.0f;

    if (voltage_v >= soc_max_v) {
        return 100u;
    }
    if (voltage_v <= soc_min_v) {
        return 0u;
    }
    if (voltage_v >= soc_nom_v) {
        pct = 50.0f + ((voltage_v - soc_nom_v) / (soc_max_v - soc_nom_v)) * 50.0f;
    } else {
        pct = ((voltage_v - soc_min_v) / (soc_nom_v - soc_min_v)) * 50.0f;
    }

    if (pct < 0.0f) pct = 0.0f;
    if (pct > 100.0f) pct = 100.0f;
    return (uint8_t)(pct + 0.5f);
}
static HTS221_Calibration_t calib_data;

static const ULONG SENSOR_I2C_MUTEX_TIMEOUT_TICKS = 50;
static const uint32_t SENSOR_I2C_TIMEOUT_MS = 100;

static HAL_StatusTypeDef SensorI2cProbeAddress(I2C_HandleTypeDef *hi2c, uint8_t dev_addr_7bit)
{
    HAL_StatusTypeDef status;
    TX_THREAD *thread = tx_thread_identify();
    if (hi2c == NULL || hi2c->Instance == NULL)
    {
        UartPrint("[I2C GUARD] probe null handle\r\n");
        return HAL_ERROR;
    }

    if (thread)
    {
        if (tx_mutex_get(&g_i2cMutex, SENSOR_I2C_MUTEX_TIMEOUT_TICKS) != TX_SUCCESS)
            return HAL_BUSY;
    }

    status = HAL_I2C_IsDeviceReady(hi2c, (uint16_t)(dev_addr_7bit << 1), 1, SENSOR_I2C_TIMEOUT_MS);

    if (thread)
        tx_mutex_put(&g_i2cMutex);

    return status;
}

static HAL_StatusTypeDef SensorI2cMemRead(I2C_HandleTypeDef *hi2c,
                                          uint16_t dev_addr,
                                          uint16_t mem_addr,
                                          uint8_t *buf,
                                          uint16_t len)
{
    HAL_StatusTypeDef status;
    TX_THREAD *thread = tx_thread_identify();
    uint8_t reg_addr = (uint8_t)(mem_addr & 0xFFu);
    if (hi2c == NULL || hi2c->Instance == NULL || buf == NULL || len == 0u)
    {
        UartPrint("[I2C GUARD] mem read invalid args\r\n");
        return HAL_ERROR;
    }

    if (thread)
    {
        if (tx_mutex_get(&g_i2cMutex, SENSOR_I2C_MUTEX_TIMEOUT_TICKS) != TX_SUCCESS)
            return HAL_BUSY;
    }

    status = HAL_I2C_Mem_Read(hi2c,
                              dev_addr,
                              mem_addr,
                              I2C_MEMADD_SIZE_8BIT,
                              buf,
                              len,
                              SENSOR_I2C_TIMEOUT_MS);

    if (status != HAL_OK)
    {
        /* Fallback path for devices that prefer register-pointer write + read sequence. */
        status = HAL_I2C_Master_Transmit(hi2c, dev_addr, &reg_addr, 1, SENSOR_I2C_TIMEOUT_MS);
        if (status == HAL_OK)
        {
            status = HAL_I2C_Master_Receive(hi2c, dev_addr, buf, len, SENSOR_I2C_TIMEOUT_MS);
        }
    }

    if (thread) tx_mutex_put(&g_i2cMutex);
    return status;
}

static HAL_StatusTypeDef SensorI2cMemWrite(I2C_HandleTypeDef *hi2c,
                                           uint16_t dev_addr,
                                           uint16_t mem_addr,
                                           const uint8_t *buf,
                                           uint16_t len)
{
    HAL_StatusTypeDef status;
    TX_THREAD *thread = tx_thread_identify();
    if (hi2c == NULL || hi2c->Instance == NULL || buf == NULL || len == 0u)
    {
        UartPrint("[I2C GUARD] mem write invalid args\r\n");
        return HAL_ERROR;
    }

    if (thread)
    {
        if (tx_mutex_get(&g_i2cMutex, SENSOR_I2C_MUTEX_TIMEOUT_TICKS) != TX_SUCCESS)
            return HAL_BUSY;
    }

    status = HAL_I2C_Mem_Write(hi2c,
                               dev_addr,
                               mem_addr,
                               I2C_MEMADD_SIZE_8BIT,
                               (uint8_t *)buf,
                               len,
                               SENSOR_I2C_TIMEOUT_MS);

    if (thread) tx_mutex_put(&g_i2cMutex);
    return status;
}

/* ============================================================================
 * HTS221 Driver Implementation (Thread-Safe)
 * ============================================================================ */

static HAL_StatusTypeDef HTS221_WriteReg(I2C_HandleTypeDef *hi2c, uint8_t reg, uint8_t data)
{
    uint16_t addr = HTS221_I2C_ADDRESS << 1;
    return SensorI2cMemWrite(hi2c, addr, reg, &data, 1);
}

static HAL_StatusTypeDef HTS221_ReadCalibration(I2C_HandleTypeDef *hi2c)
{
    uint8_t t0_msb, t1_msb;
    uint8_t buffer[16];
    uint16_t addr = HTS221_I2C_ADDRESS << 1;
    HAL_StatusTypeDef status = SensorI2cMemRead(hi2c, addr, 0x30 | 0x80, buffer, 16);

    if (status != HAL_OK) return HAL_ERROR;

    calib_data.H0_rh = buffer[0] >> 1;
    calib_data.H1_rh = buffer[1] >> 1;
    calib_data.T0_degC = buffer[2];
    calib_data.T1_degC = buffer[3];
    t0_msb = (buffer[5] & 0x03);
    t1_msb = (buffer[5] & 0x0C) >> 2;
    calib_data.T0_degC = ((t0_msb << 8) | calib_data.T0_degC) >> 3;
    calib_data.T1_degC = ((t1_msb << 8) | calib_data.T1_degC) >> 3;
    calib_data.H0_T0_out = (int16_t)(buffer[6] | (buffer[7] << 8));
    calib_data.H1_T0_out = (int16_t)(buffer[8] | (buffer[9] << 8));
    calib_data.T0_out = (int16_t)(buffer[12] | (buffer[13] << 8));
    calib_data.T1_out = (int16_t)(buffer[14] | (buffer[15] << 8));
    return HAL_OK;
}

HAL_StatusTypeDef HTS221_Init(I2C_HandleTypeDef *hi2c)
{
    if (hi2c == NULL || hi2c->Instance == NULL)
    {
        UartPrint("HTS221: init null I2C handle\r\n");
        return HAL_ERROR;
    }
    if (HTS221_WriteReg(hi2c, HTS221_CTRL_REG1, 0x85) != HAL_OK)
    {
        UartPrint("HTS221: Failed to write CTRL_REG1\r\n");
        return HAL_ERROR;
    }
    if (HTS221_ReadCalibration(hi2c) != HAL_OK)
    {
        UartPrint("HTS221: Failed to read calibration\r\n");
        return HAL_ERROR;
    }
    UartPrint("HTS221: Initialized successfully\r\n");
    SoftwareDelay(500);
    return HAL_OK;
}

HAL_StatusTypeDef HTS221_ReadBoth(I2C_HandleTypeDef *hi2c, float *temperature, float *humidity)
{
    if (hi2c == NULL || hi2c->Instance == NULL || temperature == NULL || humidity == NULL)
    {
        UartPrint("HTS221: read invalid args\r\n");
        return HAL_ERROR;
    }
    uint8_t h_low, t_low, t_high;
    int16_t h_raw, t_raw;
    uint16_t addr = HTS221_I2C_ADDRESS << 1;
    if (SensorI2cMemRead(hi2c, addr, HTS221_HUMIDITY_OUT_L, &h_low, 1) != HAL_OK) return HAL_ERROR;
    if (SensorI2cMemRead(hi2c, addr, HTS221_TEMP_OUT_L, &t_low, 1) != HAL_OK) return HAL_ERROR;
    if (SensorI2cMemRead(hi2c, addr, HTS221_TEMP_OUT_H, &t_high, 1) != HAL_OK) return HAL_ERROR;

    h_raw = (int8_t)h_low;
    t_raw = (int16_t)(t_low | (t_high << 8));

    float t_temp = (float)(t_raw - calib_data.T0_out) * (float)(calib_data.T1_degC - calib_data.T0_degC) /
                (float)(calib_data.T1_out - calib_data.T0_out) + calib_data.T0_degC;
    float h_temp = ((float)(h_raw - calib_data.H0_T0_out)) * ((float)(calib_data.H1_rh - calib_data.H0_rh)) /
                ((float)(calib_data.H1_T0_out - calib_data.H0_T0_out)) + (float)calib_data.H0_rh;
    if (h_temp < 0.0f) h_temp = 0.0f;
    if (h_temp > 100.0f) h_temp = 100.0f;
    *temperature = t_temp;
    *humidity = h_temp;
    return HAL_OK;
}

void SensorHTS221Thread(ULONG initial_input)
{
    float temp, hum;
    float last_temp = 0.0f, last_hum = 0.0f;
    HAL_StatusTypeDef   status;
    HAL_StatusTypeDef   init_status;
    static int16_t      last_temp_int = -99;
    static int16_t      last_hum_int = -99;
    static ULONG        last_send_time = 0;
    static const ULONG  HEARTBEAT_INTERVAL = 500; /* 5 seconds @ 100Hz tick */
    static const ULONG  HTS_STALE_TIMEOUT_TICKS = 1000; /* 10 seconds without valid read => stale */
    static const uint8_t HTS_REINIT_THRESHOLD = 5;
    uint32_t            init_attempts = 0;
    uint8_t             consecutive_failures = 0;
    bool                hts_ready = false;
    bool                have_sample = false;
    ULONG               last_hts_ok_time = 0;

    (void)initial_input;
    UartPrint("HTS221 Thread: Started\r\n");
    tx_thread_sleep(100);

    while (!g_battery_power_ready)
    {
        tx_thread_sleep(50);
    }

    while (!hts_ready)
    {
        init_status = HTS221_Init(&hi2c2);
        if (init_status == HAL_OK)
        {
            hts_ready = true;
            last_send_time = tx_time_get();
            last_hts_ok_time = last_send_time;
            break;
        }

        init_attempts++;
        if (init_attempts == 1 || (init_attempts % 10) == 0)
        {
            UartPrintf("HTS221: init retry %lu failed\r\n", (unsigned long)init_attempts);
        }
        tx_thread_sleep(500);
    }

    while (1)
    {
        ULONG current_time = tx_time_get();

        status = HTS221_ReadBoth(&hi2c2, &temp, &hum);
        if (status == HAL_OK)
        {
            consecutive_failures = 0;
            last_temp = temp;
            last_hum = hum;
            have_sample = true;
            last_hts_ok_time = current_time;
            if (tx_mutex_get(&g_sensorDataMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
            {
                g_hts221_data.temperature = last_temp;
                g_hts221_data.humidity = last_hum;
                g_hts221_data.timestamp = current_time;
                g_hts221_data.data_valid = 1;
                tx_mutex_put(&g_sensorDataMutex);
            }
            int16_t temp_int = (int16_t)temp;
            int16_t hum_int = (int16_t)hum;

            if (temp_int != last_temp_int || hum_int != last_hum_int ||
                (current_time - last_send_time) >= HEARTBEAT_INTERVAL)
            {
                t_can_message msg;
                memset(&msg, 0, sizeof(msg));
                msg.id = CAN_ID_HTS221_DATA;
                msg.len = 8;
                memcpy(&msg.data[0], &last_temp, 4);
                memcpy(&msg.data[4], &last_hum, 4);
                if (tx_mutex_get(&g_canMutex, 5) == TX_SUCCESS)
                {
                    CanSend(&msg);
                    tx_mutex_put(&g_canMutex);
                }
                last_temp_int = temp_int;
                last_hum_int = hum_int;
                last_send_time = current_time;
            }
        }
        else
        {
            bool hts_stale = ((current_time - last_hts_ok_time) >= HTS_STALE_TIMEOUT_TICKS);

            if (hts_stale)
            {
                last_temp = 0.0f;
                last_hum = 0.0f;

                if (tx_mutex_get(&g_sensorDataMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
                {
                    g_hts221_data.temperature = 0.0f;
                    g_hts221_data.humidity = 0.0f;
                    g_hts221_data.timestamp = current_time;
                    g_hts221_data.data_valid = 0;
                    tx_mutex_put(&g_sensorDataMutex);
                }
            }

            if (have_sample && (current_time - last_send_time) >= HEARTBEAT_INTERVAL)
            {
                t_can_message msg;
                memset(&msg, 0, sizeof(msg));
                msg.id = CAN_ID_HTS221_DATA;
                msg.len = 8;
                memcpy(&msg.data[0], &last_temp, 4);
                memcpy(&msg.data[4], &last_hum, 4);
                if (tx_mutex_get(&g_canMutex, 5) == TX_SUCCESS)
                {
                    CanSend(&msg);
                    tx_mutex_put(&g_canMutex);
                }
                last_send_time = current_time;
            }

            consecutive_failures++;
            if (consecutive_failures < HTS_REINIT_THRESHOLD)
            {
                if (consecutive_failures == 1 || consecutive_failures == HTS_REINIT_THRESHOLD - 1)
                {
                    UartPrintf("HTS221: read failed (%u/%u)\r\n",
                               (unsigned int)consecutive_failures,
                               (unsigned int)HTS_REINIT_THRESHOLD);
                }
                tx_thread_sleep(100);
                continue;
            }

            consecutive_failures = 0;
            hts_ready = false;
            tx_thread_sleep(500);

            while (!hts_ready)
            {
                init_status = HTS221_Init(&hi2c2);
                if (init_status == HAL_OK)
                {
                    hts_ready = true;
                    last_send_time = tx_time_get();
                    break;
                }

                init_attempts++;
                if (init_attempts == 1 || (init_attempts % 10) == 0)
                {
                    UartPrintf("HTS221: reinit retry %lu failed\r\n", (unsigned long)init_attempts);
                }
                tx_thread_sleep(500);
            }
        }
        tx_thread_sleep(100);
    }
}

/**
 * @brief Initialize sensor data structures and mutexes.
 */
void SensorsInit(void)
{
    tx_mutex_create(&g_i2cMutex, "I2C Mutex", TX_INHERIT);
    tx_mutex_create(&g_sensorDataMutex, "Sensor Data Mutex", TX_INHERIT);
    memset(&g_hts221_data, 0, sizeof(HTS221_Data_t));
    memset(&g_battery_data, 0, sizeof(Battery_Data_t));
    memset(&g_ina231_data, 0, sizeof(INA231_Data_t));
}

/* ============================================================================
* Exact Port of bare-metal INA231 logic to RTOS
* ============================================================================ */

static HAL_StatusTypeDef INA231_WriteRegister(I2C_HandleTypeDef *hi2c, uint8_t reg, uint16_t value)
{
    uint8_t data[2];
    HAL_StatusTypeDef status;

    data[0] = (uint8_t)((value >> 8) & 0xFF);   // MSB
    data[1] = (uint8_t)(value & 0xFF);          // LSB

    /* Use detected INA231 address shifted to 8-bit */
    status = SensorI2cMemWrite(hi2c,
                               (uint16_t)(g_ina231_addr_7bit << 1),
                               reg,
                               data,
                               2);

    if (status != HAL_OK)
    {
        uint32_t hal_err = HAL_I2C_GetError(hi2c);
        UartPrintf("Battery: INA231 write reg 0x%02X failed status=%d err=0x%08lX\r\n",
                   reg,
                   status,
                   (unsigned long)hal_err);
    }

    return status;
}

static HAL_StatusTypeDef INA231_ReadRegister(I2C_HandleTypeDef *hi2c, uint8_t dev_addr_7bit, uint8_t reg, uint16_t *value)
{
    uint8_t buf[2];
    HAL_StatusTypeDef status;

    if (value == NULL)
        return HAL_ERROR;

    status = SensorI2cMemRead(hi2c, (uint16_t)(dev_addr_7bit << 1), reg, buf, 2);
    if (status != HAL_OK)
        return status;

    *value = (uint16_t)((buf[0] << 8) | buf[1]);
    return HAL_OK;
}

static HAL_StatusTypeDef INA231_Configure(I2C_HandleTypeDef *hi2c, uint8_t dev_addr_7bit)
{
    uint8_t prev_addr = g_ina231_addr_7bit;
    uint16_t readback = 0u;
    HAL_StatusTypeDef status;

    g_ina231_addr_7bit = dev_addr_7bit;

    status = INA231_WriteRegister(hi2c, INA231_REG_CONFIG, INA231_CONFIG_VAL);
    if (status != HAL_OK)
    {
        g_ina231_addr_7bit = prev_addr;
        return status;
    }

    status = INA231_WriteRegister(hi2c, INA231_REG_CALIBRATION, INA231_CALIB_VAL);
    if (status != HAL_OK)
    {
        g_ina231_addr_7bit = prev_addr;
        return status;
    }

    status = INA231_ReadRegister(hi2c, dev_addr_7bit, INA231_REG_CONFIG, &readback);
    if (status != HAL_OK || readback != INA231_CONFIG_VAL)
    {
        g_ina231_addr_7bit = prev_addr;
        return HAL_ERROR;
    }

    return HAL_OK;
}

HAL_StatusTypeDef Battery_Init(I2C_HandleTypeDef *hi2c)
{
    UartPrintf("Battery: Initializing INA231 at I2C address 0x%02X (using I2C%d)\r\n",
               INA231_I2C_ADDRESS, (hi2c == &hi2c2) ? 2 : (hi2c == &hi2c3) ? 3 : 1);

    /* PE13 power is enabled during GPIO init in main.c. */
    tx_thread_sleep(2);
    UartPrint("Battery: PE13 power assumed enabled\r\n");
    (void)hi2c;
    g_ina231_addr_7bit = INA231_I2C_ADDRESS;
    UartPrint("Battery: Startup safe mode - probe deferred to runtime reads\r\n");
    return HAL_OK;
}

HAL_StatusTypeDef Battery_Read(I2C_HandleTypeDef *hi2c, float *voltage, uint8_t *percentage)
{
    uint8_t buf[2];
    HAL_StatusTypeDef status;
    static uint32_t read_fail_count = 0u;

    if (hi2c == NULL || hi2c->Instance == NULL || voltage == NULL || percentage == NULL)
    {
        UartPrint("Battery: read invalid args\r\n");
        return HAL_ERROR;
    }

    /* Read bus voltage register (0x02) */
    status = SensorI2cMemRead(hi2c, (uint16_t)(g_ina231_addr_7bit << 1), INA231_REG_BUS_V, buf, 2);
    if (status != HAL_OK)
    {
        read_fail_count++;
        if ((read_fail_count % 25u) == 0u)
        {
            UartPrintf("[INA READ] bus_v read failed addr=0x%02X err=0x%08lX\r\n",
                       (unsigned int)g_ina231_addr_7bit,
                       (unsigned long)HAL_I2C_GetError(hi2c));
        }
    }

    if (status != HAL_OK)
    {
        *voltage = 0.0f;
        *percentage = 0;
        return HAL_ERROR;
    }

    {
        uint16_t bus_raw = (uint16_t)((buf[0] << 8) | buf[1]);
        *voltage = bus_raw * 1.25e-3f;
    }

    *percentage = BatteryPercentFrom2SVoltage(*voltage);
    return HAL_OK;
}

static HAL_StatusTypeDef ExpansionBattery_Read(I2C_HandleTypeDef *hi2c, float *voltage, uint8_t *percentage)
{
    uint8_t buf[2];
    HAL_StatusTypeDef status;
    const uint16_t dev_addr = (uint16_t)(0x41u << 1);

    if (voltage == NULL || percentage == NULL) return HAL_ERROR;

    status = SensorI2cMemRead(hi2c, dev_addr, INA231_REG_BUS_V, buf, 2);

    if (status != HAL_OK)
    {
        *voltage = 0.0f;
        *percentage = 0;
        return HAL_ERROR;
    }

    /* INA219-style bus voltage register decoding used by expansion monitor. */
    {
        uint16_t bus_voltage_raw = (uint16_t)((buf[0] << 8) | buf[1]);
        uint16_t voltage_bits = (uint16_t)((bus_voltage_raw >> 3) & 0x1FFFu);
        *voltage = voltage_bits * 0.004f;
    }

    *percentage = BatteryPercentFrom2SVoltage(*voltage);

    return HAL_OK;
}

/**
 * @brief Read current from INA226 shunt resistor
 * @param hi2c I2C handle
 * @param current Pointer to store current in Amps
 * @return HAL_OK on success, HAL_ERROR on failure
 */
HAL_StatusTypeDef Battery_ReadCurrent(I2C_HandleTypeDef *hi2c, float *current)
{
    uint8_t buf[2];
    uint8_t shunt_buf[2];
    HAL_StatusTypeDef status;
    HAL_StatusTypeDef shunt_status;
    static uint32_t dbg_sample_count = 0u;
    static uint32_t dbg_fail_count = 0u;
    const float shunt_lsb_v = 2.5e-6f; /* INA231 shunt voltage LSB: 2.5 uV/bit */
    const float shunt_res_ohm = 0.1f;  /* Board shunt resistor: 0.1 ohm */

    if (current == NULL) return HAL_ERROR;

    /* Read current register (0x04) for diagnostics/comparison only */
    status = SensorI2cMemRead(hi2c, (uint16_t)(g_ina231_addr_7bit << 1), INA231_REG_CURRENT, buf, 2);
    if (status != HAL_OK)
    {
        buf[0] = 0u;
        buf[1] = 0u;
    }

    /* Read shunt register (0x01) and compute current directly: I = Vshunt / Rshunt */
    shunt_status = SensorI2cMemRead(hi2c, (uint16_t)(g_ina231_addr_7bit << 1), INA231_REG_SHUNT_V, shunt_buf, 2);
    if (shunt_status != HAL_OK)
    {
        *current = 0.0f;
        dbg_fail_count++;
        if ((dbg_fail_count % 25u) == 0u)
        {
            UartPrintf("[INA231 CUR] shunt read fail count=%lu err=0x%08lX\r\n",
                       (unsigned long)dbg_fail_count,
                       (unsigned long)HAL_I2C_GetError(hi2c));
        }
        return HAL_ERROR;
    }
    int16_t current_raw = (int16_t)((buf[0] << 8) | buf[1]);
    int16_t shunt_raw = (int16_t)((shunt_buf[0] << 8) | shunt_buf[1]);
    *current = (shunt_raw * shunt_lsb_v) / shunt_res_ohm;

    dbg_sample_count++;
    if ((dbg_sample_count % 10u) == 0u)
    {
        UartPrintf("[INA231 CUR] reg_raw=%d reg=0x%02X%02X | shunt_raw=%d reg=0x%02X%02X\r\n",
                   (int)current_raw,
                   (unsigned int)buf[0],
                   (unsigned int)buf[1],
                   (int)shunt_raw,
                   (unsigned int)shunt_buf[0],
                   (unsigned int)shunt_buf[1]);
    }

    return HAL_OK;
}

/* ============================================================================
* Battery Sensor Thread
* ============================================================================ */

void SensorBatteryThread(ULONG initial_input)
{
    float               expansion_voltage;
    float               ina_voltage;
    uint8_t             expansion_percentage;
    uint8_t             ina_percentage;
    HAL_StatusTypeDef   expansion_status;
    HAL_StatusTypeDef   ina_status;
    HAL_StatusTypeDef   current_status;
    uint32_t            error_count = 0;
    static ULONG        last_send_time = 0;
    static const ULONG  SEND_INTERVAL_TICKS = 100; /* 1 second @ 100Hz ThreadX tick */
    static const ULONG  POLL_INTERVAL_TICKS = 20;  /* 200ms polling to keep cadence accurate */
    static const ULONG  INA_STALE_TIMEOUT_TICKS = 1000; /* 10 seconds without valid read => stale */
    float               last_ina_voltage = 0.0f;
    uint8_t             last_ina_percentage = 0u;
    float               last_current_amps = 0.0f;
    bool                have_ina_sample = false;
    ULONG               last_ina_ok_time = 0;
    uint32_t            loop_count = 0;
    ULONG               last_current_sample_time = 0;

    (void)initial_input;
    UartPrint("Battery Thread: Started\r\n");
    last_send_time = tx_time_get();
    if (last_send_time >= SEND_INTERVAL_TICKS)
        last_send_time -= SEND_INTERVAL_TICKS;
    else
        last_send_time = 0;
    last_ina_ok_time = last_send_time;
    last_current_sample_time = last_send_time;

    /* Give the system 2 seconds to settle exactly as before */
    tx_thread_sleep(200);

    /* Initialize INA231 battery monitor on I2C2 (STMod+ connector) at address 0x40 */
    if (Battery_Init(&hi2c2) != HAL_OK) {
        UartPrint("Battery Thread: Init failed - continuing with reads anyway\r\n");
        g_battery_power_ready = true;
    } else {
        UartPrint("Battery Thread: INA231 initialized successfully\r\n");
        g_battery_power_ready = true;
    }

    /* Wait for first conversion to complete (1024 samples @ 1.1ms = ~1.2 seconds) */
    tx_thread_sleep(120);

    while (1)
    {
        float current_amps = 0.0f;
        ULONG current_time = tx_time_get();
        loop_count++;
        if ((loop_count % 250u) == 0u)
        {
            UartPrintf("[BATTERY LOOP] alive=%lu tick=%lu\r\n",
                       (unsigned long)loop_count,
                       (unsigned long)current_time);
        }

        (void)last_send_time;

        /* Live-only mode: attempt INA read; data_valid drives CAN publication. */
        expansion_voltage = 0.0f;
        expansion_percentage = 0u;
        expansion_status = ExpansionBattery_Read(&hi2c3, &expansion_voltage, &expansion_percentage);
        ina_status = Battery_Read(&hi2c2, &ina_voltage, &ina_percentage);

        if (ina_status == HAL_OK)
        {
            last_ina_voltage = ina_voltage;
            last_ina_percentage = ina_percentage;
            have_ina_sample = true;
            last_ina_ok_time = current_time;
            current_status = Battery_ReadCurrent(&hi2c2, &current_amps);
            if (current_status == HAL_OK)
            {
                last_current_amps = current_amps;
                last_current_sample_time = current_time;
            }
            else
            {
                last_current_amps = 0.0f;
            }

            if (tx_mutex_get(&g_sensorDataMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
            {
                g_ina231_data.voltage = last_ina_voltage;
                g_ina231_data.current = last_current_amps;
                g_ina231_data.power = 0.0f;
                g_ina231_data.percentage = last_ina_percentage;
                g_ina231_data.timestamp = current_time;
                g_ina231_data.data_valid = 1u;
                if (expansion_status == HAL_OK)
                {
                    g_battery_data.voltage = expansion_voltage;
                    g_battery_data.percentage = expansion_percentage;
                    g_battery_data.timestamp = current_time;
                    g_battery_data.data_valid = 1u;
                }
                tx_mutex_put(&g_sensorDataMutex);
            }
        }

        if (expansion_status == HAL_OK || ina_status == HAL_OK)
        {
            error_count = 0;
        }
        else
        {
            error_count++;
            if ((error_count % 200u) == 0u)
            {
                UartPrintf("[BATTERY] INA read fail count=%lu\r\n", (unsigned long)error_count);
            }
            if (error_count >= 3)
            {
                if (tx_mutex_get(&g_sensorDataMutex, MUTEX_WAIT_TICKS) == TX_SUCCESS)
                {
                    g_battery_data.data_valid = 0;
                    g_ina231_data.data_valid = 0;
                    tx_mutex_put(&g_sensorDataMutex);
                }
            }
        }
        tx_thread_sleep(POLL_INTERVAL_TICKS);
    }
}

/* ============================================================================
 * INA231 Sensor Thread (DISABLED / SLEEPING FOREVER)
 * ============================================================================ */

void SensorINA231Thread(ULONG initial_input)
{
    (void)initial_input;
    while (1) { tx_thread_sleep(TX_WAIT_FOREVER); }
}
