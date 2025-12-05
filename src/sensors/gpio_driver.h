#ifndef GPIO_DRIVER_H
#define GPIO_DRIVER_H

#include "gpio_interface.h"

/**
 * @brief Concrete GPIO driver (stub for cppcheck / simple compilation)
 *
 * In production, this class talks to actual GPIO hardware.
 */
class GPIODriver : public IGpioDriver {
public:
    explicit GPIODriver(int /*pin*/) {}

    int read_pulse_count(int /*duration_ms*/) override {
        return 0; // stub: always return 0 pulses
    }
};

#endif // GPIO_DRIVER_H
