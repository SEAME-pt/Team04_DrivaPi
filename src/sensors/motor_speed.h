/**
 * @file motor_speed.h
 * @brief Motor speed sensor driver header
 * @version 1.1 (Corrected)
 * @date 2025-11-14
 *
 * Requirement: SWD-998
 * ASIL: A
 *
 * Changes:
 * - Now includes "gpio_interface.h".
 * - Constructor is overloaded to accept an IGpioDriver* for testing.
 * - Manages GPIO driver ownership to prevent memory leaks.
 */

#ifndef MOTOR_SPEED_H
#define MOTOR_SPEED_H

#include <cstdint>
#include "gpio_interface.h" // Use the abstract interface

// Forward declaration of the concrete driver (PIMPL)
class GPIODriver;

/**
 * @class MotorSpeedSensor
 * @brief Driver for reading motor RPM via GPIO tachometer input
 *
 * Requirement: SWD-998
 */
class MotorSpeedSensor {
private:
    int pin;            ///< GPIO pin number
    int last_rpm;       ///< Last valid RPM reading
    bool error_flag;    ///< Error status flag
    IGpioDriver* gpio;  ///< GPIO hardware interface (abstract)
    bool is_managing_gpio; ///< True if this class created the gpio driver

public:
    /**
     * @brief Constructor (Production)
     *
     * Creates and manages its own GPIODriver.
     * @param gpio_pin GPIO pin number
     */
    explicit MotorSpeedSensor(int gpio_pin = 17);

    /**
     * @brief Constructor (Testing)
     *
     * Injects an external (mock) GPIO driver. Does not take ownership.
     * @param test_gpio Pointer to a mock driver implementing IGpioDriver
     */
    explicit MotorSpeedSensor(IGpioDriver* test_gpio);

    /**
     * @brief Destructor - cleanup GPIO resources if managed
     */
    ~MotorSpeedSensor();

    // Delete copy constructor and assignment to prevent shallow copies
    MotorSpeedSensor(const MotorSpeedSensor&) = delete;
    MotorSpeedSensor& operator=(const MotorSpeedSensor&) = delete;

    /**
     * @brief Read motor speed in RPM
     *
     * @return RPM value on success, -1 on error
     *
     * Requirement: SWD-998
     */
    int read_rpm(void);

    /**
     * @brief Get last valid RPM reading
     * @return Last RPM reading
     */
    int get_last_rpm(void) const;

    /**
     * @brief Check if error occurred
     * @return true if error, false if no error
     */
    bool has_error(void) const;

    /**
     * @brief Clear error flag
     */
    void clear_error(void);
};

#endif // MOTOR_SPEED_H
