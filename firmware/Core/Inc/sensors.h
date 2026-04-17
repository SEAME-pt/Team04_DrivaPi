/**
  ******************************************************************************
  * @file           : sensors.h
  * @brief          : Sensor management - HTS221 temperature/humidity sensor
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
    float		temperature;      /* Temperature in Celsius */
    float		humidity;         /* Humidity in percentage */
    uint32_t	timestamp;     /* Timestamp of last read */
    uint8_t		data_valid;     /* Data validity flag */
} HTS221_Data_t;

/* Battery sensor data structure */
typedef struct
{
    float		voltage;          /* Battery voltage in Volts */
    uint8_t		percentage;     /* Battery percentage (0-100) */
    uint32_t	timestamp;     /* Timestamp of last read */
    uint8_t		data_valid;     /* Data validity flag */
} Battery_Data_t;

/* HTS221 Calibration data */
typedef struct
{
    int16_t 	H0_T0_out;
    int16_t		H1_T0_out;
    int16_t		T0_out;
    int16_t		T1_out;
    uint16_t	H0_rh;
    uint16_t	H1_rh;
    uint16_t	T0_degC;
    uint16_t	T1_degC;
} HTS221_Calibration_t;

/* Exported constants --------------------------------------------------------*/
/* HTS221 I2C Address */
#define HTS221_I2C_ADDRESS     0x5F

/* HTS221 Register Addresses */
#define HTS221_WHO_AM_I 	   0x0F
#define HTS221_CTRL_REG1	   0x20
#define HTS221_CTRL_REG2	   0x21
#define HTS221_CTRL_REG3       0x22
#define HTS221_STATUS_REG	   0x27
#define HTS221_HUMIDITY_OUT_L  0x28
#define HTS221_HUMIDITY_OUT_H  0x29
#define HTS221_TEMP_OUT_L      0x2A
#define HTS221_TEMP_OUT_H      0x2B

/* HTS221 Calibration registers */
#define HTS221_H0_RH_X2     	0x30
#define HTS221_H1_RH_X2     	0x31
#define HTS221_T0_DEGC_X8  		0x32
#define HTS221_T1_DEGC_X8 		0x33
#define HTS221_T1_T0_MSB    	0x35
#define HTS221_H0_T0_OUT_L  	0x36

/* HTS221 Expected WHO_AM_I value */
#define HTS221_WHO_AM_I_VALUE  	0xBC

/* Battery Monitor - INA219 Power Monitor at 0x41 */
#define BATTERY_I2C_ADDRESS    	0x41
#define INA219_REG_CONFIG      	0x00
#define INA219_REG_SHUNT_V     	0x01
#define INA219_REG_BUS_V       	0x02
#define INA219_REG_POWER       	0x03
#define INA219_REG_CURRENT     	0x04
#define INA219_REG_CALIBRATION 	0x05

/* INA219 Bus Voltage Register bits */
#define INA219_BUS_V_OVF       	(1 << 0)
#define INA219_BUS_V_CNVR      	(1 << 1)

/* 3S LiPo Battery voltage thresholds */
#define BATTERY_3S_MAX_V       	12.6f
#define BATTERY_3S_NOM_V       	11.1f
#define BATTERY_3S_MIN_V       	9.0f
#define BATTERY_3S_LOW_V       	10.5f

#define HTS221_H1_T0_OUT_H  	0x39
#define HTS221_T0_OUT_L     	0x3C
#define HTS221_T0_OUT_H    		0x3D
#define HTS221_T1_OUT_L     	0x3E

#define BATTERY_VOLTAGE_EPSILON 0.01f


extern TX_MUTEX 			g_sensorDataMutex;
extern HTS221_Data_t		g_hts221_data;
extern Battery_Data_t		g_battery_data;
extern I2C_HandleTypeDef	hi2c2;

/* Global sensor data */

HAL_StatusTypeDef	HTS221_Init(I2C_HandleTypeDef *hi2c);
HAL_StatusTypeDef	HTS221_ReadBoth(I2C_HandleTypeDef *hi2c, float *temperature, float *humidity);

HAL_StatusTypeDef	Battery_Init(I2C_HandleTypeDef *hi2c);
HAL_StatusTypeDef	Battery_Read(I2C_HandleTypeDef *hi2c, float *voltage, uint8_t *percentage);

void 				SensorHTS221Thread(ULONG initial_input);
void				SensorBatteryThread(ULONG initial_input);

void				SensorsInit(void);

#ifdef __cplusplus
}
#endif

#endif
