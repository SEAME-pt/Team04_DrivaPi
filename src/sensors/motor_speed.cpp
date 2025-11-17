#include "motor_speed.h"
#include <chrono>
#include <thread>

/**
 * @brief Production constructor - creates and manages GPIODriver
 */
MotorSpeedSensor::MotorSpeedSensor(int gpio_pin)
    : pin(gpio_pin), last_rpm(0), error_flag(false), is_managing_gpio(true) {
    gpio = new GPIODriver(pin);
}

/**
 * @brief Test constructor - injects external GPIO driver
 */
MotorSpeedSensor::MotorSpeedSensor(IGpioDriver* test_gpio)
    : pin(-1), last_rpm(0), error_flag(false), gpio(test_gpio), is_managing_gpio(false) {}

/**
 * @brief Destructor - cleans up if managing GPIO driver
 */
MotorSpeedSensor::~MotorSpeedSensor() {
    if (is_managing_gpio) {
        delete gpio;
    }
}

/**
 * @brief Read motor speed in RPM over 1s window
 * @return RPM value, -1 on error
 */
int MotorSpeedSensor::read_rpm(void) {
    if (!gpio) {
        error_flag = true;
        return -1;
    }
    int pulses = gpio->read_pulse_count(1000); // 1s window
    if (pulses < 0) {
        error_flag = true;
        return -1;
    }
    last_rpm = pulses * 60; // convert Hz -> RPM
	if (last_rpm < 0 || last_rpm > 10000) {
		error_flag = true;
		return -1;
	}
    return last_rpm;
}

/**
 * @brief Get last valid RPM reading
 */
int MotorSpeedSensor::get_last_rpm(void) const {
    return last_rpm;
}

/**
 * @brief Check if error occurred
 */
bool MotorSpeedSensor::has_error(void) const {
    return error_flag;
}

/**
 * @brief Clear error flag
 */
void MotorSpeedSensor::clear_error(void) {
    error_flag = false;
}
