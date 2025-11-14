/**
 * @file motor_speed.cpp
 * @brief Motor speed sensor driver implementation
 * @version 1.0
 * @date 2025-11-03
 *
 * Requirement: SWD-998
 * ASIL: A
 */

#include "motor_speed.h"
#include <stdint.h>
#include <chrono>
#include <thread>

// GPIO interface (simplified for Raspberry Pi)
class GPIODriver {
private:
    int pin;
    int pulse_count;
    bool is_setup;

public:
    GPIODriver(int pin_num) : pin(pin_num), pulse_count(0), is_setup(false) {}

    /**
     * Setup GPIO pin for input
     * @return 0 on success, -1 on error
     */
    int setup(void) {
        // In real implementation, use wiringPi or similar
        // gpio.setup_gpio(pin);
        is_setup = true;
        return 0;
    }

    /**
     * Read pulse count from GPIO pin over specified duration
     * @param duration_ms Time window in milliseconds
     * @return Number of pulses, -1 on error
     */
    int read_pulse_count(int duration_ms) {
        if (!is_setup) {
            return -1;
        }

        // In real implementation:
        // - Wait for duration_ms
        // - Count rising edges on pin
        // - Return count

        // For testing, this is mocked
        return pulse_count;
    }

    void set_pulse_count(int count) {
        pulse_count = count;
    }
};

// ============================================================================
// MotorSpeedSensor Implementation
// ============================================================================

MotorSpeedSensor::MotorSpeedSensor(int gpio_pin)
    : pin(gpio_pin), last_rpm(0), error_flag(false) {
    gpio = new GPIODriver(gpio_pin);
    gpio->setup();
}

MotorSpeedSensor::~MotorSpeedSensor() {
    if (gpio) {
        delete gpio;
    }
}

int MotorSpeedSensor::read_rpm(void) {
    // Read pulses over 1 second window
    int pulses = gpio->read_pulse_count(1000);

    // Check for error from GPIO
    if (pulses < 0) {
        error_flag = true;
        return -1;
    }

    // Convert pulses to RPM
    // 1 pulse per motor revolution
    int rpm = pulses * 60;

    // Validate range (0-10000 RPM)
    if (rpm < 0 || rpm > 10000) {
        error_flag = true;
        return -1;
    }

    // Update last valid reading
    last_rpm = rpm;
    error_flag = false;
    return rpm;
}

int MotorSpeedSensor::get_last_rpm(void) const {
    return last_rpm;
}

bool MotorSpeedSensor::has_error(void) const {
    return error_flag;
}

void MotorSpeedSensor::clear_error(void) {
    error_flag = false;
}
