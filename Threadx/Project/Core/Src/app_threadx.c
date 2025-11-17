/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    app_threadx.c
  * @author  MCD Application Team
  * @brief   ThreadX applicative file
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
#include "app_threadx.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <string.h>
#include "main.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */
#define  THREAD_STACK_SIZE 1024
/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN PV */
uint8_t		thread_stack1[THREAD_STACK_SIZE];
TX_THREAD	thread_ptr1;

uint8_t		dc_motor_stack[THREAD_STACK_SIZE];
TX_THREAD	dc_motor_thread;

uint8_t		servo_motor_stack[THREAD_STACK_SIZE];
TX_THREAD	servo_motor_thread;

uint8_t		speed_sensor_stack[THREAD_STACK_SIZE];
TX_THREAD	speed_sensor_thread;

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN PFP */
VOID ld1_thread_entry(ULONG initial_input);
/* USER CODE END PFP */

/**
  * @brief  Application ThreadX Initialization.
  * @param memory_ptr: memory pointer
  * @retval int
  */
UINT App_ThreadX_Init(VOID *memory_ptr)
{
  UINT ret = TX_SUCCESS;
  /* USER CODE BEGIN App_ThreadX_MEM_POOL */

  /* USER CODE END App_ThreadX_MEM_POOL */
  /* USER CODE BEGIN App_ThreadX_Init */
  uint8_t status;
  status = 0;
  const char *msg_tick = "Failed to start thread1\r\n";

  if (tx_thread_create(&thread_ptr1, "led_thread1", ld1_thread_entry, 0, thread_stack1, THREAD_STACK_SIZE,
   10, 10, 1, TX_AUTO_START) != TX_SUCCESS)
	  status = TX_THREAD_ERROR;
  if (status == TX_THREAD_ERROR)
	  	  HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), HAL_MAX_DELAY);

  if (tx_thread_create(&thread_ptr1, "led_thread1", ld1_thread_entry, 0, thread_stack1, THREAD_STACK_SIZE,
   10, 10, 1, TX_AUTO_START) != TX_SUCCESS)
	  status = TX_THREAD_ERROR;
  if (status == TX_THREAD_ERROR)
  	  {
	  	  sprintf(dbuf, "Failed to start thread1\r\n", (unsigned long)free);
	  	  HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), HAL_MAX_DELAY);
  	  }

  if (tx_thread_create(&thread_ptr1, "led_thread1", ld1_thread_entry, 0, thread_stack1, THREAD_STACK_SIZE,
   10, 10, 1, TX_AUTO_START) != TX_SUCCESS)
	  status = TX_THREAD_ERROR;
  if (status == TX_THREAD_ERROR)
  	  {
	  	  sprintf(dbuf, "Failed to start thread1\r\n", (unsigned long)free);
	  	  HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), HAL_MAX_DELAY);
  	  }

  /* USER CODE END App_ThreadX_Init */

  return ret;
}

  /**
  * @brief  Function that implements the kernel's initialization.
  * @param  None
  * @retval None
  */
void MX_ThreadX_Init(void)
{
  /* USER CODE BEGIN Before_Kernel_Start */

  /* USER CODE END Before_Kernel_Start */

  tx_kernel_enter();

  /* USER CODE BEGIN Kernel_Start_Error */

  /* USER CODE END Kernel_Start_Error */
}

/* USER CODE BEGIN 1 */
VOID ld1_thread_entry(ULONG initial_input)
{
	const char *msg_tick = "Tick\r\n";
	while (1)
		HAL_UART_Transmit(&huart1, (uint8_t*)msg_tick, strlen(msg_tick), HAL_MAX_DELAY);
}
/* USER CODE END 1 */
