#ifndef TX_API_H
#define TX_API_H

#include <stdint.h>
#include <string.h>

/* ThreadX types and macros */
#define VOID void

typedef unsigned int UINT;
typedef unsigned long ULONG;
typedef unsigned long long ULONGLONG;

#define TX_NO_WAIT 0
#define TX_OR_CLEAR 1
#define TX_OR 0
#define TX_SUCCESS 0x00
#define TX_WAIT_FOREVER 0xFFFFFFFFUL
#define TX_TIMER_TICKS_PER_SECOND 1000

typedef struct {
    UINT tx_thread_id;
} TX_THREAD;

typedef struct {
    UINT tx_mutex_id;
} TX_MUTEX;

typedef struct {
    UINT tx_event_flags_group_id;
} TX_EVENT_FLAGS_GROUP;

typedef struct {
    UINT tx_queue_id;
} TX_QUEUE;

/* ThreadX function stubs */
UINT tx_mutex_create(TX_MUTEX *mutex_ptr, const char *name_ptr, UINT inherit);
UINT tx_mutex_delete(TX_MUTEX *mutex_ptr);
UINT tx_mutex_get(TX_MUTEX *mutex_ptr, ULONG wait_option);
UINT tx_mutex_put(TX_MUTEX *mutex_ptr);

UINT tx_event_flags_group_create(TX_EVENT_FLAGS_GROUP *group_ptr, const char *name_ptr);
UINT tx_event_flags_group_delete(TX_EVENT_FLAGS_GROUP *group_ptr);
UINT tx_event_flags_get(TX_EVENT_FLAGS_GROUP *group_ptr, ULONG requested_flags, UINT get_option, ULONG *actual_flags, ULONG wait_option);
UINT tx_event_flags_set(TX_EVENT_FLAGS_GROUP *group_ptr, ULONG flags_to_set, UINT set_option);
UINT tx_event_flags_get_all(TX_EVENT_FLAGS_GROUP *group_ptr, ULONG *flags);

UINT tx_queue_create(TX_QUEUE *queue_ptr, const char *name_ptr, UINT payload_size, void *queue_start, ULONG queue_size);
UINT tx_queue_delete(TX_QUEUE *queue_ptr);
UINT tx_queue_send(TX_QUEUE *queue_ptr, void *source_ptr, ULONG wait_option);
UINT tx_queue_receive(TX_QUEUE *queue_ptr, void *destination_ptr, ULONG wait_option);

UINT tx_thread_create(TX_THREAD *thread_ptr, const char *name_ptr, void (*entry_function)(ULONG), ULONG entry_input, void *stack_start, ULONG stack_size, UINT priority, UINT preempt_threshold, ULONG time_slice, UINT auto_start);
UINT tx_thread_delete(TX_THREAD *thread_ptr);
UINT tx_thread_resume(TX_THREAD *thread_ptr);
UINT tx_thread_suspend(TX_THREAD *thread_ptr);
ULONG tx_time_get(void);
UINT tx_thread_sleep(ULONG timer_ticks);

#endif
