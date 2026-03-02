#include "main.h"
#include "mock_stm32u5xx_hal.h"
#include "mock_tx_api.h"

/* --- GLOBAL VARIABLES --- */
TX_MUTEX g_speedDataMutex;
TX_EVENT_FLAGS_GROUP g_eventFlags;
TX_QUEUE g_queueSpeedCmd;
TX_QUEUE g_queueSteerCmd;

float g_vehicleSpeed = 0.0f;

/* --- FAKE HARDWARE --- */
TIM_HandleTypeDef htim1;
UART_HandleTypeDef huart1;
TIM_TypeDef fake_tim1_registers;

/* --- INCLUDE SOURCE FILE DIRECTLY --- */
#include "../../../firmware/Core/Src/speed_sensor.c"

/* --- TEST INFRASTRUCTURE --- */
static jmp_buf test_break_jump;
static int s_canSendCallCount;
static t_can_message s_lastCanSendMessage;

/* Stub for Error_Handler */
void Error_Handler(void) {
    // No-op for tests
}

int CanSend(t_can_message* msg)
{
    s_canSendCallCount++;
    if (msg != NULL)
    {
        memcpy(&s_lastCanSendMessage, msg, sizeof(t_can_message));
    }
    return 0;
}

// --------------------------------------------------------
// SETUP & TEARDOWN
// --------------------------------------------------------

void setUp(void)
{
    // Reset the fake hardware registers to 0 before every test
    memset(&fake_tim1_registers, 0, sizeof(TIM_TypeDef));

    // Point the HAL handle to our fake registers
    // Now, when your code reads htim1.Instance->CNT, it reads our variable!
    htim1.Instance = &fake_tim1_registers;

    // Reset static variables in your function if possible.
    // Note: Since 'ReadSpeedSensor' has statics, unit testing it repeatedly
    // requires either resetting the system or adding a 'reset_sensor()' helper function
    // to your source code. For these tests, we assume a fresh start or we manage logic carefully.
    s_canSendCallCount = 0;
    memset(&s_lastCanSendMessage, 0, sizeof(s_lastCanSendMessage));
}

/**
 * Stub: Breaks the loop only on the SECOND call.
 * This forces the while(1) loop to iterate once fully, ensuring coverage.
 */
UINT Stub_BreakLoop_OnSecondCall(TX_EVENT_FLAGS_GROUP *group_ptr, ULONG flags_to_set, UINT set_option, int cmock_num_calls)
{
    // If this is the second time we are called (Index 1), break the loop.
    if (cmock_num_calls == 1)
    {
        longjmp(test_break_jump, 1);
    }

    // Otherwise (Index 0), just pretend we set the flags successfully
    return TX_SUCCESS;
}

UINT Stub_BreakLoop_OnSecondCallAndMoveCounter(TX_EVENT_FLAGS_GROUP *group_ptr, ULONG flags_to_set, UINT set_option, int cmock_num_calls)
{
    (void)group_ptr;
    (void)flags_to_set;
    (void)set_option;

    if (cmock_num_calls == 0)
    {
        fake_tim1_registers.CNT = 1030;
        return TX_SUCCESS;
    }

    longjmp(test_break_jump, 1);
    return TX_SUCCESS;
}

void tearDown(void)
{
}

static jmp_buf test_break_jump;

/**
 * Custom Stub: Pretends to set event flags, but actually breaks the loop
 * by jumping back to the test function.
 */
UINT Stub_BreakLoop_tx_event_flags_set(TX_EVENT_FLAGS_GROUP *group_ptr, ULONG flags_to_set, UINT set_option, int cmock_num_calls)
{
    // You can add assertions here if you want to verify the flags
    // TEST_ASSERT_EQUAL(FLAG_SENSOR_UPDATE, flags_to_set);

    // Jump back to the point where setjmp was called
    longjmp(test_break_jump, 1);

    return TX_SUCCESS; // This line is never reached
}

// --------------------------------------------------------
// UNIT TESTS
// --------------------------------------------------------

/**
 * Test: First Run Initialization
 * Expected: The first time we call the function, it should just store the baseline
 * values and return 0.0 speed.
 */
void test_ReadSpeedSensor_FirstRun_Should_ReturnZero(void)
{
    // 1. Setup Data
    fake_tim1_registers.CNT = 1000; // Random starting count

    // 2. Expect Calls
    // We expect the code to ask for time. We return tick 100.
    tx_time_get_ExpectAndReturn(100);

    // 3. Execute
    float speed = ReadSpeedSensor();

    // 4. Verify
    TEST_ASSERT_EQUAL_FLOAT(0.0f, speed);
}

/**
 * Test: Normal Movement
 * Context:
 * - 30 pulses (1 revolution)
 * - 1 second (1000 ticks) duration
 * - Wheel perimeter = 0.212m
 * Expected Result: 0.212 m/s
 */
void test_ReadSpeedSensor_StandardMovement_Should_CalculateCorrectSpeed(void)
{
    // --- STEP 1: First Run (Initialize Baseline) ---
    fake_tim1_registers.CNT = 1000;
    tx_time_get_ExpectAndReturn(1000); // Time = 1000ms
    ReadSpeedSensor(); // Returns 0, sets last_count=1000, last_time=1000

    // --- STEP 2: Second Run (The actual test) ---
    // Advance Time by 1000 ticks (1 second)
    tx_time_get_ExpectAndReturn(2000);

    // Advance Pulse Counter by 30 (1 Rev)
    fake_tim1_registers.CNT = 1030;

    // Execute
    float speed = ReadSpeedSensor();

    // Verify
    // 30 pulses / 30 pulses_per_rev = 1 rev
    // 1 rev * 0.212m = 0.212m
    // Time = 1s
    // Speed = 0.212 m/s
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 0.212f, speed);
}

/**
 * Test: No Movement
 * Context: Time passes, but CNT remains the same.
 */
void test_ReadSpeedSensor_NoMovement_Should_ReturnZero(void)
{
    // --- Baseline ---
    fake_tim1_registers.CNT = 5000;
    tx_time_get_ExpectAndReturn(10000);
    ReadSpeedSensor();

    // --- Test Run ---
    tx_time_get_ExpectAndReturn(11000); // 1 sec later
    fake_tim1_registers.CNT = 5000;     // Count unchanged

    float speed = ReadSpeedSensor();

    TEST_ASSERT_EQUAL_FLOAT(0.0f, speed);
}

/**
 * Test: Timer Overflow (Wrap Around)
 * Context:
 * - Timer is 16-bit (65535 max)
 * - Previous Count: 65500
 * - Current Count: 20
 * - Expected Pulses: (65535 - 65500) + 20 + 1 = 56 pulses
 * - Time delta: 1 second
 */
void test_ReadSpeedSensor_TimerOverflow_Should_CalculatePulsesCorrectly(void)
{
    // --- Baseline ---
    fake_tim1_registers.CNT = 65500;
    tx_time_get_ExpectAndReturn(1000);
    ReadSpeedSensor();

    // --- Test Run ---
    tx_time_get_ExpectAndReturn(2000); // 1 sec later
    fake_tim1_registers.CNT = 20;      // Wrapped around

    float speed = ReadSpeedSensor();

    // Verify Math
    // Pulses = 56
    // Rotations = 56 / 30 = 1.8666...
    // Distance = 1.8666 * 0.212 = 0.39573m
    // Speed = 0.39573 m/s
    TEST_ASSERT_FLOAT_WITHIN(0.001f, 0.3957f, speed);
}

/**
 * Test: Very Small Time Delta (Divide by Zero protection)
 * Context: Code has `if (dt <= 0.001f) return 0.0f;`
 */
void test_ReadSpeedSensor_SmallTimeDelta_Should_ReturnZero(void)
{
    // --- Baseline ---
    fake_tim1_registers.CNT = 1000;
    tx_time_get_ExpectAndReturn(1000);
    ReadSpeedSensor();

    // --- Test Run ---
    // Only 1 tick passed (0.001s), or 0 ticks
    tx_time_get_ExpectAndReturn(1001);
    fake_tim1_registers.CNT = 1050; // Huge movement, but tiny time

    float speed = ReadSpeedSensor();

    TEST_ASSERT_EQUAL_FLOAT(0.0f, speed);
}



// --------------------------------------------------------
// HAPPY PATH SCENARIOS
// --------------------------------------------------------

// Helper to convert km/h to m/s for assertions
#define KMH_TO_MPS(kmh) ((kmh) / 3.6f)

/**
 * Test: 10 km/h Speed
 * Math: 10 Revs (300 pulses) over 763 ticks (0.763s) should equal ~10km/h
 */
void test_Speed_10kmh(void)
{
    // 1. Setup Baseline
    fake_tim1_registers.CNT = 1000;
    tx_time_get_ExpectAndReturn(1000);
    ReadSpeedSensor(); // Init

    // 2. Setup Movement (10 km/h simulation)
    // Ticks = 763
    // Pulses = 300 (10 revs)
    tx_time_get_ExpectAndReturn(1000 + 763);
    fake_tim1_registers.CNT = 1000 + 300;

    // 3. Execute
    float speed = ReadSpeedSensor();

    // 4. Verify
    // We allow a slightly larger tolerance because of integer tick rounding
    TEST_ASSERT_FLOAT_WITHIN(0.1f, KMH_TO_MPS(10.0f), speed);
}

/**
 * Test: 50 km/h Speed
 * Math: 10 Revs (300 pulses) over 153 ticks should equal ~50km/h
 */
void test_Speed_50kmh(void)
{
    // 1. Setup Baseline
    fake_tim1_registers.CNT = 2000;
    tx_time_get_ExpectAndReturn(5000);
    ReadSpeedSensor(); // Init

    // 2. Setup Movement (50 km/h simulation)
    // Ticks = 153
    // Pulses = 300
    tx_time_get_ExpectAndReturn(5000 + 153);
    fake_tim1_registers.CNT = 2000 + 300;

    // 3. Execute
    float speed = ReadSpeedSensor();

    // 4. Verify
    TEST_ASSERT_FLOAT_WITHIN(0.5f, KMH_TO_MPS(50.0f), speed);
}

/**
 * Test: 100 km/h Speed
 * Math: 10 Revs (300 pulses) over 76 ticks should equal ~100km/h
 */
void test_Speed_100kmh(void)
{
    // 1. Setup Baseline
    fake_tim1_registers.CNT = 5000;
    tx_time_get_ExpectAndReturn(10000);
    ReadSpeedSensor(); // Init

    // 2. Setup Movement (100 km/h simulation)
    // Ticks = 76
    // Pulses = 300
    tx_time_get_ExpectAndReturn(10000 + 76);
    fake_tim1_registers.CNT = 5000 + 300;

    // 3. Execute
    float speed = ReadSpeedSensor();

    // 4. Verify
    // At high speeds, 1 tick difference has a huge impact on calculated speed.
    // 76 ticks = 100.4 km/h
    // 77 ticks = 99.1 km/h
    // So we need a tolerance of ~1.0 m/s (~3.6 km/h) or we need to simulate more pulses.
    TEST_ASSERT_FLOAT_WITHIN(1.0f, KMH_TO_MPS(100.0f), speed);
}


// --------------------------------------------------------
// Zero Speed & Timeout
// --------------------------------------------------------

/**
 * Test: Stationary / Timeout Condition
 * Requirement: If significant time passes (Period > Threshold) with 0 pulses,
 * return 0.0 speed.
 * * Note: In this specific implementation, "Timeout" is effectively the sampling
 * interval. If count doesn't change between calls, speed is 0.
 */
void test_Speed_Zero_Timeout(void)
{
    // 1. Setup Baseline (Last state)
    fake_tim1_registers.CNT = 5000;
    tx_time_get_ExpectAndReturn(1000);
    ReadSpeedSensor(); // Init

    // 2. Simulate "Timeout"
    // Advance time significantly (e.g., 2 seconds / 2000 ticks)
    // But keep CNT the same (Car is stopped)
    tx_time_get_ExpectAndReturn(1000 + 2000);
    fake_tim1_registers.CNT = 5000;

    // 3. Execute
    float speed = ReadSpeedSensor();

    // 4. Verify
    // - Should return exactly 0.0
    TEST_ASSERT_EQUAL_FLOAT(0.0f, speed);
}

/**
 * Test: Division by Zero Safety
 * Requirement: Ensure that if the function is called too quickly (dt approx 0),
 * it does not crash or return infinity.
 */
void test_Speed_Protection_Against_Tiny_TimeDelta(void)
{
    // 1. Setup Baseline
    fake_tim1_registers.CNT = 1000;
    tx_time_get_ExpectAndReturn(1000);
    ReadSpeedSensor();

    // 2. Call again immediately (0 ticks elapsed)
    // This forces 'dt' to be 0.0
    tx_time_get_ExpectAndReturn(1000);
    fake_tim1_registers.CNT = 1000;

    // 3. Execute
    float speed = ReadSpeedSensor();

    // 4. Verify safety
    // Code has: if (dt <= 0.001f) return 0.0f;
    TEST_ASSERT_EQUAL_FLOAT(0.0f, speed);
}

void test_DetermineRNDGear_ShouldReturnDrive_WhenSpeedAboveDeadzoneAndPositivePwm(void)
{
    RNDGear_t gear = DetermineRNDGear(1.0f, 100);
    TEST_ASSERT_EQUAL_INT(GEAR_DRIVE, gear);
}

void test_DetermineRNDGear_ShouldReturnReverse_WhenSpeedAboveDeadzoneAndNegativePwm(void)
{
    RNDGear_t gear = DetermineRNDGear(1.0f, -100);
    TEST_ASSERT_EQUAL_INT(GEAR_REVERSE, gear);
}

void test_DetermineRNDGear_ShouldReturnNeutral_WhenSpeedAboveDeadzoneAndZeroPwm(void)
{
    RNDGear_t gear = DetermineRNDGear(1.0f, 0);
    TEST_ASSERT_EQUAL_INT(GEAR_NEUTRAL, gear);
}

/**
 * Test: Speed Sensor Thread Entry
 * Context:
 * - Initializes hardware (Stop/Start Timer)
 * - Enters infinite loop
 * - Reads registers, prints debug, sleeps
 * - Calls ReadSpeedSensor()
 * - Updates global variable protected by Mutex
 * - Sets Event Flags -> [WE BREAK LOOP HERE]
 */
void test_SpeedSensor_Thread_Should_LoopTwice(void)
{
    // ... Setup code ...
    fake_tim1_registers.CNT = 500;
    HAL_TIM_Base_Stop_ExpectAndReturn(&htim1, HAL_OK);
    HAL_TIM_Base_Start_ExpectAndReturn(&htim1, HAL_OK);
    HAL_UART_Transmit_IgnoreAndReturn(HAL_OK);

    // --- PASS 1 ---
    tx_thread_sleep_ExpectAndReturn(100, TX_SUCCESS);
    tx_time_get_ExpectAndReturn(1000);
    tx_mutex_get_ExpectAndReturn(&g_speedDataMutex, TX_WAIT_FOREVER, TX_SUCCESS);
    tx_mutex_put_ExpectAndReturn(&g_speedDataMutex, TX_SUCCESS);

    // [CRITICAL] NO tx_event_flags_set_Expect HERE! Delete it if it exists.

    // --- PASS 2 ---
    tx_thread_sleep_ExpectAndReturn(100, TX_SUCCESS);
    tx_time_get_ExpectAndReturn(1100);
    tx_mutex_get_ExpectAndReturn(&g_speedDataMutex, TX_WAIT_FOREVER, TX_SUCCESS);
    tx_mutex_put_ExpectAndReturn(&g_speedDataMutex, TX_SUCCESS);

    // --- Stub Register ---
    // This handles ALL calls. It doesn't check arguments unless you code it to.
    tx_event_flags_set_Stub(Stub_BreakLoop_OnSecondCall);

    // --- Execute ---
    if (setjmp(test_break_jump) == 0)
    {
        SpeedSensor(0);
        TEST_FAIL_MESSAGE("Loop did not break!");
    }
}

void test_SpeedSensor_ShouldSendCanGearMessage_WhenGearChanges(void)
{
    fake_tim1_registers.CNT = 1000;
    g_current_pwm = 500;

    HAL_TIM_Base_Stop_ExpectAndReturn(&htim1, HAL_OK);
    HAL_TIM_Base_Start_ExpectAndReturn(&htim1, HAL_OK);

    tx_thread_sleep_ExpectAndReturn(100, TX_SUCCESS);
    tx_time_get_ExpectAndReturn(1000);
    tx_mutex_get_ExpectAndReturn(&g_speedDataMutex, TX_WAIT_FOREVER, TX_SUCCESS);
    tx_mutex_put_ExpectAndReturn(&g_speedDataMutex, TX_SUCCESS);

    tx_thread_sleep_ExpectAndReturn(100, TX_SUCCESS);
    tx_time_get_ExpectAndReturn(2000);
    tx_mutex_get_ExpectAndReturn(&g_speedDataMutex, TX_WAIT_FOREVER, TX_SUCCESS);
    tx_mutex_put_ExpectAndReturn(&g_speedDataMutex, TX_SUCCESS);

    tx_event_flags_set_Stub(Stub_BreakLoop_OnSecondCallAndMoveCounter);

    if (setjmp(test_break_jump) == 0)
    {
        SpeedSensor(0);
        TEST_FAIL_MESSAGE("Loop did not break!");
    }

    TEST_ASSERT_EQUAL_INT(1, s_canSendCallCount);
    TEST_ASSERT_EQUAL_UINT32(CAN_ID_RND_GEAR, s_lastCanSendMessage.id);
    TEST_ASSERT_EQUAL_UINT8(1, s_lastCanSendMessage.len);
    TEST_ASSERT_EQUAL_UINT8((uint8_t)GEAR_DRIVE, s_lastCanSendMessage.data[0]);
}

