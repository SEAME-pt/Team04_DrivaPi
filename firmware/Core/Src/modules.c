#include "app_threadx.h"
#include "modules.h"
#include "speed_sensor.h"

/* Module manager runtime memory areas (kernel-side).
 * Multiple modules each reserve stacks + data from this pool, so keep headroom.
 */
static UCHAR g_module_manager_ram[131072];
static UCHAR g_module_manager_object_pool[65536];
static TXM_MODULE_INSTANCE g_speed_sensor_module;
static TXM_MODULE_INSTANCE g_sensors_module;
static TXM_MODULE_INSTANCE g_ultrasonic_module;
static TXM_MODULE_INSTANCE g_dc_motor_module;
static TXM_MODULE_INSTANCE g_servo_module;
static TXM_MODULE_INSTANCE g_health_module;

/* Default empty module images, overridden by generated image sources when present. */
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

UINT ModulesInit(void)
{
	UINT ret = TX_SUCCESS;

	/* Initialize module manager so kernel can host ThreadX modules. */
	ret = txm_module_manager_initialize(g_module_manager_ram, sizeof(g_module_manager_ram));
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Module manager init failed\r\n", 28, HAL_MAX_DELAY);
		return ret;
	}

	ret = txm_module_manager_object_pool_create(g_module_manager_object_pool, sizeof(g_module_manager_object_pool));
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Module object pool failed\r\n", 27, HAL_MAX_DELAY);
		return ret;
	}

	txm_module_manager_memory_fault_notify(ModuleFaultHandler);

	if (g_speed_sensor_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Speed module image missing\r\n", 28, HAL_MAX_DELAY);
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
		HAL_UART_Transmit(&huart1, (uint8_t *)"Speed module load failed\r\n", 27, HAL_MAX_DELAY);
		return ret;
	}

	ret = txm_module_manager_start(&g_speed_sensor_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Speed module start failed\r\n", 28, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t *)"Speed module started\r\n", 22, HAL_MAX_DELAY);

	InitAllDevices();

	if (g_sensors_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Sensors module image missing\r\n", 30, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}

	ret = txm_module_manager_in_place_load(&g_sensors_module,
			(CHAR *)"sensors_module",
			(VOID *)g_sensors_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Sensors module load failed\r\n", 29, HAL_MAX_DELAY);
		return ret;
	}

	ret = txm_module_manager_start(&g_sensors_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Sensors module start failed\r\n", 30, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t *)"Sensors module started\r\n", 24, HAL_MAX_DELAY);

	if (g_ultrasonic_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Ultrasonic module image missing\r\n", 34, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}
	ret = txm_module_manager_in_place_load(&g_ultrasonic_module,
			(CHAR *)"ultrasonic_module",
			(VOID *)g_ultrasonic_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Ultrasonic module load failed\r\n", 32, HAL_MAX_DELAY);
		return ret;
	}
	ret = txm_module_manager_start(&g_ultrasonic_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Ultrasonic module start failed\r\n", 33, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t *)"Ultrasonic module started\r\n", 28, HAL_MAX_DELAY);

	if (g_dc_motor_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"DC motor module image missing\r\n", 32, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}
	ret = txm_module_manager_in_place_load(&g_dc_motor_module,
			(CHAR *)"dc_motor_module",
			(VOID *)g_dc_motor_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"DC motor module load failed\r\n", 30, HAL_MAX_DELAY);
		return ret;
	}
	ret = txm_module_manager_start(&g_dc_motor_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"DC motor module start failed\r\n", 31, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t *)"DC motor module started\r\n", 26, HAL_MAX_DELAY);

	if (g_servo_motor_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Servo module image missing\r\n", 29, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}
	ret = txm_module_manager_in_place_load(&g_servo_module,
			(CHAR *)"servo_motor_module",
			(VOID *)g_servo_motor_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Servo module load failed\r\n", 27, HAL_MAX_DELAY);
		return ret;
	}
	ret = txm_module_manager_start(&g_servo_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Servo module start failed\r\n", 28, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t *)"Servo module started\r\n", 23, HAL_MAX_DELAY);

	if (g_health_module_image_size == 0u)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Health module image missing\r\n", 30, HAL_MAX_DELAY);
		return TX_PTR_ERROR;
	}
	ret = txm_module_manager_in_place_load(&g_health_module,
			(CHAR *)"health_module",
			(VOID *)g_health_module_image);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Health module load failed\r\n", 28, HAL_MAX_DELAY);
		return ret;
	}
	ret = txm_module_manager_start(&g_health_module);
	if (ret != TX_SUCCESS)
	{
		HAL_UART_Transmit(&huart1, (uint8_t *)"Health module start failed\r\n", 29, HAL_MAX_DELAY);
		return ret;
	}
	HAL_UART_Transmit(&huart1, (uint8_t *)"Health module started\r\n", 24, HAL_MAX_DELAY);

	return TX_SUCCESS;
}