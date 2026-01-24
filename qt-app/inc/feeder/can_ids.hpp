/**
 * @file can_ids.hpp
 * @brief CAN ID definitions matching STM32 ThreadX implementation
 * 
 * These must stay in sync with the STM32 firmware definitions
 */

#pragma once

#include <cstdint>

namespace can {

// CAN IDs from STM32 ThreadX firmware
constexpr uint32_t ID_SPEED = 0x100;  // Speed telemetry (float m/s from STM32, 4 bytes)

// Additional IDs can be added here as needed:
// constexpr uint32_t ID_TEMPERATURE = 0x200;
// constexpr uint32_t ID_BATTERY = 0x300;
// constexpr uint32_t ID_HEARTBEAT = 0x701;

} // namespace can
