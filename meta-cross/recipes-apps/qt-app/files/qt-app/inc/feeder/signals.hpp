/**
 * @file signals.hpp
 * @author DrivaPi Team
 * @brief VSS signal path definitions for KUKSA publishing
 *
 * Centralized VSS paths to ensure consistency between feeder and subscribers
 */

#pragma once

namespace vss {

// Speed (official VSS)
constexpr const char* VEHICLE_SPEED = "Vehicle.Speed";  // km/h (float)

// STM32 12V battery (custom VSS nodes under STM32 control unit)
constexpr const char* STM32_BATTERY_SOC =
    "Vehicle.ControlUnit.STM32.Health.Resources.BatteryLevel";     // percent (float)

constexpr const char* STM32_BATTERY_VOLTAGE =
    "Vehicle.ControlUnit.STM32.Health.Resources.BatteryVoltage";   // volts (float)

// Gear (official VSS)
constexpr const char* CURRENT_GEAR =
    "Vehicle.Powertrain.Transmission.CurrentGear";  // int8: 0=N, -1=R, 1=forward

// “STM32 internal sensors” (we map onto existing VSS cabin signals to avoid custom nodes)
constexpr const char* STM32_TEMPERATURE =
    "Vehicle.ControlUnit.STM32.Health.Resources.Temperature";  // celsius (float)

constexpr const char* STM32_HUMIDITY =
    "Vehicle.ControlUnit.STM32.Health.Resources.Humidity";  // percent (float)

// RPi UPS battery (custom VSS nodes under Central control unit)
constexpr const char* RPI_BATTERY_SOC =
    "Vehicle.ControlUnit.Central.Health.Resources.BatteryLevel";  // percent (float)

constexpr const char* RPI_BATTERY_VOLTAGE =
    "Vehicle.ControlUnit.Central.Health.Resources.BatteryVoltage";  // volts (float)

} // namespace vss
