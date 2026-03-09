/**
 ******************************************************************************
* @file    firmware/Core/Src/supervisor.c
* @author  DrivaPi Team
* @brief   This file contains the supervisor thread function.
******************************************************************************
* @attention
*
*/

#include "app_threadx.h"

#define TRACE_CHUNK_SIZE 1024

void DumpTraceBufferUART(void)
{
    uint32_t remaining = TRACE_BUFFER_SIZE;
    uint8_t *ptr = trace_buffer;

    while (remaining > 0)
    {
        uint16_t chunk = (remaining > TRACE_CHUNK_SIZE) ? TRACE_CHUNK_SIZE : remaining;
        HAL_UART_Transmit(&huart1, ptr, chunk, HAL_MAX_DELAY);
        ptr += chunk;
        remaining -= chunk;
    }
}
/**
 * @brief
 *
 * @param initial_input
 * @return VOID
 */
void ld1_ThreadEntry(ULONG initial_input)
{
	while (1)
	{
		DumpTraceBufferUART();
		tx_thread_sleep(500);
	}
}
