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
RNDGear_t				g_currentGear;
float                   g_vehicleSpeed;
float 					g_currentSpeed;
int16_t 				g_currentPWM;
MotorControlState		g_motorControlState;
uint16_t				g_targetSpeed;
unsigned char			trace_buffer[TRACE_BUFFER_SIZE];
/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN PFP */
static void AppThreadX_LogBootDiagnostics(void);
static void AppThreadX_LogThreadInitMessage(void);

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
	g_emergencyBrake = false;
	g_vehicleSpeed = 0;
	g_currentGear = GEAR_NEUTRAL;
	g_currentSpeed = 0.0f;
	g_currentPWM = 0;
	AppThreadX_LogBootDiagnostics();

	tx_queue_create(&g_queueSpeedCmd, "Speed Queue", sizeof(t_can_message)/sizeof(ULONG),
	memory_ptr, QUEUE_SIZE * sizeof(t_can_message));
	memory_ptr += QUEUE_SIZE * sizeof(t_can_message);

	tx_queue_create(&g_queueSteerCmd, "Steering Queue", sizeof(t_can_message)/sizeof(ULONG),
	memory_ptr, QUEUE_SIZE * sizeof(t_can_message));
	memory_ptr += QUEUE_SIZE * sizeof(t_can_message);

	tx_event_flags_create(&g_eventFlags, "System Events");

	tx_mutex_create(&g_speedDataMutex, "Speed Data Mutex", TX_INHERIT);
	tx_mutex_create(&g_emergencyMutex, "Emergency Mutex", TX_INHERIT);
	tx_mutex_create(&g_canMutex, "CAN Mutex", TX_INHERIT);
	tx_mutex_create(&g_motorMutex, "Motor Mutex", TX_INHERIT);
	tx_mutex_create(&g_servoMutex, "Servo Mutex", TX_INHERIT);
	tx_mutex_create(&g_gearMutex, "Gear Mutex", TX_INHERIT);

	//InitAllDevices();
	MotorControlInit(&g_motorControlState);
	AppThreadX_LogThreadInitMessage();
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
#if DEBUG_DIAGNOSTICS
	tx_trace_enable(trace_buffer, sizeof(trace_buffer), 32);
	SEGGER_SYSVIEW_Conf();
	SEGGER_SYSVIEW_Start();
#endif
  /* USER CODE END Before_Kernel_Start */

  tx_kernel_enter();

  /* USER CODE BEGIN Kernel_Start_Error */

  /* USER CODE END Kernel_Start_Error */
}

/* USER CODE BEGIN 1 */

static void AppThreadX_LogBootDiagnostics(void)
{
#if DEBUG_DIAGNOSTICS
	const char *msg = "\r\n=== DrivaPi ThreadX Init ===\r\n";
#endif
	uint8_t saw_flag = 0u;

#if DEBUG_DIAGNOSTICS
	(void)HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_TIMEOUT_MS);
#endif

	if (__HAL_RCC_GET_FLAG(RCC_FLAG_WWDGRST))
	{
#if DEBUG_DIAGNOSTICS
		msg = "[RESET] WWDG reset\r\n";
		(void)HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_TIMEOUT_MS);
#endif
		saw_flag = 1u;
	}
	if (__HAL_RCC_GET_FLAG(RCC_FLAG_IWDGRST))
	{
#if DEBUG_DIAGNOSTICS
		msg = "[RESET] IWDG reset\r\n";
		(void)HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_TIMEOUT_MS);
#endif
		saw_flag = 1u;
	}
	if (__HAL_RCC_GET_FLAG(RCC_FLAG_SFTRST))
	{
#if DEBUG_DIAGNOSTICS
		msg = "[RESET] Software reset\r\n";
		(void)HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_TIMEOUT_MS);
#endif
		saw_flag = 1u;
	}
	if (__HAL_RCC_GET_FLAG(RCC_FLAG_BORRST))
	{
#if DEBUG_DIAGNOSTICS
		msg = "[RESET] BOR/POR reset\r\n";
		(void)HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_TIMEOUT_MS);
#endif
		saw_flag = 1u;
	}
	if (__HAL_RCC_GET_FLAG(RCC_FLAG_PINRST))
	{
#if DEBUG_DIAGNOSTICS
		msg = "[RESET] Pin reset\r\n";
		(void)HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_TIMEOUT_MS);
#endif
		saw_flag = 1u;
	}
#if DEBUG_DIAGNOSTICS
	if (!saw_flag)
	{
		msg = "[RESET] No reset flag set\r\n";
		(void)HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_TIMEOUT_MS);
	}
#else
	(void)saw_flag;
#endif
	__HAL_RCC_CLEAR_RESET_FLAGS();
}

static void AppThreadX_LogThreadInitMessage(void)
{
#if DEBUG_DIAGNOSTICS
	const char *msg = "Initializing threads...\r\n";
	(void)HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), UART_BOOT_TIMEOUT_MS);
#endif
}

/* USER CODE END 1 */
