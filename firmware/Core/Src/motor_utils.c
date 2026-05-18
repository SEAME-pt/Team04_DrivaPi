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

