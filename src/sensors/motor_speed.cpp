/**
 * @file motor_speed.cpp
 * @brief Motor speed sensor driver implementation
 * @version 1.1
 * @date 2025-11-17
 *
 * Requirement: SWD-998
 * ASIL: A
 *
 * Notes:
 * - Production GPIODriver is minimal and must be replaced with real hardware logic.
 * - Unit tests should inject a Mock implementing IGpioDriver.
 */

#include "motor_speed.h"
#include "gpio_interface.h"
#include <cstdint>

// ----------------------------------------------------------------------------
// Production concrete GPIO driver (minimal, for production builds).
// ----------------------------------------------------------------------------
class GPIODriver : public IGpioDriver {
private:
    int pin;
    bool is_setup;

public:
    // Mark constructor explicit to satisfy cppcheck/style rules
    explicit GPIODriver(int pin_num) : pin(pin_num), is_setup(false) {}

    /**
     * Setup GPIO pin for input
     * @return 0 on success, -1 on error
     */
    int setup(void) {
        // Implement real GPIO setup here (wiringPi, libgpiod, etc.)
        is_setup = true;
        return 0;
    }

    /**
     * Read pulse count from GPIO pin over specified duration
     * @param duration_ms Time window in milliseconds
     * @return Number of pulses, -1 on error / not implemented
     */
    int read_pulse_count(int duration_ms) override {
        if (!is_setup) {
            return -1;
        }
        // NOTE: Production implementation should count edges for duration_ms.
        // This placeholder returns -1 to indicate "not implemented / no data".
        return -1;
    }
};

// ----------------------------------------------------------------------------
// MotorSpeedSensor implementation
// ----------------------------------------------------------------------------

MotorSpeedSensor::MotorSpeedSensor(int gpio_pin)
    : pin(gpio_pin),
      last_rpm(0),
      error_flag(false),
      gpio(nullptr),
      is_managing_gpio(true) // This instance owns the GPIO driver
{
    GPIODriver* driver = new GPIODriver(gpio_pin);
    // If setup fails, we keep gpio pointer but read_pulse_count will return -1
    (void)driver->setup();
    this->gpio = driver;
}

MotorSpeedSensor::MotorSpeedSensor(IGpioDriver* test_gpio)
    : pin(-1), // Pin is irrelevant when injecting
      last_rpm(0),
      error_flag(false),
      gpio(test_gpio), // Use the provided mock driver
      is_managing_gpio(false) // This instance does NOT own the driver
{
    // Do not setup injected mock: it's assumed ready-to-use
}

MotorSpeedSensor::~MotorSpeedSensor() {
    // Only delete the driver if this instance created it
    if (is_managing_gpio && gpio) {
        delete gpio;
        gpio = nullptr;
    }
}

/* cppcheck-suppress unusedFunction */
int MotorSpeedSensor::read_rpm(void) {
    if (!gpio) {
        error_flag = true;
        return -1;
    }

    // Read pulses over 1 second window
    int pulses = gpio->read_pulse_count(1000);

    // Check for error from GPIO
    if (pulses < 0) {
        error_flag = true;
        return -1;
    }

    // Convert pulses to RPM: pulses per second * 60
    int rpm = pulses * 60;

    // Validate range (0 - 10000 RPM)
    if (rpm < 0 || rpm > 10000) {
        error_flag = true;
        return -1;
    }

    // Update last valid reading
    last_rpm = rpm;
    error_flag = false;
    return rpm;
}

/* cppcheck-suppress unusedFunction */
int MotorSpeedSensor::get_last_rpm(void) const {
    return last_rpm;
}

/* cppcheck-suppress unusedFunction */
bool MotorSpeedSensor::has_error(void) const {
    return error_flag;
}

/* cppcheck-suppress unusedFunction */
void MotorSpeedSensor::clear_error(void) {
    error_flag = false;
}
