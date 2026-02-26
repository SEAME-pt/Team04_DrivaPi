/* USER CODE BEGIN Header */
/**
******************************************************************************
* @file           : i2c_integration_test.c
* @brief          : Integration tests for I2C motor controller communication
* @description    : Tests Phase C - STM32 → Motor Controllers (I2C)
*                   Validates I2C communication with throttle (0x60) and
*                   steering (0x40) PCA9685 motor controllers
******************************************************************************
*/
/* USER CODE END Header */

#include "../Inc/i2c_integration_test.h"

static inline uint16_t ClampU16(int32_t computedValue)
{
	if (computedValue < 0)
		return 0;
	if (computedValue >= (int32_t)PCA9685_COUNTS) 
		return (uint16_t)(PCA9685_COUNTS - 1u);
	return (uint16_t)computedValue;
}

HAL_StatusTypeDef MotorLeft(double speed)
{
	const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);
	uint16_t pwm_val = ClampU16((int32_t)(speed * (double)max + 0.5));

	HAL_StatusTypeDef status = HAL_OK;
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, max);
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, 0);
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, 0);
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, max);
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);

	return status;
}

/**
* @brief Move motors right
*
* @param speed Motor speed (0.0 to 1.0)
* @return HAL_StatusTypeDef Status of I2C operations
*/
HAL_StatusTypeDef MotorRight(double speed)
{
	const uint16_t max = (uint16_t)(PCA9685_COUNTS - 1u);
	uint16_t pwm_val = ClampU16((int32_t)(speed * (double)max + 0.5));

	HAL_StatusTypeDef status = HAL_OK;
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_A, 0, 0);
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_B, 0, max);
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_L_PWM, 0, pwm_val);

	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_A, 0, max);
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_B, 0, 0);
	status |= PCA9685_SetPWM(PCA9685_ADDR_MOTOR, MOTOR_R_PWM, 0, pwm_val);

	return status;
}


/* Test result counters */
static uint32_t tests_passed = 0;
static uint32_t tests_failed = 0;

/**
 * @brief Reset test counters and buffer
 */
static void ResetTestCounters(void)
{
    tests_passed = 0;
    tests_failed = 0;
}

/**
 * @brief Log test result to buffer and UART
 */
static void LogTestResult(const char* test_name, HAL_StatusTypeDef status, HAL_StatusTypeDef expected)
{
    if (status == expected)
    {
        UartPrintf("✅ PASS: %s (status=%d)\r\n", test_name, status);
        tests_passed++;
    }
    else
    {
        UartPrintf("❌ FAIL: %s (expected=%d, got=%d)\r\n", test_name, expected, status);
        tests_failed++;
    }
}

/**
 * @brief Test 1: Device Initialization
 * Verifies both motor controllers respond to initialization
 */
static void Test_DeviceInitialization(void)
{
    UartPrint("\r\n=== Test 1: Device Initialization ===\r\n");
    
    HAL_StatusTypeDef status_throttle = PCA9685_InitDevice(&hi2c3, PCA9685_ADDR_MOTOR, "Throttle");
    LogTestResult("Throttle controller (0x60) init", status_throttle, HAL_OK);
    
    HAL_StatusTypeDef status_steering = PCA9685_InitDevice(&hi2c3, 0x40, "Steering");
    LogTestResult("Steering controller (0x40) init", status_steering, HAL_OK);
}

/**
 * @brief Test 2: Throttle I2C Write + ACK
 * Sends throttle command via motor control and verifies ACK
 */
static void Test_ThrottleWriteAndAck(void)
{
    UartPrint("\r\n=== Test 2: Throttle I2C Write + ACK ===\r\n");
    
    // Test motors at 0% (stop)
    HAL_StatusTypeDef ack1 = MotorLeft(0.0);
    LogTestResult("Motor control - 0% (stop)", ack1, HAL_OK);
    SoftwareDelay(500);
    
    // Test motors at 25% forward (left turn)
    HAL_StatusTypeDef ack2 = MotorLeft(0.25);
    LogTestResult("Motor control - 25% left turn", ack2, HAL_OK);
    SoftwareDelay(500);
    
    // Test motors at 50% forward (left turn)
    HAL_StatusTypeDef ack3 = MotorLeft(0.50);
    LogTestResult("Motor control - 50% left turn", ack3, HAL_OK);
    SoftwareDelay(500);
    
    // Test motors at 50% right turn
    HAL_StatusTypeDef ack4 = MotorRight(0.50);
    LogTestResult("Motor control - 50% right turn", ack4, HAL_OK);
    SoftwareDelay(500);
    
    // Return to stop
    HAL_StatusTypeDef ack5 = MotorLeft(0.0);
    LogTestResult("Motor control - back to stop", ack5, HAL_OK);
}

/**
 * @brief Test 3: Steering I2C Write + ACK
 * Sends steering commands and verifies ACK
 */
static void Test_SteeringWriteAndAck(void)
{
    UartPrint("\r\n=== Test 3: Steering I2C Write + ACK ===\r\n");
    
    // Test center position (~1.5ms pulse = 375 counts at 50Hz)
    HAL_StatusTypeDef ack1 = PCA9685_SetPWM(0x40, 0, 0, 375);
    LogTestResult("Steering 0x40 - center position", ack1, HAL_OK);
    SoftwareDelay(100);
    
    // Test left turn (~1.0ms pulse = 250 counts)
    HAL_StatusTypeDef ack2 = PCA9685_SetPWM(0x40, 0, 0, 250);
    LogTestResult("Steering 0x40 - left turn", ack2, HAL_OK);
    SoftwareDelay(100);
    
    // Test right turn (~2.0ms pulse = 500 counts)
    HAL_StatusTypeDef ack3 = PCA9685_SetPWM(0x40, 0, 0, 500);
    LogTestResult("Steering 0x40 - right turn", ack3, HAL_OK);
    SoftwareDelay(100);
    
    // Return to center
    HAL_StatusTypeDef ack4 = PCA9685_SetPWM(0x40, 0, 0, 375);
    LogTestResult("Steering 0x40 - back to center", ack4, HAL_OK);
}

/**
 * @brief Run all I2C integration tests
 * @return 0 if all tests pass, -1 if any test fails
 */
int32_t RunI2CIntegrationTests(void)
{
    UartPrint("\r\n");
    UartPrint("╔════════════════════════════════════════════════╗\r\n");
    UartPrint("║  Phase C: STM32 → Motor Controllers (I2C)     ║\r\n");
    UartPrint("║  Integration Test Suite                       ║\r\n");
    UartPrint("╚════════════════════════════════════════════════╝\r\n");
    
    ResetTestCounters();
    
    // Run test suite
    Test_DeviceInitialization();
    Test_ThrottleWriteAndAck();
    Test_SteeringWriteAndAck();
    
    // Print summary to UART
    UartPrint("\r\n");
    UartPrint("╔════════════════════════════════════════════════╗\r\n");
    UartPrint("║  Test Summary                                  ║\r\n");
    UartPrint("╚════════════════════════════════════════════════╝\r\n");
    UartPrintf("Total Tests:  %lu\r\n", tests_passed + tests_failed);
    UartPrintf("✅ Passed:    %lu\r\n", tests_passed);
    UartPrintf("❌ Failed:    %lu\r\n", tests_failed);
    
    if (tests_failed == 0)
    {
        UartPrint("\r\n🎉 ALL TESTS PASSED! I2C integration verified.\r\n\r\n");
    }
    else
    {
        UartPrint("\r\n⚠️  SOME TESTS FAILED. Review logs above.\r\n\r\n");
    }
    
    return (tests_failed == 0) ? 0 : -1;
}
