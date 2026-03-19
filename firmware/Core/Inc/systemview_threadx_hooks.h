/**
 ******************************************************************************
 * @file    systemview_threadx_hooks.h
 * @author  DrivaPi Team
 * @brief   ThreadX execution-change hooks exported for SEGGER SystemView.
 ******************************************************************************
 */

#ifndef INC_SYSTEMVIEW_THREADX_HOOKS_H_
#define INC_SYSTEMVIEW_THREADX_HOOKS_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "tx_api.h"

/**
 * @brief Initializes execution profiling hooks used by ThreadX.
 */
VOID _tx_execution_initialize(VOID);

/**
 * @brief Called by ThreadX scheduler when a thread starts executing.
 */
VOID _tx_execution_thread_enter(VOID);

/**
 * @brief Called by ThreadX scheduler when a thread stops executing.
 */
VOID _tx_execution_thread_exit(VOID);

/**
 * @brief Called by ThreadX on ISR entry when execution-change notify is enabled.
 */
VOID _tx_execution_isr_enter(VOID);

/**
 * @brief Called by ThreadX on ISR exit when execution-change notify is enabled.
 */
VOID _tx_execution_isr_exit(VOID);

#ifdef __cplusplus
}
#endif

#endif /* INC_SYSTEMVIEW_THREADX_HOOKS_H_ */
