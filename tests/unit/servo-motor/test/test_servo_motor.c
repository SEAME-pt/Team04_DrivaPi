/**
 ******************************************************************************
 * @file    test_servo_motor.c
 * @brief   Unit tests for real servo_motor.c using CMock (speed-sensor pattern)
 * @details Tests the actual firmware code by including it directly and mocking
 *          HAL/PCA9685 dependencies using CMock from common/mocks
 ******************************************************************************
 */

#include "main.h"
#include "mock_stm32u5xx_hal.h"
#include "mock_tx_api.h"
#include "mock_pca9685.h"

TX_MUTEX g_speedDataMutex;
TX_EVENT_FLAGS_GROUP g_eventFlags;
TX_QUEUE g_queueSpeedCmd;
TX_QUEUE g_queueSteerCmd;

I2C_HandleTypeDef hi2c3;
UART_HandleTypeDef huart1;

#include "../../../firmware/Core/Src/servo_motor.c"

void Error_Handler(void) {
    // No-op for tests
}

void UartPrintf(const char *format, ...) {
    // Stub for tests
}

// ========================================================
// TESTS FOR SetServoAngle - Basic Angles
// ========================================================

void test_SetServoAngle_ShouldReturnSuccessFor0Degrees(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MIN_PULSE, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 0);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldAccept90Degrees(void)
{
    uint16_t expected_pulse = SERVO_MIN_PULSE + ((SERVO_MAX_PULSE - SERVO_MIN_PULSE) * 90) / 180;
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, expected_pulse, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 90);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldAccept180Degrees(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MAX_PULSE, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 180);
    TEST_ASSERT_EQUAL_INT(1, result);
}

// ========================================================
// TESTS FOR SetServoAngle - Angle Clamping (> 180°)
// ========================================================

void test_SetServoAngle_ShouldClampAbove180Degrees(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MAX_PULSE, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 181);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldClamp181Degrees(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MAX_PULSE, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 181);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldClamp250Degrees(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MAX_PULSE, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 250);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldClamp500Degrees(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MAX_PULSE, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 500);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldClampMaxUint16(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MAX_PULSE, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 65535);
    TEST_ASSERT_EQUAL_INT(1, result);
}

// ========================================================
// TESTS FOR SetServoAngle - Pulse Calculation
// ========================================================

void test_SetServoAngle_ShouldCalculateCorrectPulseFor45Degrees(void)
{
    uint16_t expected_pulse = SERVO_MIN_PULSE + ((SERVO_MAX_PULSE - SERVO_MIN_PULSE) * 45) / 180;
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, expected_pulse, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 45);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldCalculateCorrectPulseFor135Degrees(void)
{
    uint16_t expected_pulse = SERVO_MIN_PULSE + ((SERVO_MAX_PULSE - SERVO_MIN_PULSE) * 135) / 180;
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, expected_pulse, HAL_OK);
    int result = SetServoAngle(SERVO_CH, 135);
    TEST_ASSERT_EQUAL_INT(1, result);
}

// ========================================================
// TESTS FOR SetServoAngle - Error Handling
// ========================================================

void test_SetServoAngle_ShouldReturnFailureWhenPCA9685Fails(void)
{
    uint16_t pulse = SERVO_MIN_PULSE + ((SERVO_MAX_PULSE - SERVO_MIN_PULSE) * 90) / 180;
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, pulse, HAL_ERROR);
    int result = SetServoAngle(SERVO_CH, 90);
    TEST_ASSERT_EQUAL_INT(0, result);
}

void test_SetServoAngle_ShouldReturnFailureWhenPCA9685Busy(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MIN_PULSE, HAL_BUSY);
    int result = SetServoAngle(SERVO_CH, 0);
    TEST_ASSERT_EQUAL_INT(0, result);
}

void test_SetServoAngle_ShouldReturnFailureWhenPCA9685Timeout(void)
{
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, SERVO_MIN_PULSE, HAL_TIMEOUT);
    int result = SetServoAngle(SERVO_CH, 0);
    TEST_ASSERT_EQUAL_INT(0, result);
}

// ========================================================
// TESTS FOR SetServoAngle - Different Channels
// ========================================================

void test_SetServoAngle_ShouldUseCorrectChannel0(void)
{
    uint16_t pulse = SERVO_MIN_PULSE + ((SERVO_MAX_PULSE - SERVO_MIN_PULSE) * 90) / 180;
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, 0, 0, pulse, HAL_OK);
    int result = SetServoAngle(0, 90);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldUseCorrectChannel5(void)
{
    uint16_t pulse = SERVO_MIN_PULSE + ((SERVO_MAX_PULSE - SERVO_MIN_PULSE) * 90) / 180;
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, 5, 0, pulse, HAL_OK);
    int result = SetServoAngle(5, 90);
    TEST_ASSERT_EQUAL_INT(1, result);
}

void test_SetServoAngle_ShouldUseCorrectChannel15(void)
{
    uint16_t pulse = SERVO_MIN_PULSE + ((SERVO_MAX_PULSE - SERVO_MIN_PULSE) * 90) / 180;
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, 15, 0, pulse, HAL_OK);
    int result = SetServoAngle(15, 90);
    TEST_ASSERT_EQUAL_INT(1, result);
}

static jmp_buf s_servoMotorLoopExit;
static t_can_message s_servoMotorQueuedMessage;

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
    (void)cmock_num_calls;
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
        memcpy(destination_ptr, &s_servoMotorQueuedMessage, sizeof(t_can_message));
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

static UINT ServoTxThreadSleepBreakCallback(ULONG timer_ticks, int cmock_num_calls)
{
    (void)timer_ticks;
    (void)cmock_num_calls;
    longjmp(s_servoMotorLoopExit, 1);
    return TX_SUCCESS;
}

void test_ServoMotor_ShouldProcessQueueMessageAndSetServoAngle(void)
{
    float angle_f = 45.7f;
    uint16_t angle = (uint16_t)angle_f;
    uint16_t expected_pulse = SERVO_MIN_PULSE + ((SERVO_MAX_PULSE - SERVO_MIN_PULSE) * angle) / 180u;

    memset(&s_servoMotorQueuedMessage, 0, sizeof(s_servoMotorQueuedMessage));
    s_servoMotorQueuedMessage.len = 8;
    memcpy(s_servoMotorQueuedMessage.data, &angle_f, sizeof(float));

    tx_event_flags_get_StubWithCallback(ServoTxEventFlagsGetCallback);
    tx_queue_receive_StubWithCallback(ServoTxQueueReceiveOnceCallback);
    tx_thread_sleep_StubWithCallback(ServoTxThreadSleepBreakCallback);

    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_SERVO, SERVO_CH, 0, expected_pulse, HAL_OK);

    if (setjmp(s_servoMotorLoopExit) == 0) {
        ServoMotor(0);
    }
}

void test_ServoMotor_ShouldSleepWhenQueueIsEmpty(void)
{
    tx_event_flags_get_StubWithCallback(ServoTxEventFlagsGetCallback);
    tx_queue_receive_StubWithCallback(ServoTxQueueReceiveEmptyCallback);
    tx_thread_sleep_StubWithCallback(ServoTxThreadSleepBreakCallback);

    if (setjmp(s_servoMotorLoopExit) == 0) {
        ServoMotor(0);
    }
}
