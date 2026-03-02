#ifndef STM32U5XX_HAL_H
#define STM32U5XX_HAL_H

#include <stdint.h>

/* 1. Register Definitions */
typedef struct {
    uint32_t CR1;
    uint32_t CNT;
    uint32_t ARR;
    uint32_t PSC;
} TIM_TypeDef;

/* 2. Handle Types */
typedef struct {
    TIM_TypeDef *Instance;
} TIM_HandleTypeDef;

typedef uint32_t UART_HandleTypeDef;
typedef uint32_t I2C_HandleTypeDef;
typedef uint32_t FDCAN_HandleTypeDef;
typedef uint32_t FDCAN_TxHeaderTypeDef;

/* 3. Status Constants - MUST BE ENUM for CMock */
typedef enum {
    HAL_OK      = 0x00U,
    HAL_ERROR   = 0x01U,
    HAL_BUSY    = 0x02U,
    HAL_TIMEOUT = 0x03U
} HAL_StatusTypeDef;

#ifndef __HAL_RCC_TIM1_CLK_ENABLE
#define __HAL_RCC_TIM1_CLK_ENABLE() (void)0
#endif

#define HAL_MAX_DELAY 0xFFFFFFFFU

/* 4. Function Prototypes for CMock */
HAL_StatusTypeDef HAL_TIM_Base_Start(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_TIM_Base_Stop(TIM_HandleTypeDef *htim);
HAL_StatusTypeDef HAL_UART_Transmit(UART_HandleTypeDef *huart, uint8_t *pData, uint16_t Size, uint32_t Timeout);

#endif
