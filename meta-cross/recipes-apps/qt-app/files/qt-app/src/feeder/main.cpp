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

    // --- 2. Open CAN socket before initialising gRPC ---
    // Must fail-fast here: a return at this point skips gRPC entirely so no
    // shutdown bookkeeping is needed.
    int can_sock = feeder::OpenCanSocket(config.can_interface);
    if (can_sock < 0) {
        std::cerr << "[Error] Failed to open CAN interface. Is it up? Try:" << std::endl;
        std::cerr << "        sudo ip link set " << config.can_interface << " up" << std::endl;
        return 1;
    }

    // Scope ensures publisher (and all gRPC objects) are destroyed before process exit.
    // Modern gRPC C++ handles global shutdown automatically via static destructors —
    // calling grpc_shutdown() explicitly is unnecessary and can cause double-free crashes.
    {
        // --- 3. Connect to KUKSA databroker ---
        feeder::Publisher publisher(config.publisher_options);
        std::cout << "[Feeder] Connected to KUKSA databroker." << std::endl;

        // --- 4. Install signal handlers for graceful shutdown ---
        feeder::InstallSignalHandlers();
        std::cout << "[Feeder] Running. Press Ctrl+C to stop." << std::endl;

        // --- 5. Main read-dispatch loop ---
        while (!feeder::g_stopRequested.load()) {
            can_frame frame;
            if (!feeder::ReadCanFrame(can_sock, frame)) {
                if (feeder::g_stopRequested.load()) break;
                continue;  // Retry on error (unless stop requested)
            }

            // Skip SocketCAN error frames — they carry fault flags, not telemetry.
            // Without CAN_RAW_ERR_FILTER, the OS drops them by default; but relying on
            // that implicit behaviour is fragile: an error frame reaching this point would
            // have its ID truncated by CAN_SFF_MASK and be dispatched as vehicle data,
            // disguising a hardware fault as a valid telemetry value.
            if (frame.can_id & CAN_ERR_FLAG) {
                std::cerr << "[CAN] Error frame received — skipping." << std::endl;
                continue;
            }

            // Mask the CAN ID according to the actual frame type.
            // Extended frames (CAN_EFF_FLAG) use 29-bit IDs; standard frames use 11-bit.
            // Blindly applying CAN_SFF_MASK to an EFF frame silently truncates the upper bits.
            const uint32_t can_id = (frame.can_id & CAN_EFF_FLAG)
                                        ? (frame.can_id & CAN_EFF_MASK)
                                        : (frame.can_id & CAN_SFF_MASK);

            // Dispatch frame to appropriate handler
            switch (can_id) {
                case can::ID_SPEED:
                    handlers::HandleSpeed(frame, publisher);
                    break;
                case can::ID_STM32_BATTERY:
                    handlers::HandleStm32Battery(frame, publisher);
                    break;
                case can::ID_RPI_BATTERY:
                    handlers::HandleRpiBattery(frame, publisher);
                    break;
                case can::ID_GEAR:
                    handlers::HandleGear(frame, publisher);
                    break;
                case can::ID_ENV:
                    handlers::HandleEnv(frame, publisher);
                    break;
                default:
                    // Ignore unknown CAN IDs silently
                    break;
            }
        }

        // --- 6. Cleanup ---
        feeder::KillRegisteredChildren();
        feeder::CloseCanSocket(can_sock);
    } // publisher destroyed here — all gRPC objects released before grpc_shutdown()

    std::cout << "[Feeder] Stopped." << std::endl;
    return 0;
}
