/**
 ******************************************************************************
 * @file    test_dc_motor.c
 * @brief   Unit tests for firmware/Core/Src/dc_motor.c (non-PCA implementation)
 ******************************************************************************
 */

#include "main.h"
#include "mock_tx_api.h"

typedef struct {
    uint32_t dummy;
} GPIO_TypeDef;

static GPIO_TypeDef s_gpio_a;
static GPIO_TypeDef s_gpio_b;
static GPIO_TypeDef s_gpio_c;
static GPIO_TypeDef s_gpio_d;
static GPIO_TypeDef s_gpio_e;
static GPIO_TypeDef s_gpio_f;
static GPIO_TypeDef s_gpio_g;
static GPIO_TypeDef s_gpio_h;
static GPIO_TypeDef s_gpio_i;

#define GPIOA (&s_gpio_a)
#define GPIOB (&s_gpio_b)
#define GPIOC (&s_gpio_c)
#define GPIOD (&s_gpio_d)
#define GPIOE (&s_gpio_e)
#define GPIOF (&s_gpio_f)
#define GPIOG (&s_gpio_g)
#define GPIOH (&s_gpio_h)
#define GPIOI (&s_gpio_i)

#define GPIO_PIN_0  ((uint16_t)0x0001u)
#define GPIO_PIN_1  ((uint16_t)0x0002u)
#define GPIO_PIN_2  ((uint16_t)0x0004u)
#define GPIO_PIN_3  ((uint16_t)0x0008u)
#define GPIO_PIN_4  ((uint16_t)0x0010u)
#define GPIO_PIN_5  ((uint16_t)0x0020u)
#define GPIO_PIN_6  ((uint16_t)0x0040u)
#define GPIO_PIN_7  ((uint16_t)0x0080u)
#define GPIO_PIN_8  ((uint16_t)0x0100u)
#define GPIO_PIN_9  ((uint16_t)0x0200u)
#define GPIO_PIN_10 ((uint16_t)0x0400u)
#define GPIO_PIN_11 ((uint16_t)0x0800u)
#define GPIO_PIN_12 ((uint16_t)0x1000u)
#define GPIO_PIN_13 ((uint16_t)0x2000u)
#define GPIO_PIN_14 ((uint16_t)0x4000u)
#define GPIO_PIN_15 ((uint16_t)0x8000u)

#define GPIO_PIN_RESET 0u
#define GPIO_PIN_SET   1u

#define TIM_CHANNEL_1  0x00000001u

typedef struct {
    GPIO_TypeDef *port;
    uint16_t pin;
    uint32_t state;
} GpioWriteCall;

typedef struct {
    TIM_HandleTypeDef *htim;
    uint32_t channel;
    uint32_t compare_value;
} TimCompareCall;

#define MAX_CAPTURED_HAL_CALLS 32

static GpioWriteCall s_gpio_write_calls[MAX_CAPTURED_HAL_CALLS];
static TimCompareCall s_tim_compare_calls[MAX_CAPTURED_HAL_CALLS];
static uint32_t s_gpio_write_call_count;
static uint32_t s_tim_compare_call_count;
static uint32_t s_update_motor_control_calls;

static void CaptureTimSetCompare(TIM_HandleTypeDef *htim, uint32_t channel, uint32_t compare_value);
void HAL_GPIO_WritePin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, uint32_t PinState);

#define __HAL_TIM_SET_COMPARE(htim, channel, compare) \
    CaptureTimSetCompare((htim), (channel), (compare))

#include "../../../firmware/Core/Src/dc_motor.c"

TX_MUTEX g_speedDataMutex;
TX_EVENT_FLAGS_GROUP g_eventFlags;
TX_QUEUE g_queueSpeedCmd;
TX_QUEUE g_queueSteerCmd;
TX_MUTEX g_motorMutex;
TX_MUTEX g_emergencyMutex;
bool g_emergencyBrake;
int16_t g_currentPWM;
float g_currentSpeed;
float g_vehicleSpeed;
uint16_t g_targetSpeed;
MotorControlState g_motorControlState;

I2C_HandleTypeDef hi2c3;
UART_HandleTypeDef huart1;

TIM_HandleTypeDef htim4;
TIM_HandleTypeDef htim8;
TIM_HandleTypeDef htim16;

void Error_Handler(void)
{
}

void UpdateMotorControl(void)
{
    s_update_motor_control_calls++;
}

void HAL_GPIO_WritePin(GPIO_TypeDef *GPIOx, uint16_t GPIO_Pin, uint32_t PinState)
{
    if (s_gpio_write_call_count < MAX_CAPTURED_HAL_CALLS) {
        s_gpio_write_calls[s_gpio_write_call_count].port = GPIOx;
        s_gpio_write_calls[s_gpio_write_call_count].pin = GPIO_Pin;
        s_gpio_write_calls[s_gpio_write_call_count].state = PinState;
        s_gpio_write_call_count++;
    }
}

static void CaptureTimSetCompare(TIM_HandleTypeDef *htim, uint32_t channel, uint32_t compare_value)
{
    if (s_tim_compare_call_count < MAX_CAPTURED_HAL_CALLS) {
        s_tim_compare_calls[s_tim_compare_call_count].htim = htim;
        s_tim_compare_calls[s_tim_compare_call_count].channel = channel;
        s_tim_compare_calls[s_tim_compare_call_count].compare_value = compare_value;
        s_tim_compare_call_count++;
    }
}

static jmp_buf s_dc_motor_loop_exit;
static t_can_message s_dc_motor_queued_message;

static UINT TxEventFlagsGetSuccessCallback(TX_EVENT_FLAGS_GROUP *group_ptr,
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

static UINT TxEventFlagsGetNoEventsCallback(TX_EVENT_FLAGS_GROUP *group_ptr,
                                            ULONG requested_flags,
                                            UINT get_option,
                                            ULONG *actual_flags,
                                            ULONG wait_option,
                                            int cmock_num_calls)
{
    (void)group_ptr;
    (void)requested_flags;
    (void)get_option;
    (void)actual_flags;
    (void)wait_option;
    (void)cmock_num_calls;
    return 1u;
}

static UINT TxQueueReceiveOnceCallback(TX_QUEUE *queue_ptr,
                                       void *destination_ptr,
                                       ULONG wait_option,
                                       int cmock_num_calls)
{
    (void)queue_ptr;
    (void)wait_option;

    if (cmock_num_calls == 0) {
        memcpy(destination_ptr, &s_dc_motor_queued_message, sizeof(t_can_message));
        return TX_SUCCESS;
    }

    return 1u;
}

static UINT TxThreadSleepBreakCallback(ULONG timer_ticks, int cmock_num_calls)
{
    (void)cmock_num_calls;
    TEST_ASSERT_EQUAL_UINT32((ULONG)10, timer_ticks);
    longjmp(s_dc_motor_loop_exit, 1);
    return TX_SUCCESS;
}

void setUp(void)
{
    memset(&g_motorControlState, 0, sizeof(g_motorControlState));
    memset(&s_dc_motor_queued_message, 0, sizeof(s_dc_motor_queued_message));
    memset(s_gpio_write_calls, 0, sizeof(s_gpio_write_calls));
    memset(s_tim_compare_calls, 0, sizeof(s_tim_compare_calls));

    s_gpio_write_call_count = 0;
    s_tim_compare_call_count = 0;
    s_update_motor_control_calls = 0;
    g_targetSpeed = 0;
}

void tearDown(void)
{
}

void test_MoveMotors_ShouldSetForwardDirectionAndPwm(void)
{
    MoveMotors(500u, true);

    TEST_ASSERT_EQUAL_UINT32(2u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_PTR(&htim4, s_tim_compare_calls[0].htim);
    TEST_ASSERT_EQUAL_UINT32(TIM_CHANNEL_1, s_tim_compare_calls[0].channel);
    TEST_ASSERT_EQUAL_UINT32(500u, s_tim_compare_calls[0].compare_value);
    TEST_ASSERT_EQUAL_PTR(&htim16, s_tim_compare_calls[1].htim);
    TEST_ASSERT_EQUAL_UINT32(TIM_CHANNEL_1, s_tim_compare_calls[1].channel);
    TEST_ASSERT_EQUAL_UINT32(500u, s_tim_compare_calls[1].compare_value);

    TEST_ASSERT_EQUAL_UINT32(4u, s_gpio_write_call_count);
    TEST_ASSERT_EQUAL_PTR(GPIOE, s_gpio_write_calls[0].port);
    TEST_ASSERT_EQUAL_UINT16(AIN1_Pin, s_gpio_write_calls[0].pin);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[0].state);
    TEST_ASSERT_EQUAL_PTR(GPIOD, s_gpio_write_calls[1].port);
    TEST_ASSERT_EQUAL_UINT16(AIN2_Pin, s_gpio_write_calls[1].pin);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[1].state);
    TEST_ASSERT_EQUAL_PTR(GPIOD, s_gpio_write_calls[2].port);
    TEST_ASSERT_EQUAL_UINT16(BIN1_Pin, s_gpio_write_calls[2].pin);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[2].state);
    TEST_ASSERT_EQUAL_PTR(GPIOD, s_gpio_write_calls[3].port);
    TEST_ASSERT_EQUAL_UINT16(BIN2_Pin, s_gpio_write_calls[3].pin);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[3].state);
}

void test_MoveMotors_ShouldSetReverseDirectionAndPwm(void)
{
    MoveMotors(321u, false);

    TEST_ASSERT_EQUAL_UINT32(2u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(321u, s_tim_compare_calls[0].compare_value);
    TEST_ASSERT_EQUAL_UINT32(321u, s_tim_compare_calls[1].compare_value);

    TEST_ASSERT_EQUAL_UINT32(4u, s_gpio_write_call_count);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[0].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[1].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[2].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[3].state);
}

void test_MoveMotors_ShouldClampSpeedAt665(void)
{
    MoveMotors(900u, true);

    TEST_ASSERT_EQUAL_UINT32(2u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(665u, s_tim_compare_calls[0].compare_value);
    TEST_ASSERT_EQUAL_UINT32(665u, s_tim_compare_calls[1].compare_value);
}

void test_MotorCoast_ShouldResetAllPinsAndDisablePwm(void)
{
    MotorCoast();

    TEST_ASSERT_EQUAL_UINT32(4u, s_gpio_write_call_count);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[0].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[1].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[2].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[3].state);

    TEST_ASSERT_EQUAL_UINT32(2u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(0u, s_tim_compare_calls[0].compare_value);
    TEST_ASSERT_EQUAL_UINT32(0u, s_tim_compare_calls[1].compare_value);
}

void test_StopMotors_ShouldSetBrakeStateAndMaxPwm(void)
{
    StopMotors();

    TEST_ASSERT_EQUAL_UINT32(4u, s_gpio_write_call_count);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[0].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[1].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[2].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[3].state);

    TEST_ASSERT_EQUAL_UINT32(2u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(665u, s_tim_compare_calls[0].compare_value);
    TEST_ASSERT_EQUAL_UINT32(665u, s_tim_compare_calls[1].compare_value);
}

void test_DcMotor_ShouldProcessSpeedMessageAndTriggerControlUpdate(void)
{
    int16_t speed = 120;
    int32_t direction = FORWARD;

    memcpy(s_dc_motor_queued_message.data, &speed, sizeof(speed));
    memcpy(s_dc_motor_queued_message.data + sizeof(int32_t), &direction, sizeof(direction));

    tx_event_flags_get_StubWithCallback(TxEventFlagsGetSuccessCallback);
    tx_queue_receive_StubWithCallback(TxQueueReceiveOnceCallback);
    tx_thread_sleep_StubWithCallback(TxThreadSleepBreakCallback);

    if (setjmp(s_dc_motor_loop_exit) == 0) {
        DcMotor(0);
    }

    TEST_ASSERT_EQUAL_UINT16((uint16_t)120u, g_targetSpeed);
    TEST_ASSERT_EQUAL_INT32(FORWARD, g_motorControlState.direction);
    TEST_ASSERT_EQUAL_UINT32(1u, s_update_motor_control_calls);
}

void test_DcMotor_ShouldProcessReverseMessageAndTriggerControlUpdate(void)
{
    int16_t speed = 95;
    int32_t direction = REVERSE;

    memcpy(s_dc_motor_queued_message.data, &speed, sizeof(speed));
    memcpy(s_dc_motor_queued_message.data + sizeof(int32_t), &direction, sizeof(direction));

    tx_event_flags_get_StubWithCallback(TxEventFlagsGetSuccessCallback);
    tx_queue_receive_StubWithCallback(TxQueueReceiveOnceCallback);
    tx_thread_sleep_StubWithCallback(TxThreadSleepBreakCallback);

    if (setjmp(s_dc_motor_loop_exit) == 0) {
        DcMotor(0);
    }

    TEST_ASSERT_EQUAL_UINT16((uint16_t)95u, g_targetSpeed);
    TEST_ASSERT_EQUAL_INT32(REVERSE, g_motorControlState.direction);
    TEST_ASSERT_EQUAL_UINT32(1u, s_update_motor_control_calls);
}

void test_DcMotor_ShouldCoastWhenDirectionIsNeutral(void)
{
    g_motorControlState.direction = NEUTRAL;

    tx_event_flags_get_StubWithCallback(TxEventFlagsGetNoEventsCallback);
    tx_mutex_get_ExpectAndReturn(&g_motorMutex, TX_WAIT_FOREVER, TX_SUCCESS);
    tx_mutex_put_ExpectAndReturn(&g_motorMutex, TX_SUCCESS);
    tx_thread_sleep_StubWithCallback(TxThreadSleepBreakCallback);

    if (setjmp(s_dc_motor_loop_exit) == 0) {
        DcMotor(0);
    }

    TEST_ASSERT_EQUAL_UINT32(4u, s_gpio_write_call_count);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[0].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[1].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[2].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_RESET, s_gpio_write_calls[3].state);
    TEST_ASSERT_EQUAL_UINT32(2u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(0u, s_tim_compare_calls[0].compare_value);
    TEST_ASSERT_EQUAL_UINT32(0u, s_tim_compare_calls[1].compare_value);
}

void test_DcMotor_ShouldBrakeWhenDirectionIsNotForwardReverseOrNeutral(void)
{
    g_motorControlState.direction = BRAKE;

    tx_event_flags_get_StubWithCallback(TxEventFlagsGetNoEventsCallback);
    tx_mutex_get_ExpectAndReturn(&g_motorMutex, TX_WAIT_FOREVER, TX_SUCCESS);
    tx_mutex_put_ExpectAndReturn(&g_motorMutex, TX_SUCCESS);
    tx_thread_sleep_StubWithCallback(TxThreadSleepBreakCallback);

    if (setjmp(s_dc_motor_loop_exit) == 0) {
        DcMotor(0);
    }

    TEST_ASSERT_EQUAL_UINT32(4u, s_gpio_write_call_count);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[0].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[1].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[2].state);
    TEST_ASSERT_EQUAL_UINT32(GPIO_PIN_SET, s_gpio_write_calls[3].state);
    TEST_ASSERT_EQUAL_UINT32(2u, s_tim_compare_call_count);
    TEST_ASSERT_EQUAL_UINT32(665u, s_tim_compare_calls[0].compare_value);
    TEST_ASSERT_EQUAL_UINT32(665u, s_tim_compare_calls[1].compare_value);
}
