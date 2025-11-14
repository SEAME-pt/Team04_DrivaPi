/**
 * @file motor_speed.cpp
 * @brief Motor speed sensor driver implementation
 * @version 1.1 (Corrected)
 * @date 2025-11-14
 *
 * Requirement: SWD-998
 * ASIL: A
 *
 * Changes:
 * - GPIODriver now implements the IGpioDriver interface.
 * - MotorSpeedSensor constructors are implemented to support
 *   both production and test-injected GPIO drivers.
 * - Ownership of the GPIO driver is now tracked and managed.
 */

#include "motor_speed.h"
#include "gpio_interface.h" // Include the abstract interface
#include <cstdint>

// GPIO interface (simplified for Raspberry Pi)
// This is the concrete implementation used in production.
class GPIODriver : public IGpioDriver {
private:
    int pin;
    int pulse_count; // Mocked value for this example
    bool is_setup;

public:
    GPIODriver(int pin_num) : pin(pin_num), pulse_count(0), is_setup(false) {}

    /**
     * Setup GPIO pin for input
     * @return 0 on success, -1 on error
     */
    int setup(void) {
        // In real implementation, use wiringPi or similar
        is_setup = true;
        return 0;
    }

    /**
     * Read pulse count from GPIO pin over specified duration
     * @param duration_ms Time window in milliseconds
     * @return Number of pulses, -1 on error
     */
    int read_pulse_count(int duration_ms) override {
        if (!is_setup) {
            return -1;
        }
        // In real implementation:
        // - Wait for duration_ms
        // - Count rising edges on pin
        // - Return count

        // For this file's example, we just return the mock value
        // To make this *really* work, you would set this value externally
        // or implement the real hardware logic.
        return pulse_count;
    }

    // This method is for simulation/testing of the concrete driver
    void set_pulse_count(int count) {
        pulse_count = count;
    }
};

// ============================================================================
// MotorSpeedSensor Implementation
// ============================================================================

/**
 * @brief Constructor (Production)
 * Creates and manages its own GPIODriver.
 */
MotorSpeedSensor::MotorSpeedSensor(int gpio_pin)
    : pin(gpio_pin),
      last_rpm(0),
      error_flag(false),
      gpio(nullptr),
      is_managing_gpio(true) // This instance owns the GPIO driver
{
    GPIODriver* driver = new GPIODriver(gpio_pin);
    driver->setup();
    this->gpio = driver; // Store concrete driver as interface pointer
}

/**
 * @brief Constructor (Testing)
 * Injects an external (mock) GPIO driver.
 */
MotorSpeedSensor::MotorSpeedSensor(IGpioDriver* test_gpio)
    : pin(-1), // Pin is irrelevant when injecting
      last_rpm(0),
      error_flag(false),
      gpio(test_gpio), // Use the provided mock driver
      is_managing_gpio(false) // This instance does NOT own the driver
{
    // Do not setup, the mock is assumed to be ready
}

MotorSpeedSensor::~MotorSpeedSensor() {
    // Only delete the driver if this instance created it
    if (is_managing_gpio && gpio) {
        delete gpio;
    }
}

int MotorSpeedSensor::read_rpm(void) {
    // Read pulses over 1 second window
    // This now calls the interface, which could be the real or mock driver
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
