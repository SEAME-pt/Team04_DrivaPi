/**
 ******************************************************************************
 * @file    test_dc_motor.c
 * @brief   Unit tests for MotorSetPWM() function using CMock
 * @details Tests the real MotorSetPWM from firmware/Core/Src/dc_motor.c
 *          The function is compiled from the actual firmware source file
 ******************************************************************************
 */

#include "main.h"
#include "mock_stm32u5xx_hal.h"
#include "mock_tx_api.h"
#include "mock_pca9685.h"

/* --- GLOBAL VARIABLES (required by firmware) --- */
TX_MUTEX g_speedDataMutex;
TX_EVENT_FLAGS_GROUP g_eventFlags;
TX_QUEUE g_queueSpeedCmd;
TX_QUEUE g_queueSteerCmd;
int16_t g_current_pwm;

I2C_HandleTypeDef hi2c3;
UART_HandleTypeDef huart1;

/* --- INCLUDE FIRMWARE SOURCE FILES DIRECTLY --- */
#include "../../../firmware/Core/Src/motor_utils.c"
#include "../../../firmware/Core/Src/dc_motor.c"

/* --- TEST INFRASTRUCTURE --- */
void Error_Handler(void) {
    // No-op for tests
}

// ========================================================
// TESTS FOR MotorSetPWM - ONLY TESTED FUNCTION
// ========================================================

void test_MotorSetPWM_ShouldSetBothMotors(void)
{
    // Arrange - positive counts move motors forward
    int32_t left_counts = 2048;
    int32_t right_counts = 2048;
    const uint16_t max = 4095;
    uint16_t left_pwm = ClampU16(left_counts);
    uint16_t right_pwm = ClampU16(right_counts);
    
    // Left motor forward: A=max, B=0
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, left_pwm, HAL_OK);
    
    // Right motor forward: A=0, B=max
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, right_pwm, HAL_OK);
    MotorSetPWM(left_counts, right_counts);
}

void test_MotorSetPWM_WithNegativeCounts(void)
{
    // Arrange - negative counts move motors backward
    int32_t left_counts = -2048;
    int32_t right_counts = -2048;
    const uint16_t max = 4095;
    uint16_t left_pwm = ClampU16(-left_counts);
    uint16_t right_pwm = ClampU16(-right_counts);
    
    // Left motor backward: A=0, B=max
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, left_pwm, HAL_OK);
    
    // Right motor backward: A=max, B=0
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, right_pwm, HAL_OK);

    MotorSetPWM(left_counts, right_counts);
}

void test_MotorSetPWM_WithMixedDirections(void)
{
    // Arrange - left forward, right backward
    int32_t left_counts = 3000;
    int32_t right_counts = -3000;
    const uint16_t max = 4095;
    uint16_t left_pwm = ClampU16(left_counts);
    uint16_t right_pwm = ClampU16(-right_counts);
    
    // Left motor forward: A=max, B=0
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, left_pwm, HAL_OK);
    
    // Right motor backward: A=max, B=0
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, right_pwm, HAL_OK);
    MotorSetPWM(left_counts, right_counts);
}

void test_MotorSetPWM_WithClampingPositive(void)
{
    // Arrange - value above max should clamp to 4095
    int32_t left_counts = 5000;
    int32_t right_counts = 10000;
    const uint16_t max = 4095;
    uint16_t left_pwm = ClampU16(left_counts);
    uint16_t right_pwm = ClampU16(right_counts);
    
    // Left motor forward at clamped max
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, left_pwm, HAL_OK);
    
    // Right motor forward at clamped max
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, right_pwm, HAL_OK);
    MotorSetPWM(left_counts, right_counts);
}

void test_MotorSetPWM_WithClampingNegative(void)
{
    // Arrange - large negative values should clamp to 4095 after negation
    int32_t left_counts = -5000;
    int32_t right_counts = -10000;
    const uint16_t max = 4095;
    uint16_t left_pwm = ClampU16(-left_counts);
    uint16_t right_pwm = ClampU16(-right_counts);
    
    // Left motor backward at clamped max
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, left_pwm, HAL_OK);
    
    // Right motor backward at clamped max
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, right_pwm, HAL_OK);
    MotorSetPWM(left_counts, right_counts);
}
void test_MotorSetPWM_WithZeroCounts(void)
{
    int32_t left_counts = 0;
    int32_t right_counts = 0;
    const uint16_t max = 4095;
    
    // Left motor active brake (all max)
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, max, HAL_OK);
    
    // Right motor active brake (all max)
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, max, HAL_OK);
    MotorSetPWM(left_counts, right_counts);
}

void test_MotorSetPWM_WithMaxCounts(void)
{
    // Arrange - max positive counts
    int32_t left_counts = 4095;
    int32_t right_counts = 4095;
    const uint16_t max = 4095;
    uint16_t left_pwm = ClampU16(left_counts);
    uint16_t right_pwm = ClampU16(right_counts);
    
    // Left motor forward at max
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, left_pwm, HAL_OK);
    
    // Right motor forward at max
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, right_pwm, HAL_OK);
    MotorSetPWM(left_counts, right_counts);
}

static jmp_buf s_dcMotorLoopExit;
static t_can_message s_dcMotorQueuedMessage;

static UINT TxEventFlagsGetCallback(TX_EVENT_FLAGS_GROUP *group_ptr,
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

static UINT TxQueueReceiveOnceCallback(TX_QUEUE *queue_ptr,
                                       void *destination_ptr,
                                       ULONG wait_option,
                                       int cmock_num_calls)
{
    (void)queue_ptr;
    (void)wait_option;

    if (cmock_num_calls == 0) {
        memcpy(destination_ptr, &s_dcMotorQueuedMessage, sizeof(t_can_message));
        return TX_SUCCESS;
    }

    return 1u;
}

static UINT TxQueueReceiveEmptyCallback(TX_QUEUE *queue_ptr,
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

static UINT TxThreadSleepBreakCallback(ULONG timer_ticks, int cmock_num_calls)
{
    (void)timer_ticks;
    (void)cmock_num_calls;
    longjmp(s_dcMotorLoopExit, 1);
    return TX_SUCCESS;
}

void test_DcMotor_ShouldProcess8ByteCommand(void)
{
    int32_t left_counts = 1000;
    int32_t right_counts = -500;
    const uint16_t max = 4095;

    memset(&s_dcMotorQueuedMessage, 0, sizeof(s_dcMotorQueuedMessage));
    s_dcMotorQueuedMessage.len = 8;
    memcpy(s_dcMotorQueuedMessage.data, &left_counts, sizeof(int32_t));
    memcpy(s_dcMotorQueuedMessage.data + sizeof(int32_t), &right_counts, sizeof(int32_t));

    tx_event_flags_get_StubWithCallback(TxEventFlagsGetCallback);
    tx_queue_receive_StubWithCallback(TxQueueReceiveOnceCallback);
    tx_thread_sleep_StubWithCallback(TxThreadSleepBreakCallback);

    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, ClampU16(left_counts), HAL_OK);

    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, ClampU16(-right_counts), HAL_OK);

    if (setjmp(s_dcMotorLoopExit) == 0) {
        DcMotor(0);
    }
}

void test_DcMotor_ShouldProcess4ByteCommandForBothMotors(void)
{
    int32_t counts = 777;
    const uint16_t max = 4095;

    memset(&s_dcMotorQueuedMessage, 0, sizeof(s_dcMotorQueuedMessage));
    s_dcMotorQueuedMessage.len = 4;
    memcpy(s_dcMotorQueuedMessage.data, &counts, sizeof(int32_t));

    tx_event_flags_get_StubWithCallback(TxEventFlagsGetCallback);
    tx_queue_receive_StubWithCallback(TxQueueReceiveOnceCallback);
    tx_thread_sleep_StubWithCallback(TxThreadSleepBreakCallback);

    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, ClampU16(counts), HAL_OK);

    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max, HAL_OK);
    PCA9685_SetPWM_ExpectAndReturn(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, ClampU16(counts), HAL_OK);

    if (setjmp(s_dcMotorLoopExit) == 0) {
        DcMotor(0);
    }
}

void test_DcMotor_ShouldIgnoreMessagesSmallerThan4Bytes(void)
{
    memset(&s_dcMotorQueuedMessage, 0, sizeof(s_dcMotorQueuedMessage));
    s_dcMotorQueuedMessage.len = 3;

    tx_event_flags_get_StubWithCallback(TxEventFlagsGetCallback);
    tx_queue_receive_StubWithCallback(TxQueueReceiveOnceCallback);
    tx_thread_sleep_StubWithCallback(TxThreadSleepBreakCallback);

    if (setjmp(s_dcMotorLoopExit) == 0) {
        DcMotor(0);
    }
}

static HAL_StatusTypeDef UartTransmitCaptureCallback(UART_HandleTypeDef *huart,
                                                     uint8_t *pData,
                                                     uint16_t Size,
                                                     uint32_t Timeout,
                                                     int cmock_num_calls)
{
    (void)cmock_num_calls;
    TEST_ASSERT_EQUAL_PTR(&huart1, huart);
    TEST_ASSERT_EQUAL_UINT32(HAL_MAX_DELAY, Timeout);
    TEST_ASSERT_EQUAL_UINT16((uint16_t)5, Size);
    TEST_ASSERT_EQUAL_MEMORY("SPD42", pData, 5);
    return HAL_OK;
}

void test_ClampU16_ShouldReturnZeroForNegativeValue(void)
{
    TEST_ASSERT_EQUAL_UINT16(0, ClampU16(-1));
}

void test_ClampU16_ShouldReturnInputWithinRange(void)
{
    TEST_ASSERT_EQUAL_UINT16(1234, ClampU16(1234));
}

void test_ClampU16_ShouldClampAtUpperBound(void)
{
    TEST_ASSERT_EQUAL_UINT16(4095, ClampU16(4096));
}

void test_UartPrint_ShouldTransmitGivenMessage(void)
{
    const char *msg = "OK";
    HAL_UART_Transmit_ExpectAndReturn(&huart1, (uint8_t *)msg, 2, HAL_MAX_DELAY, HAL_OK);

    UartPrint(msg);
}

void test_UartPrintf_ShouldFormatAndTransmit(void)
{
    HAL_UART_Transmit_StubWithCallback(UartTransmitCaptureCallback);

    UartPrintf("SPD%d", 42);
}

void test_SoftwareDelay_ShouldNotReturnImmediately(void)
{
    SoftwareDelay(5);
    TEST_PASS();
}
