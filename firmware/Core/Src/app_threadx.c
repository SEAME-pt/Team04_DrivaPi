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
#include "tx_api.h"
#include "txm_module.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include "sensors.h"
#include "speed_sensor.h"
#include "speed_sensor_module_image.h"
#include "sensors_module_image.h"
#include "ultrasonic_module_image.h"
#include "dc_motor_module_image.h"
#include "servo_motor_module_image.h"
#include "health_module_image.h"
#include "txm_module_port.h"
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
TX_QUEUE                g_queueCanTx;
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
ULONG                   g_speed_module_last_tick;
ULONG                   g_sensors_module_last_tick;
ULONG                   g_ultrasonic_module_last_tick;
ULONG                   g_dc_motor_module_last_tick;
ULONG                   g_servo_module_last_tick;
ULONG                   g_health_module_last_tick;

ULONG                   g_latest_speed_command_tick;
int32_t                 g_latest_speed_command_left;
int32_t                 g_latest_speed_command_right;
UINT                    g_latest_speed_command_valid;

ULONG                   g_latest_servo_command_tick;
uint16_t                g_latest_servo_command_angle;
UINT                    g_latest_servo_command_valid;

/* Module manager runtime memory areas (kernel-side).
 * Multiple modules each reserve stacks + data from this pool, so keep headroom.
 */
static UCHAR            g_module_manager_ram[131072];
static UCHAR            g_module_manager_object_pool[65536];
static TXM_MODULE_INSTANCE g_speed_sensor_module;
static TXM_MODULE_INSTANCE g_sensors_module;
static TXM_MODULE_INSTANCE g_ultrasonic_module;
static TXM_MODULE_INSTANCE g_dc_motor_module;
static TXM_MODULE_INSTANCE g_servo_module;
static TXM_MODULE_INSTANCE g_health_module;

/* Default empty sensors module image, overridden by generated image source when present. */
__attribute__((weak, aligned(32))) const UCHAR g_sensors_module_image[] = {0u};
__attribute__((weak)) const ULONG g_sensors_module_image_size = 0u;
__attribute__((weak, aligned(32))) const UCHAR g_ultrasonic_module_image[] = {0u};
__attribute__((weak)) const ULONG g_ultrasonic_module_image_size = 0u;
__attribute__((weak, aligned(32))) const UCHAR g_dc_motor_module_image[] = {0u};
__attribute__((weak)) const ULONG g_dc_motor_module_image_size = 0u;
__attribute__((weak, aligned(32))) const UCHAR g_servo_motor_module_image[] = {0u};
__attribute__((weak)) const ULONG g_servo_motor_module_image_size = 0u;
__attribute__((weak, aligned(32))) const UCHAR g_health_module_image[] = {0u};
__attribute__((weak)) const ULONG g_health_module_image_size = 0u;
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN PFP */
static VOID ModuleFaultHandler(TX_THREAD *thread_ptr, TXM_MODULE_INSTANCE *module_instance_ptr);

/* USER CODE END PFP */

/* USER CODE BEGIN 0 */
extern TXM_MODULE_MANAGER_MEMORY_FAULT_INFO _txm_module_manager_memory_fault_info;

static VOID ModuleFaultUartPrint(const CHAR *text)
{
	if (text == TX_NULL)
	{
		return;
	}

	HAL_UART_Transmit(&huart1, (uint8_t *)text, (uint16_t)strlen(text), HAL_MAX_DELAY);
}

static VOID ModuleFaultHandler(TX_THREAD *thread_ptr, TXM_MODULE_INSTANCE *module_instance_ptr)
{
	CHAR line[160];
	const CHAR *thread_name = "<null>";
	const CHAR *module_name = "<null>";

	if ((thread_ptr != TX_NULL) && (thread_ptr->tx_thread_name != TX_NULL))
	{
		thread_name = thread_ptr->tx_thread_name;
	}

	if ((module_instance_ptr != TX_NULL) && (module_instance_ptr->txm_module_instance_name != TX_NULL))
	{
		module_name = module_instance_ptr->txm_module_instance_name;
	}

	ModuleFaultUartPrint("Module memory fault [diag-v2]\r\n");
	(void)snprintf(line, sizeof(line), "Thread=%s Module=%s\r\n", thread_name, module_name);
	ModuleFaultUartPrint(line);

	(void)snprintf(line, sizeof(line), "Code=%08lX SP=%08lX CTRL=%08lX LR=%08lX XPSR=%08lX\r\n",
			(ULONG)_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_code_location,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_sp,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_control,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_lr,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_xpsr);
	ModuleFaultUartPrint(line);

	(void)snprintf(line, sizeof(line), "SHCSR=%08lX CFSR=%08lX MMFAR=%08lX BFAR=%08lX\r\n",
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_shcsr,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_cfsr,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_mmfar,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_bfar);
	ModuleFaultUartPrint(line);

	(void)snprintf(line, sizeof(line), "R0=%08lX R1=%08lX R2=%08lX R3=%08lX R12=%08lX\r\n",
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_r0,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_r1,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_r2,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_r3,
			_txm_module_manager_memory_fault_info.txm_module_manager_memory_fault_info_r12);
	ModuleFaultUartPrint(line);
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
	g_speed_module_last_tick = 0u;
	g_sensors_module_last_tick = 0u;
	g_ultrasonic_module_last_tick = 0u;
	g_dc_motor_module_last_tick = 0u;
	g_servo_module_last_tick = 0u;
	g_health_module_last_tick = 0u;
	g_latest_speed_command_tick = 0u;
	g_latest_speed_command_left = 0;
	g_latest_speed_command_right = 0;
	g_latest_speed_command_valid = 0u;
	g_latest_servo_command_tick = 0u;
	g_latest_servo_command_angle = 0u;
	g_latest_servo_command_valid = 0u;

	const char *msg = "\r\n=== DrivaPi ThreadX Init [fw-marker:hb-v2] ===\r\n";
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

	tx_queue_create(&g_queueCanTx, "CAN TX Queue", sizeof(t_can_message)/sizeof(ULONG),
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
	HAL_UART_Transmit(&huart1, (uint8_t*)"Speed module started\r\n", 22, HAL_MAX_DELAY);

	InitAllDevices();

	if (g_sensors_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Sensors module image missing\r\n", 30, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}

	ret = txm_module_manager_in_place_load(&g_sensors_module,
			(CHAR *)"sensors_module",
			(VOID *)g_sensors_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Sensors module load failed\r\n", 29, HAL_MAX_DELAY);
		return ret;
	}

	ret = txm_module_manager_start(&g_sensors_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Sensors module start failed\r\n", 30, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t*)"Sensors module started\r\n", 24, HAL_MAX_DELAY);

	if (g_ultrasonic_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Ultrasonic module image missing\r\n", 34, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}
	ret = txm_module_manager_in_place_load(&g_ultrasonic_module,
			(CHAR *)"ultrasonic_module",
			(VOID *)g_ultrasonic_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Ultrasonic module load failed\r\n", 32, HAL_MAX_DELAY);
		return ret;
	}
	ret = txm_module_manager_start(&g_ultrasonic_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Ultrasonic module start failed\r\n", 33, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t*)"Ultrasonic module started\r\n", 28, HAL_MAX_DELAY);

	if (g_dc_motor_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"DC motor module image missing\r\n", 32, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}
	ret = txm_module_manager_in_place_load(&g_dc_motor_module,
			(CHAR *)"dc_motor_module",
			(VOID *)g_dc_motor_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"DC motor module load failed\r\n", 30, HAL_MAX_DELAY);
		return ret;
	}
	ret = txm_module_manager_start(&g_dc_motor_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"DC motor module start failed\r\n", 31, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t*)"DC motor module started\r\n", 26, HAL_MAX_DELAY);

	if (g_servo_motor_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Servo module image missing\r\n", 29, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}
	ret = txm_module_manager_in_place_load(&g_servo_module,
			(CHAR *)"servo_motor_module",
			(VOID *)g_servo_motor_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Servo module load failed\r\n", 27, HAL_MAX_DELAY);
		return ret;
	}
	ret = txm_module_manager_start(&g_servo_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Servo module start failed\r\n", 28, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t*)"Servo module started\r\n", 23, HAL_MAX_DELAY);

	if (g_health_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Health module image missing\r\n", 30, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}
	ret = txm_module_manager_in_place_load(&g_health_module,
			(CHAR *)"health_module",
			(VOID *)g_health_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Health module load failed\r\n", 28, HAL_MAX_DELAY);
		return ret;
	}
	ret = txm_module_manager_start(&g_health_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t*)"Health module start failed\r\n", 29, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t*)"Health module started\r\n", 24, HAL_MAX_DELAY);

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
