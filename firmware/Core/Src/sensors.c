/**
  ******************************************************************************
  * @file           : sensors.c
  * @brief          : Sensor threads management and drivers
  * @details        : Each sensor runs in its own thread to collect telemetry
  *                   data for the Qt HMI application
  *                   Includes HTS221 driver implementation
  ******************************************************************************
  */

#include "sensors.h"
#include "app_threadx.h"
#include <string.h>

/* External I2C handle */
extern I2C_HandleTypeDef hi2c2;

/* Global sensor data */
TX_MUTEX g_sensorDataMutex;
HTS221_Data_t g_hts221_data;
Battery_Data_t g_battery_data;

#define BATTERY_VOLTAGE_EPSILON 0.01f
/* ============================================================================
 * HTS221 Driver Implementation
 * ============================================================================ */

/* HTS221 Calibration data */
typedef struct {
    int16_t H0_T0_out;
    int16_t H1_T0_out;
    int16_t T0_out;
    int16_t T1_out;
    uint16_t H0_rh;
    uint16_t H1_rh;
    uint16_t T0_degC;
    uint16_t T1_degC;
} HTS221_Calibration_t;

static HTS221_Calibration_t calib_data;

/**
 * @brief 
 * 
 * @param hi2c 
 * @param reg 
 * @param data 
 * @return HAL_StatusTypeDef 
 */
static HAL_StatusTypeDef HTS221_WriteReg(I2C_HandleTypeDef *hi2c, uint8_t reg, uint8_t data)
{
    uint16_t addr = HTS221_I2C_ADDRESS << 1;
    return HAL_I2C_Mem_Write(hi2c, addr, reg, I2C_MEMADD_SIZE_8BIT, &data, 1, 100);
}

/**
 * @brief 
 * 
 * @param hi2c 
 * @return * HAL_StatusTypeDef 
 */
static HAL_StatusTypeDef HTS221_ReadCalibration(I2C_HandleTypeDef *hi2c)
{
    uint8_t t0_msb, t1_msb;
    uint8_t buffer[16];
    uint16_t addr = HTS221_I2C_ADDRESS << 1;
    
    if (HAL_I2C_Mem_Read(hi2c, addr, 0x30 | 0x80, I2C_MEMADD_SIZE_8BIT, buffer, 16, 100) != HAL_OK)
        return HAL_ERROR; 
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

/**
 * @brief 
 * 
 * @param hi2c 
 * @return HAL_StatusTypeDef 
 */
HAL_StatusTypeDef HTS221_Init(I2C_HandleTypeDef *hi2c)
{   
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

/**
 * @brief 
 * 
 * @param hi2c 
 * @param temperature 
 * @param humidity 
 * @return HAL_StatusTypeDef 
 */
HAL_StatusTypeDef HTS221_ReadBoth(I2C_HandleTypeDef *hi2c, float *temperature, float *humidity)
{
    uint8_t h_low, t_low, t_high;
    int16_t h_raw, t_raw;
    uint16_t addr = HTS221_I2C_ADDRESS << 1;
    
    if (HAL_I2C_Mem_Read(hi2c, addr, HTS221_HUMIDITY_OUT_L, I2C_MEMADD_SIZE_8BIT, &h_low, 1, 100) != HAL_OK)
        return HAL_ERROR; 
    if (HAL_I2C_Mem_Read(hi2c, addr, HTS221_TEMP_OUT_L, I2C_MEMADD_SIZE_8BIT, &t_low, 1, 100) != HAL_OK)
        return HAL_ERROR;
    if (HAL_I2C_Mem_Read(hi2c, addr, HTS221_TEMP_OUT_H, I2C_MEMADD_SIZE_8BIT, &t_high, 1, 100) != HAL_OK)
        return HAL_ERROR;

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

/**
 * @brief 
 * 
 * @param initial_input 
 */
void SensorHTS221Thread(ULONG initial_input)
{
    float temp, hum;
    HAL_StatusTypeDef status;
    static int16_t last_temp_int = -99;
    static int16_t last_hum_int = -99;
    static ULONG last_send_time = 0;
    static const ULONG HEARTBEAT_INTERVAL = 3000;
    
    (void)initial_input;
    UartPrint("HTS221 Thread: Started\r\n");
    tx_thread_sleep(100);
    last_send_time = tx_time_get();
    
    while (1)
    {
        status = HTS221_ReadBoth(&hi2c2, &temp, &hum);   
        if (status == HAL_OK)
        {
            if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) == TX_SUCCESS)
            {
                g_hts221_data.temperature = temp;
                g_hts221_data.humidity = hum;
                g_hts221_data.timestamp = tx_time_get();
                g_hts221_data.data_valid = 1;
                tx_mutex_put(&g_sensorDataMutex);
            }
            int16_t temp_int = (int16_t)temp;
            int16_t hum_int = (int16_t)hum;
            ULONG current_time = tx_time_get();

            if (temp_int != last_temp_int || hum_int != last_hum_int || 
                (current_time - last_send_time) >= HEARTBEAT_INTERVAL)
            {
                t_can_message msg;
                memset(&msg, 0, sizeof(msg));
                msg.id = CAN_ID_HTS221_DATA;
                msg.len = 8;
                memcpy(&msg.data[0], &temp, 4);
                memcpy(&msg.data[4], &hum, 4);
                CanSend(&msg);
                last_temp_int = temp_int;
                last_hum_int = hum_int;
                last_send_time = current_time;
            }  
        }
        else
        {
            UartPrint("HTS221 Thread: Read error\r\n");
            if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) == TX_SUCCESS)
            {
                g_hts221_data.data_valid = 0;
                tx_mutex_put(&g_sensorDataMutex);
            }
        }
        tx_thread_sleep(100);
    }
}

/**
 * @brief 
 * 
 */
void SensorsInit(void)
{
    tx_mutex_create(&g_sensorDataMutex, "Sensor Data Mutex", TX_NO_INHERIT);
    memset(&g_hts221_data, 0, sizeof(HTS221_Data_t));
    memset(&g_battery_data, 0, sizeof(Battery_Data_t));
}

/* ============================================================================
 * Battery Monitor Driver Implementation
 * ============================================================================ */

/**
 * @brief 
 * 
 * @param hi2c 
 * @return HAL_StatusTypeDef 
 */
HAL_StatusTypeDef Battery_Init(I2C_HandleTypeDef *hi2c)
{
    uint8_t buffer[2];
    HAL_StatusTypeDef status;
    uint16_t dev_addr = BATTERY_I2C_ADDRESS << 1;

    status = HAL_I2C_Mem_Read(hi2c, dev_addr, INA219_REG_CONFIG, 
                               I2C_MEMADD_SIZE_8BIT, buffer, 2, 100);
    
    if (status != HAL_OK)
    {
        UartPrint("Battery: ERROR - Failed to communicate with INA219\r\n");
        return HAL_ERROR;
    }
    status = HAL_I2C_Mem_Read(hi2c, dev_addr, INA219_REG_BUS_V, 
                               I2C_MEMADD_SIZE_8BIT, buffer, 2, 100);
    if (status == HAL_OK)
    {
        uint16_t bus_voltage_raw = (buffer[0] << 8) | buffer[1];
        uint16_t voltage_bits = (bus_voltage_raw >> 3) & 0x1FFF;
        float voltage = voltage_bits * 0.004f;
        UartPrintf("Battery: INA219 initialized successfully! Current voltage: %.3fV\r\n", voltage);
        if (voltage < 9.0f || voltage > 13.0f)
        {
            UartPrintf("Battery: WARNING - Voltage %.3fV outside 3S range (9.0-12.6V)\r\n", voltage);
        }
        return HAL_OK;
    }
    UartPrint("Battery: ERROR - Failed to read voltage from INA219\r\n");
    return HAL_ERROR;
}

/**
 * @brief 
 * 
 * @param hi2c 
 * @param voltage 
 * @param percentage 
 * @return HAL_StatusTypeDef 
 */
HAL_StatusTypeDef Battery_Read(I2C_HandleTypeDef *hi2c, float *voltage, uint8_t *percentage)
{
    uint8_t buffer[2];
    HAL_StatusTypeDef status;
    uint16_t dev_addr = BATTERY_I2C_ADDRESS << 1;
    
    if (voltage == NULL || percentage == NULL)
    {
        return HAL_ERROR;
    }
    status = HAL_I2C_Mem_Read(hi2c, dev_addr, INA219_REG_BUS_V, 
                               I2C_MEMADD_SIZE_8BIT, buffer, 2, 100);
    if (status != HAL_OK)
    {
        *voltage = 0.0f;
        *percentage = 0;
        return HAL_ERROR;
    }
    
    /* Decode INA219 Bus Voltage Register
     * Bit 15-3: Voltage value (LSB = 4mV)
     * Bit 2: Reserved
     * Bit 1: CNVR (Conversion Ready) - 1 when conversion complete
     * Bit 0: OVF (Math Overflow) - 1 on overflow
     */
    uint16_t bus_voltage_raw = (buffer[0] << 8) | buffer[1];
    if (bus_voltage_raw & INA219_BUS_V_OVF)
    {
        UartPrint("Battery: WARNING - INA219 math overflow detected\r\n");
    }
    uint16_t voltage_bits = (bus_voltage_raw >> 3) & 0x1FFF;
    *voltage = voltage_bits * 0.004f;
    if (*voltage >= BATTERY_3S_MAX_V)
    {
        *percentage = 100;
    }
    else if (*voltage <= BATTERY_3S_MIN_V)
    {
        *percentage = 0;
    }
    else if (*voltage >= BATTERY_3S_NOM_V)
    {
        float pct = 50.0f + ((*voltage - BATTERY_3S_NOM_V) / (BATTERY_3S_MAX_V - BATTERY_3S_NOM_V)) * 50.0f;
        *percentage = (uint8_t)pct;
    }
    else
    {
        float pct = ((*voltage - BATTERY_3S_MIN_V) / (BATTERY_3S_NOM_V - BATTERY_3S_MIN_V)) * 50.0f;
        *percentage = (uint8_t)pct;
    }
    return HAL_OK;
}

/* ============================================================================
 * Battery Sensor Thread
 * ============================================================================ */

/**
 * @brief 
 * 
 * @param initial_input 
 */
void SensorBatteryThread(ULONG initial_input)
{
    float voltage;
    uint8_t percentage;
    HAL_StatusTypeDef status;
    uint32_t error_count = 0;
    static uint8_t last_percentage = 0xFF;
    static float last_voltage = -1.0f;
    
    (void)initial_input;
    UartPrint("Battery Thread: Started\r\n");
    tx_thread_sleep(100);
    while (1)
    {
        status = Battery_Read(&hi2c3, &voltage, &percentage);
        if (status == HAL_OK)
        {
            error_count = 0;
            if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) == TX_SUCCESS)
            {
                g_battery_data.voltage = voltage;
                g_battery_data.percentage = percentage;
                g_battery_data.timestamp = tx_time_get();
                g_battery_data.data_valid = 1;
                tx_mutex_put(&g_sensorDataMutex);
            }
            if (percentage != last_percentage ||
                fabsf(voltage - last_voltage) > BATTERY_VOLTAGE_EPSILON)
            {
                t_can_message msg;
                memset(&msg, 0, sizeof(msg));
                msg.id = CAN_ID_BATTERY_DATA;
                msg.len = 5;
                msg.data[0] = percentage;
                memcpy(&msg.data[1], &voltage, 4);
                CanSend(&msg);
                last_percentage = percentage;
                last_voltage = voltage;
            }
        }
        else
        {
            error_count++;
            UartPrintf("Battery: Read error #%lu (status=%d)\r\n", error_count, status);
            if (error_count >= 3)
            {
                if (tx_mutex_get(&g_sensorDataMutex, TX_WAIT_FOREVER) == TX_SUCCESS)
                {
                    g_battery_data.data_valid = 0;
                    tx_mutex_put(&g_sensorDataMutex);
                }
            }
        }
        tx_thread_sleep(1000);
    }
}
