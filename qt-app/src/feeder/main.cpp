/**
 * @file main.cpp
 * @brief KUKSA CAN Feeder - Main entry point
 * 
 * Orchestrates initialization and runs the CAN-to-KUKSA feed loop.
 * Frame dispatch and signal handling delegated to specialized modules.
 */

#include "publisher.hpp"
#include "handlers.hpp"
#include "can_ids.hpp"
#include "feeder_cli.hpp"
#include "feeder_signal.hpp"
#include "feeder_can.hpp"
#include <iostream>
#include <linux/can.h>

int main(int argc, char** argv)
{
    // --- 1. Parse CLI arguments ---
    feeder::FeederConfig config = feeder::ParseArgs(argc, argv);
    feeder::PrintConfig(config);

    // --- 2. Connect to KUKSA databroker ---
    kuksa::Publisher publisher(config.publisher_options);
    std::cout << "[Feeder] Connected to KUKSA databroker." << std::endl;

    // --- 3. Open CAN socket ---
    int can_sock = feeder::OpenCanSocket(config.can_interface);
    if (can_sock < 0) {
        std::cerr << "[Error] Failed to open CAN interface. Is it up? Try:" << std::endl;
        std::cerr << "        sudo ip link set " << config.can_interface << " up" << std::endl;
        return 1;
    }

    // --- 4. Install signal handlers for graceful shutdown ---
    feeder::InstallSignalHandlers();
    std::cout << "[Feeder] Running. Press Ctrl+C to stop." << std::endl;

    // --- 5. Main read-dispatch loop ---
    while (!feeder::g_stop_requested.load()) {
        can_frame frame;
        if (!feeder::ReadCanFrame(can_sock, frame)) {
            if (feeder::g_stop_requested.load()) break;
            continue;  // Retry on error (unless stop requested)
        }
        
        // Dispatch frame to appropriate handler
        const uint32_t can_id = frame.can_id & CAN_SFF_MASK;
        switch (can_id) {
            case can::ID_SPEED:
                handlers::HandleSpeed(frame, publisher);
                break;
            // Add more handlers as needed
            default:
                // Ignore unknown CAN IDs silently
                break;
        }
    }

    // --- 6. Cleanup ---
    feeder::KillRegisteredChildren();
    feeder::CloseCanSocket(can_sock);
    std::cout << "[Feeder] Stopped." << std::endl;
    return 0;
}
