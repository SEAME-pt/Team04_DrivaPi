#pragma once

#include <linux/can.h>
#include <string>

namespace feeder {

/**
 * @brief Opens and binds a SocketCAN socket to the specified interface
 * @param ifname Interface name (e.g., "can0", "vcan0")
 * @return Socket file descriptor (>= 0 on success, -1 on error)
 * @note On error, prints diagnostic message with interface name and errno
 * @note Call close() on the returned socket when done
 */
int OpenCanSocket(const std::string& ifname);

/**
 * @brief Closes a SocketCAN socket cleanly
 * @param sock Socket file descriptor
 */
void CloseCanSocket(int sock);

/**
 * @brief Reads a single CAN frame from the socket (blocking)
 * @param sock Socket file descriptor
 * @param frame Output parameter for received frame
 * @return true if frame successfully read, false on error (including signal interrupt with stop flag set)
 * @note Handles EINTR internally; checks g_stop_requested for graceful shutdown
 */
bool ReadCanFrame(int sock, can_frame& frame);

} // namespace feeder
