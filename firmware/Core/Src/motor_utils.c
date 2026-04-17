/**
 ******************************************************************************
 * @file           : motor_utils.c
 * @brief          : Motor utility functions implementation
 ******************************************************************************
 */

#include "../Inc/motor_utils.h"

/**
 * @brief Send a formatted string over UART1.
 *
 * @param format printf-style format string.
 * @param ... Format arguments.
 */
void UartPrintf(const char* format, ...)
{
	char buffer[256];
	va_list args;
	va_start(args, format);
	vsnprintf(buffer, sizeof(buffer), format, args);
	va_end(args);
	HAL_UART_Transmit(&huart1, (uint8_t*)buffer, strlen(buffer), HAL_MAX_DELAY);
}

/**
 * @brief Send a null-terminated string over UART1.
 *
 * @param msg Message to transmit.
 */
void UartPrint(const char* msg)
{
	HAL_UART_Transmit(&huart1, (uint8_t*)msg, strlen(msg), HAL_MAX_DELAY);
}

/**
 * @brief Busy-wait delay using a simple loop.
 *
 * @param ms Approximate delay in milliseconds.
 */
void SoftwareDelay(uint32_t ms)
{
	volatile uint32_t count = ms * 20000; 
	while (count--)
		__asm("nop");
}

/**
* @brief Clamp a signed value into the PCA9685 PWM range.
*
* @param computed_value Signed PWM count value.
* @return uint16_t Clamped PWM value.
*/
inline uint16_t ClampU16(int32_t computed_value)
{
	if (computed_value < 0)
		return 0;
	if (computed_value >= (int32_t)PCA9685_COUNTS) 
		return (uint16_t)(PCA9685_COUNTS - 1u);
	return (uint16_t)computed_value;
}
