/**
 * @file motor_speed.h
 * @brief Motor speed sensor driver header
 * @version 1.0
 * @date 2025-11-03
 *
 * Requirement: SWD-998
 * ASIL: A
 */

#ifndef MOTOR_SPEED_H
#define MOTOR_SPEED_H

#include <stdint.h>

// Forward declaration
class GPIODriver;

/**
 * @class MotorSpeedSensor
 * @brief Driver for reading motor RPM via GPIO tachometer input
 *
 * Reads pulses from GPIO pin and converts to RPM.
 * 1 pulse = 1 motor revolution.
 * Measures over 1 second window.
 * Range: 0-10000 RPM
 *
 * Requirement: SWD-998
 */
class MotorSpeedSensor {
private:
    int pin;              ///< GPIO pin number
    int last_rpm;         ///< Last valid RPM reading
    bool error_flag;      ///< Error status flag
    GPIODriver* gpio;     ///< GPIO hardware interface

public:
    /**
     * Constructor
     * @param gpio_pin GPIO pin number (default: 17 for Raspberry Pi)
     */
    explicit MotorSpeedSensor(int gpio_pin = 17);

    /**
     * Destructor - cleanup GPIO resources
     */
    ~MotorSpeedSensor();

    /**
     * Read motor speed in RPM
     *
     * Reads pulse count over 1 second and converts to RPM.
     * Valid range: 0-10000 RPM
     *
     * @return RPM value on success, -1 on error
     *
     * Requirement: SWD-998
     */
    int read_rpm(void);

    /**
     * Get last valid RPM reading
     * @return Last RPM reading
     */
    int get_last_rpm(void) const;

    /**
     * Check if error occurred
     * @return true if error, false if no error
     */
    bool has_error(void) const;

    /**
     * Clear error flag
     */
    void clear_error(void);
};

#endif // MOTOR_SPEED_H
