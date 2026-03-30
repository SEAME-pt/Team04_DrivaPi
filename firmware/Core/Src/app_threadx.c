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
#include "speed_sensor.h"
#include "speed_sensor_module_image.h"
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
bool					g_emergencyBrake;
thread_t				g_threads[9];
TX_QUEUE                g_queueSpeedCmd;
TX_QUEUE                g_queueSteerCmd;
TX_EVENT_FLAGS_GROUP    g_eventFlags;
TX_MUTEX                g_speedDataMutex;
TX_MUTEX                g_emergencyMutex;
TX_MUTEX                g_canMutex;
TX_MUTEX                g_motorMutex;
TX_MUTEX                g_servoMutex;
TX_MUTEX             	g_gearMutex;
RNDGear_t				g_current_gear;
float                   g_vehicleSpeed;
float 					g_current_speed;
int16_t 				g_current_pwm;

/* Module manager runtime memory areas (kernel-side). */
static UCHAR            g_module_manager_ram[32768];
static UCHAR            g_module_manager_object_pool[16384];
static TXM_MODULE_INSTANCE g_speed_sensor_module;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN PFP */
static VOID ModuleFaultHandler(TX_THREAD *thread_ptr, TXM_MODULE_INSTANCE *module_instance_ptr);

/* USER CODE END PFP */

/* USER CODE BEGIN 0 */
static VOID ModuleFaultHandler(TX_THREAD *thread_ptr, TXM_MODULE_INSTANCE *module_instance_ptr)
{
	(void)thread_ptr;
	(void)module_instance_ptr;
}
/* USER CODE END 0 */

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
  	g_emergencyBrake = false;
	g_vehicleSpeed = 0;
	g_current_gear = GEAR_NEUTRAL;
	g_current_speed = 0.0f;
	g_current_pwm = 0;

	const char *msg = "\r\n=== DrivaPi ThreadX Init ===\r\n";
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);

	/* Initialize module manager so kernel can host ThreadX modules. */
	ret = txm_module_manager_initialize(g_module_manager_ram, sizeof(g_module_manager_ram));
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Module manager init failed\r\n", 28, HAL_MAX_DELAY);
		return ret;
	}

	ret = txm_module_manager_object_pool_create(g_module_manager_object_pool, sizeof(g_module_manager_object_pool));
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Module object pool failed\r\n", 27, HAL_MAX_DELAY);
		return ret;
	}

	txm_module_manager_memory_fault_notify(ModuleFaultHandler);

	tx_queue_create(&g_queueSpeedCmd, "Speed Queue", sizeof(t_can_message)/sizeof(ULONG),
	memory_ptr, QUEUE_SIZE * sizeof(t_can_message));
	memory_ptr += QUEUE_SIZE * sizeof(t_can_message);

	tx_queue_create(&g_queueSteerCmd, "Steering Queue", sizeof(t_can_message)/sizeof(ULONG),
	memory_ptr, QUEUE_SIZE * sizeof(t_can_message));
	memory_ptr += QUEUE_SIZE * sizeof(t_can_message);

	tx_event_flags_create(&g_eventFlags, "System Events");

	tx_mutex_create(&g_speedDataMutex, "Speed Data Mutex", TX_NO_INHERIT);
	tx_mutex_create(&g_emergencyMutex, "Emergency Mutex", TX_NO_INHERIT);
	tx_mutex_create(&g_canMutex, "CAN Mutex", TX_NO_INHERIT);
	tx_mutex_create(&g_motorMutex, "Motor Mutex", TX_NO_INHERIT);
	tx_mutex_create(&g_servoMutex, "Servo Mutex", TX_NO_INHERIT);
	tx_mutex_create(&g_gearMutex, "Gear Mutex", TX_NO_INHERIT);

	if (g_speed_sensor_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Speed module image missing\r\n", 28, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}

	/* The speed module requests raw encoder data through kernel callbacks. */
	HAL_TIM_Base_Stop(&htim1);
	__HAL_RCC_TIM1_CLK_ENABLE();
	HAL_TIM_Base_Start(&htim1);

	ret = txm_module_manager_in_place_load(&g_speed_sensor_module,
			(CHAR *)"speed_sensor_module",
			(VOID *)g_speed_sensor_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Speed module load failed\r\n", 27, HAL_MAX_DELAY);
		return ret;
	}

	ret = txm_module_manager_start(&g_speed_sensor_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Speed module start failed\r\n", 28, HAL_MAX_DELAY);
		return ret;
	}

	InitAllDevices();

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
