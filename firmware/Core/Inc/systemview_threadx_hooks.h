/**
 ******************************************************************************
 * @file    systemview_threadx_hooks.h
 * @author  DrivaPi Team
 * @brief   ThreadX execution-change hooks exported for SEGGER SystemView.
 ******************************************************************************
 */

#ifndef SYSTEMVIEW_THREADX_HOOKS_H_
#define SYSTEMVIEW_THREADX_HOOKS_H_

#ifdef __cplusplus
extern "C" {
#endif

#include "tx_api.h"
#include "app_threadx.h"

VOID _tx_execution_initialize(VOID);
VOID _tx_execution_thread_enter(VOID);
VOID _tx_execution_thread_exit(VOID);
VOID _tx_execution_isr_enter(VOID);
VOID _tx_execution_isr_exit(VOID);

#ifdef __cplusplus
}
#endif

#endif /* SYSTEMVIEW_THREADX_HOOKS_H_ */
