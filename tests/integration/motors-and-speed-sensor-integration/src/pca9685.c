/* USER CODE BEGIN Header */
/**
******************************************************************************
* @file           : pca9685.c
* @brief          : PCA9685 PWM driver implementation
******************************************************************************
*/
/* USER CODE END Header */

#include "pca9685.h"

/**
 *@brief Write a single byte to a PCA9685 register
 * @param hi2c
 * @param addr7
 * @param reg
 * @param val
 * @return HAL status
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
 * @brief Read a single byte from a PCA9685 register	
 * @param hi2c
 * @param addr7
 * @param reg
 * @param val
 * @return HAL status
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
 * @brief Initialize the PCA9685 device with basic settings
 * @param hi2c
 * @param addr7
 * @param name
 * @return HAL status
 */
HAL_StatusTypeDef PCA9685_InitDevice(I2C_HandleTypeDef *hi2c, uint8_t addr7, const char* name)
{
	HAL_StatusTypeDef ret;
	char msg[128];
	snprintf(msg, sizeof(msg), "Init %s PCA9685 at 0x%02X with SWRST\r\n", name, addr7);
	UartPrint(msg);
	ret = HAL_OK;
	SoftwareDelay(50);

	ret = PCA9685_WriteReg(hi2c, addr7, MODE1, 0x31);
	if (ret != HAL_OK) 
	{ 
		snprintf(msg, sizeof(msg), "  FAILED MODE1: %d\r\n", ret); 
		UartPrint(msg);
		return ret;
	}

	if (addr7 == PCA9685_ADDR_MOTOR)
		ret = PCA9685_WriteReg(hi2c, addr7, PRESCALE, 0x05);
	else
		ret = PCA9685_WriteReg(hi2c, addr7, PRESCALE, SERVO_FREQ);
	if (ret != HAL_OK) 
	{ 
		snprintf(msg, sizeof(msg), "  FAILED PRESCALE: %d\r\n", ret);
		UartPrint(msg);
		return ret;
	}

	ret = PCA9685_WriteReg(hi2c, addr7, MODE1, 0x21);
	if (ret != HAL_OK)
	{ 
		snprintf(msg, sizeof(msg), "  FAILED WAKE: %d\r\n", ret); 
		UartPrint(msg);
		return ret; 
	}
	SoftwareDelay(50);

	uint8_t mode2_read = 0;
	ret = PCA9685_ReadReg(hi2c, addr7, MODE2, &mode2_read);
	if (ret == HAL_OK) 
	{ 
		snprintf(msg, sizeof(msg), "  MODE2 current value: 0x%02X\r\n", mode2_read); 
		UartPrint(msg);
	}
	else 
	{ 
		snprintf(msg, sizeof(msg), "  MODE2 read FAILED: %d\r\n", ret); 
		UartPrint(msg);
	}

	ret = PCA9685_WriteReg(hi2c, addr7, MODE2, 0x04);
	if (ret != HAL_OK)
	{
		snprintf(msg, sizeof(msg), "  MODE2 write FAILED: %d\r\n", ret); UartPrint(msg);
		UartPrint("  Skipping MODE2 - will attempt PWM write anyway\r\n");
		return HAL_OK;
	}
	return HAL_OK;
}

/**
 * @brief Set the PWM values for a specific channel on the PCA9685
 * @param hi2c
 * @param addr
 * @param channel
 * @param on
 * @param off
 * @return HAL status
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
			UartPrintf("PCA9685_SetPWM: wrote PWM to 0x%02X reg=0x%02X\r\n", addr, reg);
		return HAL_OK;
	}

	uint32_t hal_err_mem = HAL_I2C_GetError(&hi2c3);
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
			UartPrintf("PCA9685_SetPWM: write to 0x%02X failed status=%d HALerr=0x%08lX\r\n", addr, (int)status, (unsigned long)hal_err);
	}
	return status;
}
