/**
 * @file can_ids.hpp
 * @author DrivaPi Team
 * @brief CAN ID definitions matching STM32 ThreadX implementation
 *
 * These must stay in sync with the STM32 firmware definitions
 */

#pragma once

#include <cstdint>

namespace can {

// 0x100: 4-byte float (LE) speed in m/s
constexpr uint32_t ID_SPEED = 0x100;

// 0x200: 5 bytes:
//   [0]   uint8 battery percentage (0..100)
//   [1..4] float battery voltage (LE)
constexpr uint32_t ID_STM32_BATTERY = 0x200;

// 0x210: 5 bytes:
//   [0]   uint8 battery percentage (0..100)
//   [1..4] float battery voltage (LE)
constexpr uint32_t ID_RPI_BATTERY = 0x210;

// 0x300: 1 byte:
//   [0] uint8 gear: 0=N, 1=R, 2=D
constexpr uint32_t ID_GEAR = 0x300;

// 0x400: 8 bytes:
//   [0..3] float temperature (LE, celsius)
//   [4..7] float humidity (LE, percent)
constexpr uint32_t ID_ENV = 0x400;

} // namespace can
