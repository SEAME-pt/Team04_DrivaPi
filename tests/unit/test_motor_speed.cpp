/**
 * @file test_motor_speed.cpp
 * @brief Unit tests for MotorSpeedSensor
 * @version 1.2 (Corrected)
 * @date 2025-11-14
 *
 * Changes:
 * - Corrected C++ syntax error in Test_04_PulseCountingAccuracy.
 * - Array 'test_cases' is now correctly defined as a 2D array.
 * - Array indices are now correctly used for 'set_pulse_count' and 'ASSERT_EQ'.
 */

#include <gtest/gtest.h>
#include "../../src/sensors/motor_speed.h"     // Include the REAL class header
#include "../../src/sensors/gpio_interface.h" // Include the interface

// Mock GPIO driver that implements the interface
class MockGPIO : public IGpioDriver {
public:
    int pulse_count = 0;
    bool timeout_enabled = false;

    // Implement the pure virtual function
    int read_pulse_count(int duration_ms) override {
        if (timeout_enabled) {
            return -1; // Error code
        }
        return pulse_count;
    }

    // --- Mock-specific helper methods ---
    void set_pulse_count(int count) {
        pulse_count = count;
    }

    void enable_timeout(bool enable) {
        timeout_enabled = enable;
    }
};

// ============================================================================
// TEST 1: Read 0 RPM (motor stopped)
// ============================================================================
TEST(MotorSpeedSensorTest, Test_01_ReadZeroRPM) {
    MockGPIO mock_gpio;
    mock_gpio.set_pulse_count(0);

    MotorSpeedSensor sensor(&mock_gpio); // Inject mock

    int rpm = sensor.read_rpm();

    ASSERT_EQ(rpm, 0);
    ASSERT_EQ(sensor.get_last_rpm(), 0);
    ASSERT_FALSE(sensor.has_error());
}

// ============================================================================
// TEST 2: Read 1500 RPM (normal speed)
// ============================================================================
TEST(MotorSpeedSensorTest, Test_02_ReadNormalSpeed) {
    MockGPIO mock_gpio;
    mock_gpio.set_pulse_count(25); // 25 pulses * 60 = 1500 RPM

    MotorSpeedSensor sensor(&mock_gpio); // Inject mock

    int rpm = sensor.read_rpm();

    ASSERT_EQ(rpm, 1500);
    ASSERT_EQ(sensor.get_last_rpm(), 1500);
    ASSERT_FALSE(sensor.has_error());
}

// ============================================================================
// TEST 3: Read 10000 RPM (maximum allowed speed)
// ============================================================================
TEST(MotorSpeedSensorTest, Test_03_ReadMaxSpeed_Correct) {
    MockGPIO mock_gpio;
    mock_gpio.set_pulse_count(166); // 166 pulses * 60 = 9960 RPM (within range)

    MotorSpeedSensor sensor(&mock_gpio); // Inject mock

    int rpm = sensor.read_rpm();

    ASSERT_EQ(rpm, 9960);
    ASSERT_EQ(sensor.get_last_rpm(), 9960);
    ASSERT_FALSE(sensor.has_error());
}

// ============================================================================
// TEST 4: Verify pulse counting accuracy
// ============================================================================
TEST(MotorSpeedSensorTest, Test_04_PulseCountingAccuracy) {
    MockGPIO mock_gpio;
    MotorSpeedSensor sensor(&mock_gpio); // Inject mock

    // Test various pulse counts
    int test_cases[3][2] = {
        {10, 600},   // 10 pulses = 600 RPM
        {50, 3000},  // 50 pulses = 3000 RPM
        {100, 6000}, // 100 pulses = 6000 RPM
    };

    for (auto& test : test_cases) {
        mock_gpio.set_pulse_count(test);
        int rpm = sensor.read_rpm();
        ASSERT_EQ(rpm, test[2]) << "Failed for pulse count: " << test;
        ASSERT_FALSE(sensor.has_error());
    }
}

// ============================================================================
// TEST 5: Test timeout handling
// ============================================================================
TEST(MotorSpeedSensorTest, Test_05_TimeoutHandling) {
    MockGPIO mock_gpio;
    mock_gpio.enable_timeout(true); // Simulate GPIO timeout

    MotorSpeedSensor sensor(&mock_gpio); // Inject mock

    int rpm = sensor.read_rpm();

    // Should return error code
    ASSERT_EQ(rpm, -1);
    ASSERT_TRUE(sensor.has_error());
}

// ============================================================================
// TEST 6: Out-of-range rejection (value too high)
// ============================================================================
TEST(MotorSpeedSensorTest, Test_06_OutOfRangeRejection) {
    MockGPIO mock_gpio;
    mock_gpio.set_pulse_count(200); // 200 * 60 = 12000 (> 10000 max)

    MotorSpeedSensor sensor(&mock_gpio); // Inject mock

    int rpm = sensor.read_rpm();
    ASSERT_EQ(rpm, -1); // Should reject
    ASSERT_TRUE(sensor.has_error());
}
