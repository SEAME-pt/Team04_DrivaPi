/**
 ******************************************************************************
 * @file    test_servo_motor.c
 * @brief   Unit tests for firmware/Core/Src/servo_motor.c (TIM-based implementation)
 ******************************************************************************
 */

#include "main.h"
#include "mock_tx_api.h"

#define TIM_CHANNEL_4 0x00000004u

typedef struct {
    TIM_HandleTypeDef *htim;
    uint32_t channel;
    uint32_t compare_value;
} TimCompareCall;

#define MAX_CAPTURED_TIM_CALLS 16u

static TimCompareCall s_tim_compare_calls[MAX_CAPTURED_TIM_CALLS];
static uint32_t s_tim_compare_call_count;

static void CaptureTimSetCompare(TIM_HandleTypeDef *htim, uint32_t channel, uint32_t compare_value);

#define __HAL_TIM_SET_COMPARE(htim, channel, compare) \
    CaptureTimSetCompare((htim), (channel), (compare))

#include "../../../firmware/Core/Src/servo_motor.c"

TX_EVENT_FLAGS_GROUP g_eventFlags;
TX_QUEUE g_queueSteerCmd;
TX_MUTEX g_servoMutex;

TIM_HandleTypeDef htim8;

void Error_Handler(void)
{
}

static void CaptureTimSetCompare(TIM_HandleTypeDef *htim, uint32_t channel, uint32_t compare_value)
{
    if (s_tim_compare_call_count < MAX_CAPTURED_TIM_CALLS) {
        s_tim_compare_calls[s_tim_compare_call_count].htim = htim;
        s_tim_compare_calls[s_tim_compare_call_count].channel = channel;
        s_tim_compare_calls[s_tim_compare_call_count].compare_value = compare_value;
        s_tim_compare_call_count++;
    }
}

static jmp_buf s_servo_motor_loop_exit;
static t_can_message s_servo_motor_queued_message;

static UINT ServoTxEventFlagsGetCallback(TX_EVENT_FLAGS_GROUP *group_ptr,
                                         ULONG requested_flags,
                                         UINT get_option,
                                         ULONG *actual_flags,
                                         ULONG wait_option,
                                         int cmock_num_calls)
{
    (void)group_ptr;
    (void)get_option;
    (void)wait_option;

    if (cmock_num_calls > 0) {
        longjmp(s_servo_motor_loop_exit, 1);
    }

    if (actual_flags != NULL) {
        *actual_flags = requested_flags;
    }

    return TX_SUCCESS;
}

static UINT ServoTxQueueReceiveOnceCallback(TX_QUEUE *queue_ptr,
                                            void *destination_ptr,
                                            ULONG wait_option,
                                            int cmock_num_calls)
{
    (void)queue_ptr;
    (void)wait_option;

    if (cmock_num_calls == 0) {
        memcpy(destination_ptr, &s_servo_motor_queued_message, sizeof(t_can_message));
        return TX_SUCCESS;
    }

    return 1u;
}

static UINT ServoTxQueueReceiveEmptyCallback(TX_QUEUE *queue_ptr,
                                             void *destination_ptr,
                                             ULONG wait_option,
                                             int cmock_num_calls)
{
    (void)queue_ptr;
    (void)destination_ptr;
    (void)wait_option;
    (void)cmock_num_calls;
    return 1u;
}

void setUp(void)
{
    memset(s_tim_compare_calls, 0, sizeof(s_tim_compare_calls));
    memset(&s_servo_motor_queued_message, 0, sizeof(s_servo_motor_queued_message));
    s_tim_compare_call_count = 0u;
}

void tearDown(void)
{
}

void test_SetServoAngle_ShouldSetMinimumPulseForZeroDegrees(void)
{
    SetServoAngle(0u);

    TEST_ASSERT_EQUAL_UINT32(1u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_PTR(&htim8, s_tim_compare_calls[0].htim);
    TEST_ASSERT_EQUAL_UINT32(TIM_CHANNEL_4, s_tim_compare_calls[0].channel);
    TEST_ASSERT_EQUAL_UINT32(1000u, s_tim_compare_calls[0].compare_value);
}

void test_SetServoAngle_ShouldSetIntermediatePulseForNinetyDegrees(void)
{
    SetServoAngle(90u);

    TEST_ASSERT_EQUAL_UINT32(1u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(1500u, s_tim_compare_calls[0].compare_value);
}

void test_SetServoAngle_ShouldClampValuesAbove180Degrees(void)
{
    SetServoAngle(220u);

    TEST_ASSERT_EQUAL_UINT32(1u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(2000u, s_tim_compare_calls[0].compare_value);
}

void test_ServoMotor_ShouldProcessQueuedAngleAndUpdateCompare(void)
{
    uint8_t angle = 46u;
    uint32_t expected_compare = 1000u + ((uint32_t)angle * 1000u / 180u);

    s_servo_motor_queued_message.len = 8u;
    memcpy(s_servo_motor_queued_message.data, &angle, sizeof(uint8_t));

    tx_event_flags_get_StubWithCallback(ServoTxEventFlagsGetCallback);
    tx_queue_receive_StubWithCallback(ServoTxQueueReceiveOnceCallback);
    tx_mutex_get_ExpectAndReturn(&g_servoMutex, TX_WAIT_FOREVER, TX_SUCCESS);
    tx_mutex_put_ExpectAndReturn(&g_servoMutex, TX_SUCCESS);

    if (setjmp(s_servo_motor_loop_exit) == 0) {
        ServoMotor(0);
    }

    TEST_ASSERT_EQUAL_UINT32(1u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(TIM_CHANNEL_4, s_tim_compare_calls[0].channel);
    TEST_ASSERT_EQUAL_UINT32(expected_compare, s_tim_compare_calls[0].compare_value);
}

void test_ServoMotor_ShouldNotUpdateCompareWhenQueueIsEmpty(void)
{
    tx_event_flags_get_StubWithCallback(ServoTxEventFlagsGetCallback);
    tx_queue_receive_StubWithCallback(ServoTxQueueReceiveEmptyCallback);

    if (setjmp(s_servo_motor_loop_exit) == 0) {
        ServoMotor(0);
    }

    TEST_ASSERT_EQUAL_UINT32(0u, s_tim_compare_call_count);
}
