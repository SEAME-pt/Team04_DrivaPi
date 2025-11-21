#include <gtest/gtest.h>
#include <stdint.h>
#include <thread>
#include <chrono>

// Mock GPIO interface
class MockGPIO {
public:
    int pulse_count = 0;
    bool timeout_enabled = false;

    void setup_gpio(int pin) {}
    int read_pulses(int duration_ms) {
        if (timeout_enabled) {
            return -1;  // Error code
        }
        return pulse_count;
    }
};

// Motor speed sensor implementation
class MotorSpeedSensor {
private:
    MockGPIO gpio;
    int last_rpm = 0;

public:
    MotorSpeedSensor() {
        gpio.setup_gpio(17);  // GPIO pin 17
    }

    int read_rpm() {
        int pulses = gpio.read_pulses(1000);  // 1 second window

        if (pulses < 0) {
            return -1;  // Error
        }

        // 1 pulse per revolution
        int rpm = pulses * 60;

        // Validate range (0-10000 RPM)
        if (rpm < 0 || rpm > 10000) {
            return -1;  // Out of range
        }

        last_rpm = rpm;
        return rpm;
    }

    int get_last_rpm() const {
        return last_rpm;
    }

    // Mock method for testing
    void set_pulse_count(int count) {
        gpio.pulse_count = count;
    }

    void enable_timeout(bool enable) {
        gpio.timeout_enabled = enable;
    }
};

// ============================================================================
// TEST 1: Read 0 RPM (motor stopped)
// ============================================================================
TEST(MotorSpeedSensorTest, Test_01_ReadZeroRPM) {
    MotorSpeedSensor sensor;
    sensor.set_pulse_count(0);

    int rpm = sensor.read_rpm();

    ASSERT_EQ(rpm, 0);
    ASSERT_EQ(sensor.get_last_rpm(), 0);
}

// ============================================================================
// TEST 2: Read 1500 RPM (normal speed)
// ============================================================================
TEST(MotorSpeedSensorTest, Test_02_ReadNormalSpeed) {
    MotorSpeedSensor sensor;
    sensor.set_pulse_count(25);  // 25 pulses * 60 = 1500 RPM

    int rpm = sensor.read_rpm();

    ASSERT_EQ(rpm, 1500);
    ASSERT_EQ(sensor.get_last_rpm(), 1500);
}

// ============================================================================
// TEST 3: Read 10000 RPM (maximum speed)
// ============================================================================
TEST(MotorSpeedSensorTest, Test_03_ReadMaxSpeed) {
    MotorSpeedSensor sensor;
    sensor.set_pulse_count(167);  // 167 pulses * 60 ≈ 10020 RPM (will be rejected)

    int rpm = sensor.read_rpm();

    // Should reject out-of-range value
    ASSERT_EQ(rpm, -1);
}

// Correct max speed test
TEST(MotorSpeedSensorTest, Test_03_ReadMaxSpeed_Correct) {
    MotorSpeedSensor sensor;
    sensor.set_pulse_count(166);  // 166 pulses * 60 = 9960 RPM (within range)

    int rpm = sensor.read_rpm();

    ASSERT_EQ(rpm, 9960);
    ASSERT_EQ(sensor.get_last_rpm(), 9960);
}

// ============================================================================
// TEST 4: Verify pulse counting accuracy
// ============================================================================
TEST(MotorSpeedSensorTest, Test_04_PulseCountingAccuracy) {
    MotorSpeedSensor sensor;

    // Test various pulse counts
    int test_cases[][2] = {
        {10, 600},      // 10 pulses = 600 RPM
        {50, 3000},     // 50 pulses = 3000 RPM
        {100, 6000},    // 100 pulses = 6000 RPM
    };

    for (auto& test : test_cases) {
        sensor.set_pulse_count(test[0]);
        int rpm = sensor.read_rpm();
        ASSERT_EQ(rpm, test[1]) << "Failed for pulse count: " << test[0];
    }
}

// ============================================================================
// TEST 5: Test timeout handling
// ============================================================================
TEST(MotorSpeedSensorTest, Test_05_TimeoutHandling) {
    MotorSpeedSensor sensor;
    sensor.enable_timeout(true);  // Simulate GPIO timeout

    int rpm = sensor.read_rpm();

    // Should return error code
    ASSERT_EQ(rpm, -1);
}

// ============================================================================
// Additional Test: Out-of-range rejection
// ============================================================================
TEST(MotorSpeedSensorTest, Test_06_OutOfRangeRejection) {
    MotorSpeedSensor sensor;

    // Test negative pulses (should be caught by GPIO)
    sensor.set_pulse_count(-1);
    int rpm = sensor.read_rpm();
    ASSERT_EQ(rpm, -1);

    // Test extremely high value
    sensor.set_pulse_count(200);  // 200 * 60 = 12000 (> 10000 max)
    rpm = sensor.read_rpm();
    ASSERT_EQ(rpm, -1);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
