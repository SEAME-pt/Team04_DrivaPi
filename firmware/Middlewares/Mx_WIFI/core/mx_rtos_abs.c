/**
  ******************************************************************************
  * @file    mx_rtos_abs.c
  * @author  MCD Application Team
  * @brief   mx_wifi CMSIS RTOS abstraction module
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2020 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "mx_wifi_conf.h"


#if (MX_WIFI_USE_CMSIS_OS == 1)
osThreadId thread_new(const char *name, void (*thread)(void const *), void *arg, int stacksize, int prio)
{
#if (osCMSIS < 0x20000U)
  const osThreadDef_t os_thread_def =
  {
    .name = (char *)name,
    .pthread = (os_pthread)thread,
    .tpriority = (osPriority)prio,
    .instances = 0,
    .stacksize = stacksize
  };
  return osThreadCreate(&os_thread_def, arg);

#else
  const osThreadAttr_t attributes =
  {
    .name = name,
    .stack_size = (uint32_t)stacksize,
    .priority = (osPriority_t)prio
  };
  return osThreadNew((osThreadFunc_t) thread, arg, &attributes);
#endif /* (osCMSIS < 0x20000U) */
}

#if (osCMSIS < 0x20000U)
void thread_exit(volatile osThreadId *thread_id)
{
  if (NULL != thread_id)
  {
    if (NULL != *thread_id)
    {
      const osThreadId to_delete = *thread_id;
      *thread_id = NULL;
      osThreadTerminate(to_delete);

      for (;;);
    }
  }
}
#endif /* (osCMSIS < 0x20000U)*/

void *fifo_get(osMessageQId queue, uint32_t timeout)
{
  void *p = NULL;

#if (osCMSIS < 0x20000U)
  osEvent evt = osMessageGet(queue, timeout);
  if (evt.status == osEventMessage)
  {
    p = evt.value.p;
  }
  return p;

#else
  osStatus_t status = osMessageQueueGet(queue, &p, NULL, timeout);
  if (status != osOK)
  {
    p = NULL;
  }

  return p;
#endif /* osCMSIS < 0x20000U */
}


#else  /* MX_WIFI_USE_CMSIS_OS */
/* ThreadX Native Cooperative Wrapper Implementation. */

int32_t noos_sem_signal(TX_SEMAPHORE *sem)
{
  if (sem != NULL)
  {
    if (tx_semaphore_put(sem) == TX_SUCCESS)
    {
      return 0;
    }
  }
  return -1;
}


int32_t noos_sem_wait(TX_SEMAPHORE *sem, uint32_t timeout, void (*idle_func)(uint32_t duration))
{
  UINT status;
  ULONG tickstart = tx_time_get();
  ULONG elapsed = 0;
  ULONG timeout_ticks;

  if (sem == NULL) return -1;

  if (timeout == WAIT_FOREVER)
  {
    timeout_ticks = TX_WAIT_FOREVER;
  }
  else
  {
    timeout_ticks = (timeout * TX_TIMER_TICKS_PER_SECOND) / 1000;
    if (timeout_ticks == 0 && timeout > 0)
    {
      timeout_ticks = 1;
    }
  }

  if (idle_func == NULL)
  {
    status = tx_semaphore_get(sem, timeout_ticks);
    return (status == TX_SUCCESS) ? 0 : -1;
  }

  while (1)
  {
    status = tx_semaphore_get(sem, 0);
    if (status == TX_SUCCESS)
    {
      return 0;
    }

    if (timeout != WAIT_FOREVER)
    {
      elapsed = tx_time_get() - tickstart;
      if (elapsed >= timeout_ticks)
      {
        return -1;
      }
    }

    if (idle_func != NULL)
    {
      uint32_t remaining_ms = (timeout == WAIT_FOREVER) ? WAIT_FOREVER : 
                              (timeout - ((elapsed * 1000) / TX_TIMER_TICKS_PER_SECOND));
      (*idle_func)(remaining_ms);
    }

  }
}


int32_t noos_fifo_init(noos_queue_t **qret, uint16_t len)
{
  int32_t rc = -1;
  noos_queue_t *q;

  if (len > 0U)
  {
    q = (noos_queue_t *)MX_WIFI_MALLOC(sizeof(noos_queue_t));
    if (q != NULL)
    {
      uint32_t mem_size = len * sizeof(void *);
      q->queue_mem = MX_WIFI_MALLOC(mem_size);
      if (q->queue_mem != NULL)
      {
        if (tx_queue_create(&(q->tx_queue), "mx_wifi_q", TX_1_ULONG, q->queue_mem, mem_size) == TX_SUCCESS)
        {
          rc = 0;
          *qret = q;
        }
        else
        {
          MX_WIFI_FREE(q->queue_mem);
          MX_WIFI_FREE(q);
          *qret = NULL;
        }
      }
      else
      {
        MX_WIFI_FREE(q);
        *qret = NULL;
      }
    }
  }
  return rc;
}


void noos_fifo_deinit(noos_queue_t *q)
{
  if (q != NULL)
  {
    tx_queue_delete(&(q->tx_queue));
    MX_WIFI_FREE(q->queue_mem);
    MX_WIFI_FREE(q);
  }
}

int32_t noos_fifo_push(noos_queue_t *queue, void *p, uint32_t timeout, void (*idle_func)(uint32_t duration))
{
  UINT status;
  ULONG tickstart = tx_time_get();
  ULONG elapsed = 0;
  ULONG timeout_ticks;

  if (queue == NULL) return -1;

  if (timeout == WAIT_FOREVER)
  {
    timeout_ticks = TX_WAIT_FOREVER;
  }
  else
  {
    timeout_ticks = (timeout * TX_TIMER_TICKS_PER_SECOND) / 1000;
    if (timeout_ticks == 0 && timeout > 0)
    {
      timeout_ticks = 1;
    }
  }

  if (idle_func == NULL)
  {
    status = tx_queue_send(&(queue->tx_queue), &p, timeout_ticks);
    return (status == TX_SUCCESS) ? 0 : -1;
  }

  while (1)
  {
    status = tx_queue_send(&(queue->tx_queue), &p, 0);
    if (status == TX_SUCCESS)
    {
      return 0;
    }

    if (timeout != WAIT_FOREVER)
    {
      elapsed = tx_time_get() - tickstart;
      if (elapsed >= timeout_ticks)
      {
        return -1;
      }
    }

    if (idle_func != NULL)
    {
      uint32_t remaining_ms = (timeout == WAIT_FOREVER) ? WAIT_FOREVER : 
                              (timeout - ((elapsed * 1000) / TX_TIMER_TICKS_PER_SECOND));
      (*idle_func)(remaining_ms);
    }
  }
}


void *noos_fifo_pop(noos_queue_t *queue, uint32_t timeout, void (*idle_func)(uint32_t duration))
{
  UINT status;
  ULONG tickstart = tx_time_get();
  ULONG elapsed = 0;
  ULONG timeout_ticks;
  void *p = NULL;

  if (queue == NULL) return NULL;

  if (timeout == WAIT_FOREVER)
  {
    timeout_ticks = TX_WAIT_FOREVER;
  }
  else
  {
    timeout_ticks = (timeout * TX_TIMER_TICKS_PER_SECOND) / 1000;
    if (timeout_ticks == 0 && timeout > 0)
    {
      timeout_ticks = 1;
    }
  }

  if (idle_func == NULL)
  {
    status = tx_queue_receive(&(queue->tx_queue), &p, timeout_ticks);
    return (status == TX_SUCCESS) ? p : NULL;
  }

  while (1)
  {
    status = tx_queue_receive(&(queue->tx_queue), &p, 0);
    if (status == TX_SUCCESS)
    {
      return p;
    }

    if (timeout != WAIT_FOREVER)
    {
      elapsed = tx_time_get() - tickstart;
      if (elapsed >= timeout_ticks)
      {
        return NULL;
      }
    }

    if (idle_func != NULL)
    {
      uint32_t remaining_ms = (timeout == WAIT_FOREVER) ? WAIT_FOREVER : 
                              (timeout - ((elapsed * 1000) / TX_TIMER_TICKS_PER_SECOND));
      (*idle_func)(remaining_ms);
    }

  }
}

#endif /* MX_WIFI_USE_CMSIS_OS */
