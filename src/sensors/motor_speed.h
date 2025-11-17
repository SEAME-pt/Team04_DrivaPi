/**
 * @file motor_speed.h
 * @brief Motor speed sensor driver header
 * @version 1.1
 * @date 2025-11-17
 *
 * Requirement: SWD-998
 * ASIL: A
 *
 * The MotorSpeedSensor reads pulses from a GPIO tachometer and computes RPM.
 * For unit testing a mock implementing IGpioDriver may be injected.
 */

#ifndef MOTOR_SPEED_H
#define MOTOR_SPEED_H

#include <cstdint>
#include "gpio_interface.h"
#include "gpio_driver.h"

/**
 * @class MotorSpeedSensor
 * @brief Driver for reading motor RPM via GPIO tachometer input
 *
 * Requirement: SWD-998
 */
class MotorSpeedSensor {
private:
    int pin;                ///< GPIO pin number (or -1 if injecting driver)
    int last_rpm;           ///< Last valid RPM reading
    bool error_flag;        ///< Error status flag
    IGpioDriver* gpio;      ///< GPIO hardware interface (abstract)
    bool is_managing_gpio;  ///< True if this class created the gpio driver

public:
    explicit MotorSpeedSensor(int gpio_pin = 17);  ///< Production constructor
    explicit MotorSpeedSensor(IGpioDriver* test_gpio); ///< Test constructor
    ~MotorSpeedSensor();

    // Delete copy operations
    MotorSpeedSensor(const MotorSpeedSensor&) = delete;
    MotorSpeedSensor& operator=(const MotorSpeedSensor&) = delete;

    // cppcheck-suppress unusedFunction
    int read_rpm(void);

    // cppcheck-suppress unusedFunction
    int get_last_rpm(void) const;

    // cppcheck-suppress unusedFunction
    bool has_error(void) const;

    // cppcheck-suppress unusedFunction
    void clear_error(void);
};

#endif // MOTOR_SPEED_H
