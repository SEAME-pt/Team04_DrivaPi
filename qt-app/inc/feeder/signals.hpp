/**
 * @file signals.hpp
 * @brief VSS signal path definitions for KUKSA publishing
 * 
 * Centralized VSS paths to ensure consistency between feeder and subscribers
 */

#pragma once

namespace vss {

// VSS signal paths (must exist in KUKSA databroker's vss.json)
constexpr const char* VEHICLE_SPEED = "Vehicle.Speed";  // Unit: km/h, Type: float

// Additional paths can be added here:
// constexpr const char* VEHICLE_EXTERIOR_TEMP = "Vehicle.Exterior.AirTemperature";
// constexpr const char* VEHICLE_BATTERY_SOC = "Vehicle.Powertrain.TractionBattery.StateOfCharge.Current";

} // namespace vss
