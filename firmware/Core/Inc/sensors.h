/**
  ******************************************************************************
  * @file           : sensors.h
  * @brief          : Sensor management - HTS221 and INA231
  ******************************************************************************
  */

#ifndef __SENSORS_H
#define __SENSORS_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32u5xx_hal.h"
#include "tx_api.h"
#include "app_threadx.h"

/* Exported types ------------------------------------------------------------*/

/* HTS221 sensor data structure */
typedef struct
{
    float       temperature;    /* Temperature in Celsius */
    float       humidity;       /* Humidity in percentage */
    uint32_t    timestamp;      /* Timestamp of last read */
    uint8_t     data_valid;     /* Data validity flag */
} HTS221_Data_t;

/* HTS221 Calibration data */
typedef struct
{
    int16_t     H0_T0_out;
    int16_t     H1_T0_out;
    int16_t     T0_out;
    int16_t     T1_out;
    uint16_t    H0_rh;
    uint16_t    H1_rh;
    uint16_t    T0_degC;
    uint16_t    T1_degC;
} HTS221_Calibration_t;

/* Battery sensor data structure */
typedef struct
{
    float       voltage;        /* Battery voltage in Volts */
    uint8_t     percentage;     /* Battery percentage (0-100) */
    uint32_t    timestamp;      /* Timestamp of last read */
    uint8_t     data_valid;     /* Data validity flag */
} Battery_Data_t;

/* INA231 detailed telemetry structure */
typedef struct
{
    float       voltage;
    float       current;
    float       power;
    uint8_t     percentage;
    uint32_t    timestamp;
    uint8_t     data_valid;
} INA231_Data_t;


/* Exported constants --------------------------------------------------------*/

/* ================= HTS221 Definitions ================= */
#define HTS221_I2C_ADDRESS     0x5F
#define HTS221_WHO_AM_I_VALUE  0xBC

/* HTS221 Register Addresses */
#define HTS221_WHO_AM_I        0x0F
#define HTS221_CTRL_REG1       0x20
#define HTS221_CTRL_REG2       0x21
#define HTS221_CTRL_REG3       0x22
#define HTS221_STATUS_REG      0x27
#define HTS221_HUMIDITY_OUT_L  0x28
#define HTS221_HUMIDITY_OUT_H  0x29
#define HTS221_TEMP_OUT_L      0x2A
#define HTS221_TEMP_OUT_H      0x2B

/* HTS221 Calibration registers */
#define HTS221_H0_RH_X2        0x30
#define HTS221_H1_RH_X2        0x31
#define HTS221_T0_DEGC_X8      0x32
#define HTS221_T1_DEGC_X8      0x33
#define HTS221_T1_T0_MSB       0x35
#define HTS221_H0_T0_OUT_L     0x36
#define HTS221_H1_T0_OUT_H     0x39
#define HTS221_T0_OUT_L        0x3C
#define HTS221_T0_OUT_H        0x3D
#define HTS221_T1_OUT_L        0x3E


/* ================= Battery / INA231 Definitions ================= */
/* I2C Address for the INA231 monitor connected to 2S2P battery pack */
/* Hardware: I2C2 STMod+ connector (PH4=SCL pin 7, PH5=SDA pin 10), A0=GND, A1=GND → address 0x40 */
#define INA231_I2C_ADDRESS     0x40
#define BATTERY_I2C_ADDRESS    INA231_I2C_ADDRESS

/* INA231 Registers */
#define INA231_REG_CONFIG      0x00
#define INA231_REG_SHUNT_V     0x01
#define INA231_REG_BUS_V       0x02
#define INA231_REG_POWER       0x03
#define INA231_REG_CURRENT     0x04
#define INA231_REG_CALIBRATION 0x05

/* INA231 Configuration & Calibration (R_shunt = 0.100 Ohm, R100) */
#define INA231_I_LSB           0.000305f   /* A/bit */
#define INA231_CONFIG_VAL      0x4127u     /* 1024 averages, 1.1 ms conversion */
#define INA231_CALIB_VAL       168u        /* Cal = 0.00512 / (0.000305 * 0.100) = 168 */

/* 2S2P Li-Ion Battery voltage thresholds (4.2V max per cell) */
#define BATTERY_2S_MAX_V       8.4f
#define BATTERY_2S_NOM_V       7.4f
#define BATTERY_2S_MIN_V       6.0f

/* 3S Li-Ion battery thresholds used by expansion-board monitor (0x200). */
#define BATTERY_3S_MAX_V       12.6f
#define BATTERY_3S_NOM_V       11.1f
#define BATTERY_3S_MIN_V       9.0f

#define BATTERY_VOLTAGE_EPSILON 0.01f

/* RPi 5V rail thresholds for percentage (If mapping 5V rail health) */
#define INA231_VBUS_MIN        4.5f        /* 0%  */
#define INA231_VBUS_MAX        5.5f        /* 100% */
#define INA231_VOLTAGE_EPSILON 0.01f


/* Exported Variables --------------------------------------------------------*/
extern TX_MUTEX             g_sensorDataMutex;
extern HTS221_Data_t        g_hts221_data;
extern Battery_Data_t       g_battery_data;
extern INA231_Data_t        g_ina231_data;
extern I2C_HandleTypeDef    hi2c2;

/* Exported Functions --------------------------------------------------------*/

/* HTS221 Functions */
HAL_StatusTypeDef   HTS221_Init(I2C_HandleTypeDef *hi2c);
HAL_StatusTypeDef   HTS221_ReadBoth(I2C_HandleTypeDef *hi2c, float *temperature, float *humidity);
void                SensorHTS221Thread(ULONG initial_input);

/* Battery Tracking Functions (Using INA231) */
HAL_StatusTypeDef   Battery_Init(I2C_HandleTypeDef *hi2c);
HAL_StatusTypeDef   Battery_Read(I2C_HandleTypeDef *hi2c, float *voltage, uint8_t *percentage);
void                SensorBatteryThread(ULONG initial_input);

/* Battery / INA231 Functions */
HAL_StatusTypeDef   Battery_Init(I2C_HandleTypeDef *hi2c);
HAL_StatusTypeDef   Battery_Read(I2C_HandleTypeDef *hi2c, float *voltage, uint8_t *percentage);
HAL_StatusTypeDef   Battery_ReadCurrent(I2C_HandleTypeDef *hi2c, float *current);
void                SensorBatteryThread(ULONG initial_input);

/* Direct INA231 Functions */
HAL_StatusTypeDef   INA231_Init(I2C_HandleTypeDef *hi2c);
HAL_StatusTypeDef   INA231_Read(I2C_HandleTypeDef *hi2c, float *voltage, float *current_a, float *power_w, uint8_t *percentage);
void                SensorINA231Thread(ULONG initial_input);

/* Global Sensor Init */
void                SensorsInit(void);

#ifdef __cplusplus
}
#endif

#endif /* __SENSORS_H */
