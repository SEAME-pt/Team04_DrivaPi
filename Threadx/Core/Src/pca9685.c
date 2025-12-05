/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : pca9685.c
  * @brief          : PCA9685 PWM driver implementation
  ******************************************************************************
  */
/* USER CODE END Header */

#include "pca9685.h"
#include "app_threadx.h"
#include <stdarg.h>

uint8_t i2c_debug = 0;

static void UART_Printf(const char* format, ...) {
    char buffer[256];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    HAL_UART_Transmit(&huart1, (uint8_t*)buffer, strlen(buffer), HAL_MAX_DELAY);
}

void UART_Print(const char* msg) {
    HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
}

static void Software_Delay(uint32_t ms) {
    volatile uint32_t count = ms * 20000; 
    while (count--) {
        __asm("nop");
    }
}

static HAL_StatusTypeDef PCA9685_SoftwareReset(I2C_HandleTypeDef *hi2c) {
    uint8_t reset_cmd = 0x06;
    HAL_StatusTypeDef status = HAL_I2C_Master_Transmit(hi2c, 0x00, &reset_cmd, 1, 500);
    Software_Delay(10);
    return status;
}

static HAL_StatusTypeDef PCA9685_WriteReg(I2C_HandleTypeDef *hi2c, uint8_t addr7, uint8_t reg, uint8_t val) {
    uint16_t devaddr = (uint16_t)(addr7 << 1);
    uint8_t data[2] = {reg, val};
    HAL_StatusTypeDef status = HAL_I2C_Master_Transmit(hi2c, devaddr, data, 2, 500);
    if (status != HAL_OK) {
        status = HAL_I2C_Mem_Write(hi2c, devaddr, reg, I2C_MEMADD_SIZE_8BIT, &val, 1, 500);
    }
    Software_Delay(20);
    return status;
}

static HAL_StatusTypeDef PCA9685_ReadReg(I2C_HandleTypeDef *hi2c, uint8_t addr7, uint8_t reg, uint8_t *val) {
    uint16_t devaddr = (uint16_t)(addr7 << 1);
    HAL_StatusTypeDef status = HAL_I2C_Mem_Read(hi2c, devaddr, reg, I2C_MEMADD_SIZE_8BIT, val, 1, 500);
    if (status != HAL_OK) {
        status = HAL_I2C_Master_Transmit(hi2c, devaddr, &reg, 1, 500);
        if (status == HAL_OK) {
            status = HAL_I2C_Master_Receive(hi2c, devaddr, val, 1, 500);
        }
    }
    return status;
}

HAL_StatusTypeDef PCA9685_Init_Device(I2C_HandleTypeDef *hi2c, uint8_t addr7, const char* name) {
    HAL_StatusTypeDef ret;
    char msg[128];
    snprintf(msg, sizeof(msg), "Init %s PCA9685 at 0x%02X with SWRST\r\n", name, addr7);
    UART_Print(msg);
    
    // UART_Print("  Issuing Software Reset (SWRST)...\r\n");
    // ret = PCA9685_SoftwareReset(hi2c);
    // if (ret != HAL_OK) {
    //     snprintf(msg, sizeof(msg), "  SWRST failed: %d (continuing anyway)\r\n", ret);
    //     UART_Print(msg);
    // } else {
    //     UART_Print("  SWRST OK!\r\n");
    // }
//    UART_Print("  Skipping SWRST (prevent hang)\r\n");
    ret = HAL_OK;
    Software_Delay(50);

    ret = PCA9685_WriteReg(hi2c, addr7, MODE1, 0x31);
    if (ret != HAL_OK) { snprintf(msg, sizeof(msg), "  FAILED MODE1: %d\r\n", ret); UART_Print(msg); return ret; }

    ret = PCA9685_WriteReg(hi2c, addr7, PRESCALE, 121);
    if (ret != HAL_OK) { snprintf(msg, sizeof(msg), "  FAILED PRESCALE: %d\r\n", ret); UART_Print(msg); return ret; }

    ret = PCA9685_WriteReg(hi2c, addr7, MODE1, 0x21);
    if (ret != HAL_OK) { snprintf(msg, sizeof(msg), "  FAILED WAKE: %d\r\n", ret); UART_Print(msg); return ret; }
    Software_Delay(50);

    uint8_t mode2_read = 0;
    ret = PCA9685_ReadReg(hi2c, addr7, MODE2, &mode2_read);
    if (ret == HAL_OK) { snprintf(msg, sizeof(msg), "  MODE2 current value: 0x%02X\r\n", mode2_read); UART_Print(msg); }
    else { snprintf(msg, sizeof(msg), "  MODE2 read FAILED: %d\r\n", ret); UART_Print(msg); }


    ret = PCA9685_WriteReg(hi2c, addr7, MODE2, 0x04);
    if (ret != HAL_OK) {
        snprintf(msg, sizeof(msg), "  MODE2 write FAILED: %d\r\n", ret); UART_Print(msg);
        UART_Print("  Skipping MODE2 - will attempt PWM write anyway\r\n");
        return HAL_OK;
    }
    return HAL_OK;
}

HAL_StatusTypeDef PCA9685_SetPWM(I2C_HandleTypeDef *hi2c, uint16_t addr, uint8_t channel, uint16_t on, uint16_t off) {
    uint8_t data[4];
    uint8_t reg = LED0_ON_L + 4 * channel;
    uint16_t devaddr = (uint16_t)(addr << 1);
    
    data[0] = on & 0xFF;
    data[1] = (on >> 8) & 0xFF;
    data[2] = off & 0xFF;
    data[3] = (off >> 8) & 0xFF;

    HAL_StatusTypeDef status = HAL_I2C_Mem_Write(hi2c, devaddr, reg, I2C_MEMADD_SIZE_8BIT, data, 4, 500);
    if (status == HAL_OK) {
        if (i2c_debug) UART_Printf("PCA9685_SetPWM: wrote PWM to 0x%02X reg=0x%02X\r\n", addr, reg);
        return HAL_OK;
    }

    uint32_t hal_err_mem = HAL_I2C_GetError(hi2c);
    if (i2c_debug) UART_Printf("PCA9685_SetPWM: Mem_Write failed addr=0x%02X HALerr=0x%08lX\r\n", addr, (unsigned long)hal_err_mem);

    uint8_t tx[5];
    tx[0] = reg;
    tx[1] = data[0];
    tx[2] = data[1];
    tx[3] = data[2];
    tx[4] = data[3];
    status = HAL_I2C_Master_Transmit(hi2c, devaddr, tx, 5, 500);
    if (status != HAL_OK) {
        uint32_t hal_err = HAL_I2C_GetError(hi2c);
        if (i2c_debug) UART_Printf("PCA9685_SetPWM: write to 0x%02X failed status=%d HALerr=0x%08lX\r\n", addr, (int)status, (unsigned long)hal_err);
    }
    return status;
}

HAL_StatusTypeDef PCA9685_SetFrequency(I2C_HandleTypeDef *hi2c, uint8_t addr7, double freq) {
    if (freq < 24.0) freq = 24.0;
    if (freq > 1526.0) freq = 1526.0;
    double prescaleval = 25000000.0 / (4096.0 * freq) - 1.0;
    uint8_t prescale = (uint8_t)(prescaleval + 0.5);

    uint8_t oldmode = 0;
    if (PCA9685_ReadReg(hi2c, addr7, MODE1, &oldmode) != HAL_OK) {
        UART_Print("PCA9685_SetFrequency: Failed to read MODE1\r\n");
        return HAL_ERROR;
    }

    uint8_t sleep_mode = (oldmode & 0x7F) | 0x10;
    if (PCA9685_WriteReg(hi2c, addr7, MODE1, sleep_mode) != HAL_OK) {
        UART_Print("PCA9685_SetFrequency: Failed to enter sleep\r\n");
        return HAL_ERROR;
    }
    Software_Delay(5);

    if (PCA9685_WriteReg(hi2c, addr7, PRESCALE, prescale) != HAL_OK) {
        UART_Print("PCA9685_SetFrequency: Failed to write PRESCALE\r\n");
        return HAL_ERROR;
    }
    Software_Delay(5);

    if (PCA9685_WriteReg(hi2c, addr7, MODE1, oldmode) != HAL_OK) {
        UART_Print("PCA9685_SetFrequency: Failed to restore MODE1\r\n");
        return HAL_ERROR;
    }
    Software_Delay(5);

    if (PCA9685_WriteReg(hi2c, addr7, MODE1, oldmode | 0xA0 | 0x01) != HAL_OK) {
        UART_Print("PCA9685_SetFrequency: Warning - failed to set RESTART/AI\r\n");
    }

    UART_Printf("PCA9685_SetFrequency: freq=%.1f Hz prescale=%d\r\n", freq, prescale);
    return HAL_OK;
}

HAL_StatusTypeDef PCA9685_Sleep(I2C_HandleTypeDef *hi2c, uint16_t addr) {
    uint8_t data[2];
    data[0] = MODE1;
    data[1] = 0x10;
    return HAL_I2C_Master_Transmit(hi2c, addr, data, 2, I2C_TIMEOUT);
}

void PCA9685_Init_All_Devices(void) {
    I2C_HandleTypeDef* buses[] = { &hi2c3 };
    const char* bus_names[] = { "I2C3" };

    for (size_t b = 0; b < sizeof(buses)/sizeof(buses[0]); ++b) {
        I2C_HandleTypeDef* bus = buses[b];
        UART_Printf("Scanning %s for PCA9685 devices...\r\n", bus_names[b]);
        for (uint8_t addr = 1; addr < 128; ++addr) {
            uint16_t devaddr = (uint16_t)(addr << 1);
            if (HAL_I2C_IsDeviceReady(bus, devaddr, 1, 50) == HAL_OK) {
                uint8_t v;
                if (PCA9685_ReadReg(bus, addr, LED0_ON_L, &v) == HAL_OK) {
                    UART_Printf("  PCA9685-like device at 7-bit 0x%02X (bus %s)\r\n", addr, bus_names[b]);
                    char namebuf[32];
                    snprintf(namebuf, sizeof(namebuf), "PCA9685@0x%02X", addr);
                    HAL_StatusTypeDef st = PCA9685_Init_Device(bus, addr, namebuf);
                    if (st == HAL_OK) {
                        UART_Printf("    Initialized PCA9685 at 0x%02X on %s\r\n", addr, bus_names[b]);
                    } else {
                        UART_Printf("    Init failed at 0x%02X on %s (status %d)\r\n", addr, bus_names[b], st);
                    }
                }
            }
        }
    }
}
