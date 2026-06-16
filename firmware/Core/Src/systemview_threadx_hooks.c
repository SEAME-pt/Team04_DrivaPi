/**
 ******************************************************************************
 * @file    systemview_threadx_hooks.c
 * @author  DrivaPi Team
 * @brief   ThreadX execution-change hook implementation for SystemView.
 ******************************************************************************
 */

#include "systemview_threadx_hooks.h"
#include "tx_thread.h"
//#include "app_threadx.h"
/**
 * @brief Initializes execution profiling hooks used by ThreadX. Empty but needed to satisfy 
 * linker when execution-change notify is enabled.
 * @retval None
 */
VOID _tx_execution_initialize(VOID){}

/**
 * @brief Called by ThreadX scheduler when a thread starts executing.
 * @retval None
 */
VOID _tx_execution_thread_enter(VOID)
{
	TX_THREAD *current_thread;

	TX_THREAD_GET_CURRENT(current_thread);
	if (current_thread != NULL)
		SEGGER_SYSVIEW_OnTaskStartExec(TX_POINTER_TO_ULONG_CONVERT(current_thread));
	else
		SEGGER_SYSVIEW_OnIdle();
}

/**
 * @brief Called by ThreadX scheduler when a thread stops executing.
 * @retval None
 */
VOID _tx_execution_thread_exit(VOID)
{
	TX_THREAD *current_thread;

	TX_THREAD_GET_CURRENT(current_thread);
	if (current_thread != NULL)
		SEGGER_SYSVIEW_OnTaskStopReady(TX_POINTER_TO_ULONG_CONVERT(current_thread), 0u);
}

/**
 * @brief Called by ThreadX on ISR entry when execution-change notify is enabled.
 * @retval None
 */
VOID _tx_execution_isr_enter(VOID)
{
	SEGGER_SYSVIEW_RecordEnterISR();
}

/**
 * @brief Called by ThreadX on ISR exit when execution-change notify is enabled.
 * @retval None
 */
VOID _tx_execution_isr_exit(VOID)
{
	SEGGER_SYSVIEW_RecordExitISR();
}


