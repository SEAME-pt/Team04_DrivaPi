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
thread_t				threads[6];
TX_QUEUE                queue_speed_cmd;
TX_QUEUE                queue_steer_cmd;
TX_EVENT_FLAGS_GROUP    event_flags;
TX_MUTEX                speed_data_mutex;
float                   g_vehicle_speed;
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

	g_vehicle_speed = 0;

	tx_queue_create(&queue_speed_cmd, "Speed Queue", sizeof(t_can_message)/sizeof(ULONG),
    memory_ptr, QUEUE_SIZE * sizeof(t_can_message));
    memory_ptr += QUEUE_SIZE * sizeof(t_can_message);

	tx_queue_create(&queue_steer_cmd, "Steering Queue", sizeof(t_can_message)/sizeof(ULONG),
	memory_ptr, QUEUE_SIZE * sizeof(t_can_message));
	memory_ptr += QUEUE_SIZE * sizeof(t_can_message);

	tx_event_flags_create(&event_flags, "System Events");

	thread_init();
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