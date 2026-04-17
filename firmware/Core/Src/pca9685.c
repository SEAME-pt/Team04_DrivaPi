/* USER CODE BEGIN Header */
/**
******************************************************************************
* @file           : pca9685.c
* @brief          : PCA9685 PWM driver implementation
******************************************************************************
*/
/* USER CODE END Header */

#include "pca9685.h"

uint8_t g_i2cDebug = 0;

/**
 *
 * @param hi2c
 * @param addr7
 * @param reg
 * @param val
 * @return
 */
static HAL_StatusTypeDef PCA9685_WriteReg(I2C_HandleTypeDef *hi2c, uint8_t addr7, uint8_t reg, uint8_t val)
{
	uint16_t dev_addr = (uint16_t)(addr7 << 1);
	uint8_t data[2] = {reg, val};
	HAL_StatusTypeDef status = HAL_I2C_Master_Transmit(hi2c, dev_addr, data, 2, 500);
	if (status != HAL_OK)
		status = HAL_I2C_Mem_Write(hi2c, dev_addr, reg, I2C_MEMADD_SIZE_8BIT, &val, 1, 500);
	SoftwareDelay(20);
	return status;
}

/**
 *
 * @param hi2c
 * @param addr7
 * @param reg
 * @param val
 * @return
 */
static HAL_StatusTypeDef PCA9685_ReadReg(I2C_HandleTypeDef *hi2c, uint8_t addr7, uint8_t reg, uint8_t *val)
{
	uint16_t dev_addr = (uint16_t)(addr7 << 1);
	HAL_StatusTypeDef status = HAL_I2C_Mem_Read(hi2c, dev_addr, reg, I2C_MEMADD_SIZE_8BIT, val, 1, 500);
	if (status != HAL_OK) {
		status = HAL_I2C_Master_Transmit(hi2c, dev_addr, &reg, 1, 500);
		if (status == HAL_OK)
			status = HAL_I2C_Master_Receive(hi2c, dev_addr, val, 1, 500);
	}
	return status;
}

/**
 *
 * @param hi2c
 * @param addr7
 * @param name
 * @return
 */
HAL_StatusTypeDef PCA9685_InitDevice(I2C_HandleTypeDef *hi2c, uint8_t addr7, const char* name)
{
	HAL_StatusTypeDef ret;
	(void)name;
	
	SoftwareDelay(50);
	ret = PCA9685_WriteReg(hi2c, addr7, MODE1, 0x31);
	if (ret != HAL_OK)
		return ret;

	if (addr7 == 0x60)
		ret = PCA9685_WriteReg(hi2c, addr7, PRESCALE, 0x05);
	else
		ret = PCA9685_WriteReg(hi2c, addr7, PRESCALE, SERVO_FREQ);

	if (ret != HAL_OK)
		return ret;
	ret = PCA9685_WriteReg(hi2c, addr7, MODE1, 0x21);
	if (ret != HAL_OK)
		return ret;
	SoftwareDelay(50);
	ret = PCA9685_WriteReg(hi2c, addr7, MODE2, 0x04);
	if (ret != HAL_OK)
		return HAL_OK;
		
	return HAL_OK;
}

/**
 *
 * @param hi2c
 * @param addr
 * @param channel
 * @param on
 * @param off
 * @return
 */
HAL_StatusTypeDef PCA9685_SetPWM(uint16_t addr, uint8_t channel, uint16_t on, uint16_t off) {
	uint8_t data[4];
	uint8_t reg = LED0_ON_L + 4 * channel;
	uint16_t dev_addr = (uint16_t)(addr << 1);
	
	data[0] = on & 0xFF;
	data[1] = (on >> 8) & 0xFF;
	data[2] = off & 0xFF;
	data[3] = (off >> 8) & 0xFF;
	HAL_StatusTypeDef status = HAL_I2C_Mem_Write(&hi2c3, dev_addr, reg, I2C_MEMADD_SIZE_8BIT, data, 4, 500);
	if (status == HAL_OK)
	{
//		if (g_i2cDebug)
//			UartPrintf("PCA9685_SetPWM: wrote PWM to 0x%02X reg=0x%02X\r\n", addr, reg);
		return HAL_OK;
	}

	uint32_t hal_err_mem = HAL_I2C_GetError(&hi2c3);
	if (g_i2cDebug)
		UartPrintf("PCA9685_SetPWM: Mem_Write failed addr=0x%02X HALerr=0x%08lX\r\n", addr, (unsigned long)hal_err_mem);
	uint8_t tx[5];
	tx[0] = reg;
	tx[1] = data[0];
	tx[2] = data[1];
	tx[3] = data[2];
	tx[4] = data[3];
	status = HAL_I2C_Master_Transmit(&hi2c3, dev_addr, tx, 5, 500);
	if (status != HAL_OK)
	{
		uint32_t hal_err = HAL_I2C_GetError(&hi2c3);
		if (g_i2cDebug)
			UartPrintf("PCA9685_SetPWM: write to 0x%02X failed status=%d HALerr=0x%08lX\r\n", addr, (int)status, (unsigned long)hal_err);
	}
	return status;
}

/**
 *
 * @param hi2c
 * @param addr7
 * @param freq
 * @return
 */
HAL_StatusTypeDef PCA9685_SetFrequency(uint8_t addr7, double freq)
{
	if (freq < 24.0) 
		freq = 24.0;
	if (freq > 1526.0)
		freq = 1526.0;
	double prescale_val = 25000000.0 / (4096.0 * freq) - 1.0;
	uint8_t prescale = (uint8_t)(prescale_val + 0.5);

	uint8_t oldmode = 0;
	if (PCA9685_ReadReg(&hi2c3, addr7, MODE1, &oldmode) != HAL_OK)
	{
		UartPrint("PCA9685_SetFrequency: Failed to read MODE1\r\n");
		return HAL_ERROR;
	}
	uint8_t sleep_mode = (oldmode & 0x7F) | 0x10;
	if (PCA9685_WriteReg(&hi2c3, addr7, MODE1, sleep_mode) != HAL_OK)
	{
		UartPrint("PCA9685_SetFrequency: Failed to enter sleep\r\n");
		return HAL_ERROR;
	}
	SoftwareDelay(5);
	if (PCA9685_WriteReg(&hi2c3, addr7, PRESCALE, prescale) != HAL_OK)
	{
		UartPrint("PCA9685_SetFrequency: Failed to write PRESCALE\r\n");
		return HAL_ERROR;
	}
	SoftwareDelay(5);
	if (PCA9685_WriteReg(&hi2c3, addr7, MODE1, oldmode) != HAL_OK)
	{
		UartPrint("PCA9685_SetFrequency: Failed to restore MODE1\r\n");
		return HAL_ERROR;
	}
	SoftwareDelay(5);
	if (PCA9685_WriteReg(&hi2c3, addr7, MODE1, oldmode | 0xA0 | 0x01) != HAL_OK)
	{
		UartPrint("PCA9685_SetFrequency: Warning - failed to set RESTART/AI\r\n");
	}
	UartPrintf("PCA9685_SetFrequency: freq=%.1f Hz prescale=%d\r\n", freq, prescale);
	return HAL_OK;
}

/** @param hi2c
 * @param addr
 * @return
 */
HAL_StatusTypeDef PCA9685_Sleep(uint16_t addr)
{
	uint8_t data[2];
	data[0] = MODE1;
	data[1] = 0x10;
	return HAL_I2C_Master_Transmit(&hi2c3, addr, data, 2, I2C_TIMEOUT);
}

/**
 * Attempt to recover I2C bus by clearing errors
 * @param hi2c I2C handle
 * @return HAL_OK if recovery successful
 */
static HAL_StatusTypeDef I2C_BusRecovery(I2C_HandleTypeDef *hi2c)
{
	hi2c->ErrorCode = HAL_I2C_ERROR_NONE;
	uint32_t timeout = 10000;

	while ((hi2c->Instance->ISR & I2C_ISR_BUSY) && (--timeout))
	{
		SoftwareDelay(1);
	}
	if (timeout == 0)
	{
		UartPrintf("I2C bus still busy after recovery attempt\r\n");
		return HAL_BUSY;
	}
	return HAL_OK;
}

/**
 * Safe I2C device probe with recovery
 * @param hi2c I2C handle
 * @param dev_addr Device address (8-bit, left aligned)
 * @return HAL_OK if device found, HAL_ERROR otherwise
 */
static HAL_StatusTypeDef I2C_SafeProbe(I2C_HandleTypeDef *hi2c, uint16_t dev_addr)
{
	uint8_t dummy;

	HAL_StatusTypeDef status = HAL_I2C_Master_Receive(hi2c, dev_addr, &dummy, 1, 5);
	if (status != HAL_OK)
	{
		if (I2C_BusRecovery(hi2c) == HAL_OK)
		{
			status = HAL_I2C_Master_Receive(hi2c, dev_addr, &dummy, 1, 5);
		}
	}	
	return status;
}

void PCA9685_InitAllDevices(void)
{
	I2C_HandleTypeDef* buses[] = { &hi2c2, &hi2c3 };
	const char* bus_names[] = { "I2C2", "I2C3" };

	for (size_t b = 0; b < sizeof(buses)/sizeof(buses[0]); ++b) 
	{
		I2C_HandleTypeDef* bus = buses[b];
		if (bus->Instance == NULL)
			continue;
			
		if (I2C_BusRecovery(bus) != HAL_OK)
		{
			UartPrintf("Warning: %s recovery failed\r\n", bus_names[b]);
			continue;
		}
		
		for (uint8_t addr = 1; addr < 128; ++addr) 
		{
			uint16_t dev_addr = (uint16_t)(addr << 1);
			if (addr == 0x5F)
				continue;
			
			if (I2C_SafeProbe(bus, dev_addr) == HAL_OK)
			{
				uint8_t v;
				if (PCA9685_ReadReg(bus, addr, LED0_ON_L, &v) == HAL_OK)
				{
					char name_buffer[32];
					snprintf(name_buffer, sizeof(name_buffer), "PCA9685@0x%02X", addr);
					HAL_StatusTypeDef st = PCA9685_InitDevice(bus, addr, name_buffer);
					if (st != HAL_OK)
						UartPrintf("PCA9685 init failed at 0x%02X (status %d)\r\n", addr, st);
				}
			}
		}
	}
	MotorStop();
}
