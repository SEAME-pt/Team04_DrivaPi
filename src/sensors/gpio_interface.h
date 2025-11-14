#ifndef GPIO_INTERFACE_H
#define GPIO_INTERFACE_H

/**
 * @brief Abstract interface for a GPIO driver.
 *
 * This allows for dependency injection, enabling the MotorSpeedSensor
 * to be tested with a mock GPIO driver.
 */
class IGpioDriver {
public:
    virtual ~IGpioDriver() = default;

    /**
     * @brief Read pulse count from GPIO pin over specified duration
     * @param duration_ms Time window in milliseconds
     * @return Number of pulses, -1 on error
     */
    virtual int read_pulse_count(int duration_ms) = 0;
};

#endif // GPIO_INTERFACE_H
