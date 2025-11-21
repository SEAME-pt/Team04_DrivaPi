#include "motor_speed.h"
#include "gpio_driver.h" // Concrete production driver (may be platform-specific)

// Note: avoid including extra std headers (chrono/thread) here unless
// the implementation requires them. The GPIO interface provides a
// read_pulse_count(duration_ms) method.

/// Production constructor - create and manage a concrete GPIODriver
MotorSpeedSensor::MotorSpeedSensor(int gpio_pin)
    : pin(gpio_pin),
      last_rpm(0),
      error_flag(false),
      gpio(nullptr),
      is_managing_gpio(true) {
    // Instantiate platform-specific driver. If gpio_driver.h is not
    // available in a given build, this will be flagged by cppcheck as an
    // informational missing include only (which is acceptable).
    gpio = new GPIODriver(pin);
}

/// Test constructor - inject external GPIO driver (no ownership)
MotorSpeedSensor::MotorSpeedSensor(IGpioDriver* test_gpio)
    : pin(-1),
      last_rpm(0),
      error_flag(false),
      gpio(test_gpio),
      is_managing_gpio(false) {}

/// Destructor - free driver if owned
MotorSpeedSensor::~MotorSpeedSensor() {
    if (is_managing_gpio && gpio) {
        delete gpio;
        gpio = nullptr;
    }
}

/// cppcheck-suppress unusedFunction
int MotorSpeedSensor::read_rpm(void) {
    if (!gpio) {
        error_flag = true;
        return -1;
    }

    // Ask the GPIO driver for number of pulses counted in 1000 ms (1 s)
    int pulses = gpio->read_pulse_count(1000);

    // Error returned by driver
    if (pulses < 0) {
        error_flag = true;
        return -1;
    }

    // Convert pulses per second to RPM (pulses * 60)
    long rpm_calc = static_cast<long>(pulses) * 60L;

    // Validate against allowed range 0..10000 (per SWD-998)
    if (rpm_calc < 0L || rpm_calc > 10000L) {
        // Out of range -> error, do not update last_rpm
        error_flag = true;
        return -1;
    }

    // Valid reading: update last and clear error
    last_rpm = static_cast<int>(rpm_calc);
    error_flag = false;
    return last_rpm;
}

/// cppcheck-suppress unusedFunction
int MotorSpeedSensor::get_last_rpm(void) const {
    return last_rpm;
}

/// cppcheck-suppress unusedFunction
bool MotorSpeedSensor::has_error(void) const {
    return error_flag;
}

/// cppcheck-suppress unusedFunction
void MotorSpeedSensor::clear_error(void) {
    error_flag = false;
}
