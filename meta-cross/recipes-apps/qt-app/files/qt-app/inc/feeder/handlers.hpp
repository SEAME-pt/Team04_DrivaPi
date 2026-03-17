/**
 * @file handlers.hpp
 * @author DrivaPi Team
 * @brief CAN frame handlers for converting CAN data to VSS signals
 */

#pragma once

#include <linux/can.h>

namespace feeder {
class Publisher;
}

namespace handlers {

/**
 * @brief Handle speed CAN frame (ID 0x100)
 *
 * Payload: 4-byte float (little-endian) representing speed in m/s from STM32
 * Publishes to: Vehicle.Speed (converted to km/h for VSS compliance)
 *
 * @param frame The CAN frame
 * @param publisher KUKSA publisher instance
 */
void HandleSpeed(const can_frame& frame, feeder::Publisher& publisher);
void HandleStm32Battery(const can_frame& frame, feeder::Publisher& publisher);
void HandleRpiBattery(const can_frame& frame, feeder::Publisher& publisher);
void HandleGear(const can_frame& frame, feeder::Publisher& publisher);
void HandleEnv(const can_frame& frame, feeder::Publisher& publisher);

} // namespace handlers
