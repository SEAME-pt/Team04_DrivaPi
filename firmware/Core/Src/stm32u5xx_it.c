/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    stm32u5xx_it.c
  * @brief   Interrupt Service Routines.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "stm32u5xx_it.h"
/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdio.h>
#include <string.h>
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN TD */

/* USER CODE END TD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN PV */
static volatile uint32_t g_hardfault_cfsr = 0u;
static volatile uint32_t g_hardfault_hfsr = 0u;
static volatile uint32_t g_hardfault_mmfar = 0u;
static volatile uint32_t g_hardfault_bfar = 0u;
static volatile uint32_t g_hardfault_r0 = 0u;
static volatile uint32_t g_hardfault_r1 = 0u;
static volatile uint32_t g_hardfault_r2 = 0u;
static volatile uint32_t g_hardfault_r3 = 0u;
static volatile uint32_t g_hardfault_r12 = 0u;
static volatile uint32_t g_hardfault_lr = 0u;
static volatile uint32_t g_hardfault_pc = 0u;
static volatile uint32_t g_hardfault_psr = 0u;

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN PFP */
static void HardFault_DumpContext(uint32_t *stack_ptr);

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */
static void HardFault_DumpContext(uint32_t *stack_ptr)
{
  char line[192];

  if (stack_ptr != NULL)
  {
    g_hardfault_r0  = stack_ptr[0];
    g_hardfault_r1  = stack_ptr[1];
    g_hardfault_r2  = stack_ptr[2];
    g_hardfault_r3  = stack_ptr[3];
    g_hardfault_r12 = stack_ptr[4];
    g_hardfault_lr  = stack_ptr[5];
    g_hardfault_pc  = stack_ptr[6];
    g_hardfault_psr = stack_ptr[7];
  }

  g_hardfault_cfsr  = SCB->CFSR;
  g_hardfault_hfsr  = SCB->HFSR;
  g_hardfault_mmfar = SCB->MMFAR;
  g_hardfault_bfar  = SCB->BFAR;

  (void)snprintf(line, sizeof(line),
                 "\r\n[FAULT] HardFault CFSR=0x%08lX HFSR=0x%08lX MMFAR=0x%08lX BFAR=0x%08lX\r\n",
                 (unsigned long)g_hardfault_cfsr,
                 (unsigned long)g_hardfault_hfsr,
                 (unsigned long)g_hardfault_mmfar,
                 (unsigned long)g_hardfault_bfar);
  (void)HAL_UART_Transmit(&huart1, (uint8_t*)line, (uint16_t)strlen(line), 100);

  (void)snprintf(line, sizeof(line),
                 "[FAULT] r0=0x%08lX r1=0x%08lX r2=0x%08lX r3=0x%08lX r12=0x%08lX lr=0x%08lX pc=0x%08lX psr=0x%08lX\r\n",
                 (unsigned long)g_hardfault_r0,
                 (unsigned long)g_hardfault_r1,
                 (unsigned long)g_hardfault_r2,
                 (unsigned long)g_hardfault_r3,
                 (unsigned long)g_hardfault_r12,
                 (unsigned long)g_hardfault_lr,
                 (unsigned long)g_hardfault_pc,
                 (unsigned long)g_hardfault_psr);
  (void)HAL_UART_Transmit(&huart1, (uint8_t*)line, (uint16_t)strlen(line), 100);
}

/* USER CODE END 0 */

/* External variables --------------------------------------------------------*/

/* USER CODE BEGIN EV */

/* USER CODE END EV */

/******************************************************************************/
/*           Cortex Processor Interruption and Exception Handlers          */
/******************************************************************************/
/**
  * @brief This function handles Non maskable interrupt.
  */
void NMI_Handler(void)
{
  /* USER CODE BEGIN NonMaskableInt_IRQn 0 */

  /* USER CODE END NonMaskableInt_IRQn 0 */
  /* USER CODE BEGIN NonMaskableInt_IRQn 1 */
   while (1)
  {
  }
  /* USER CODE END NonMaskableInt_IRQn 1 */
}

/**
  * @brief This function handles Hard fault interrupt.
  */
void HardFault_Handler(void)
{
  /* USER CODE BEGIN HardFault_IRQn 0 */
  uint32_t *stack_ptr;
  __asm volatile
  (
    "tst lr, #4 \n"
    "ite eq     \n"
    "mrseq %0, msp \n"
    "mrsne %0, psp \n"
    : "=r" (stack_ptr)
  );
  HardFault_DumpContext(stack_ptr);

  /* USER CODE END HardFault_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_HardFault_IRQn 0 */
    /* USER CODE END W1_HardFault_IRQn 0 */
  }
}

/**
  * @brief This function handles Memory management fault.
  */
void MemManage_Handler(void)
{
  /* USER CODE BEGIN MemoryManagement_IRQn 0 */

  /* USER CODE END MemoryManagement_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_MemoryManagement_IRQn 0 */
    /* USER CODE END W1_MemoryManagement_IRQn 0 */
  }
}

/**
  * @brief This function handles Prefetch fault, memory access fault.
  */
void BusFault_Handler(void)
{
  /* USER CODE BEGIN BusFault_IRQn 0 */
	const char msg[] = "\r\n[FAULT] BusFault\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, sizeof(msg) - 1u, 100);

  /* USER CODE END BusFault_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_BusFault_IRQn 0 */
    /* USER CODE END W1_BusFault_IRQn 0 */
  }
}

/**
  * @brief This function handles Undefined instruction or illegal state.
  */
void UsageFault_Handler(void)
{
  /* USER CODE BEGIN UsageFault_IRQn 0 */
	const char msg[] = "\r\n[FAULT] UsageFault\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, sizeof(msg) - 1u, 100);

  /* USER CODE END UsageFault_IRQn 0 */
  while (1)
  {
    /* USER CODE BEGIN W1_UsageFault_IRQn 0 */
    /* USER CODE END W1_UsageFault_IRQn 0 */
  }
}

/**
  * @brief This function handles Debug monitor.
  */
void DebugMon_Handler(void)
{
  /* USER CODE BEGIN DebugMonitor_IRQn 0 */

  /* USER CODE END DebugMonitor_IRQn 0 */
  /* USER CODE BEGIN DebugMonitor_IRQn 1 */

  /* USER CODE END DebugMonitor_IRQn 1 */
}

/******************************************************************************/
/* STM32U5xx Peripheral Interrupt Handlers                                    */
/* Add here the Interrupt Handlers for the used peripherals.                  */
/* For the available peripheral interrupt handler names,                      */
/* please refer to the startup file (startup_stm32u5xx.s).                    */
/******************************************************************************/

/* USER CODE BEGIN 1 */

/* USER CODE END 1 */
