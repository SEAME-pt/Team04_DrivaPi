/**
 * @file handlers.cpp
 * @brief CAN frame handler implementations
 */

#include "handlers.hpp"
#include "publisher.hpp"
#include "can_decode.hpp"
#include "signals.hpp"
#include <iostream>

namespace handlers {

void HandleSpeed(const can_frame& frame, kuksa::Publisher& publisher) {
    // Validate payload size (expect 4 bytes for float)
    if (frame.can_dlc < 4) {
        std::cerr << "[Handler] Speed frame too short: " << static_cast<int>(frame.can_dlc) 
                  << " bytes" << std::endl;
        return;
    }

    // Decode float from CAN payload (little-endian)
    float speed_mps = can_decode::FloatLe(frame.data);  // STM32 sends m/s
    float speed_kmh = speed_mps * 3.6f;  // Convert to km/h for VSS compliance

    // Publish to KUKSA
    if (publisher.PublishFloat(vss::VEHICLE_SPEED, speed_kmh)) {
        std::cout << "[Handler] Published Vehicle.Speed = " << speed_kmh << " km/h (" 
                  << speed_mps << " m/s)" << std::endl;
    }
}

} // namespace handlers
