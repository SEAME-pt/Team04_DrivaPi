/* USER CODE BEGIN Header */
/**
******************************************************************************
* @file    app_threadx.c
* @author  DriveAPi
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
#include "sensors.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN PV */
thread_t				g_threads[8];
TX_QUEUE                g_queueSpeedCmd;
TX_QUEUE                g_queueSteerCmd;
TX_EVENT_FLAGS_GROUP    g_eventFlags;
TX_MUTEX                g_speedDataMutex;
float                   g_vehicleSpeed;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN PFP */

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

	g_vehicleSpeed = 0;

	const char *msg = "\r\n=== DrivaPi ThreadX Init ===\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);

	tx_queue_create(&g_queueSpeedCmd, "Speed Queue", sizeof(t_can_message)/sizeof(ULONG),
	memory_ptr, QUEUE_SIZE * sizeof(t_can_message));
	memory_ptr += QUEUE_SIZE * sizeof(t_can_message);

	tx_queue_create(&g_queueSteerCmd, "Steering Queue", sizeof(t_can_message)/sizeof(ULONG),
	memory_ptr, QUEUE_SIZE * sizeof(t_can_message));
	memory_ptr += QUEUE_SIZE * sizeof(t_can_message);

	tx_event_flags_create(&g_eventFlags, "System Events");

	msg = "Initializing PCA9685 devices...\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	PCA9685_InitAllDevices();

	if (Battery_Init(&hi2c3) == HAL_OK)
	{
		msg = "Battery: Initialized successfully\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	}
	else
	{
		msg = "Battery: Initialization failed!\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	}

	if (HTS221_Init(&hi2c2) != HAL_OK)
	{
		msg = "HTS221: Initialization failed!\r\n";
		HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	}

	SensorsInit();

	msg = "Initializing threads...\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
	ThreadInit();

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


/* USER CODE END 1 */

