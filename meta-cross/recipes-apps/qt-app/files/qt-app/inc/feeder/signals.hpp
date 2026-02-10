/**
 * @file signals.hpp
 * @brief VSS signal path definitions for KUKSA publishing
 *
 * Centralized VSS paths to ensure consistency between feeder and subscribers
 */

#pragma once

namespace vss {

// Speed (official VSS)
constexpr const char* VEHICLE_SPEED = "Vehicle.Speed";  // km/h (float)

// Battery (official VSS)
constexpr const char* BATTERY_SOC_DISPLAYED =
    "Vehicle.Powertrain.TractionBattery.StateOfCharge.Displayed";  // percent (float)

constexpr const char* BATTERY_VOLTAGE =
    "Vehicle.Powertrain.TractionBattery.CurrentVoltage";  // volts (float)

// Gear (official VSS)
constexpr const char* CURRENT_GEAR =
    "Vehicle.Powertrain.Transmission.CurrentGear";  // int8: 0=N, -1=R, 1=forward

// “STM32 internal sensors” (we map onto existing VSS cabin signals to avoid custom nodes)
constexpr const char* STM32_TEMPERATURE =
    "Vehicle.Cabin.Temperature";  // celsius (float)

constexpr const char* STM32_HUMIDITY =
    "Vehicle.Cabin.Humidity";  // percent (float)

} // namespace vss
