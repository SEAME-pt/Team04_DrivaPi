#include "feeder_can.hpp"
#include "feeder_signal.hpp"
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <linux/can/raw.h>
#include <unistd.h>
#include <cstring>
#include <cerrno>
#include <iostream>

namespace feeder {

int OpenCanSocket(const std::string& interface_name)
{
    // Step 1: Create CAN socket
    int sock = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (sock < 0) {
        std::cerr << "[CAN] Failed to create socket: " << std::strerror(errno) << std::endl;
        return -1;
    }
    
    // Step 2: Get interface index
    struct ifreq interface_request;
    std::memset(&interface_request, 0, sizeof(interface_request));
    std::strncpy(interface_request.ifr_name, interface_name.c_str(), IFNAMSIZ - 1);
    
    if (ioctl(sock, SIOCGIFINDEX, &interface_request) < 0) {
        std::cerr << "[CAN] Failed to get interface index for '" << interface_name 
                  << "': " << std::strerror(errno) << std::endl;
        close(sock);
        return -1;
    }
    
    // Step 3: Bind socket to CAN interface
    struct sockaddr_can socket_address;
    std::memset(&socket_address, 0, sizeof(socket_address));
    socket_address.can_family = AF_CAN;
    socket_address.can_ifindex = interface_request.ifr_ifindex;
    
    if (bind(sock, reinterpret_cast<struct sockaddr*>(&socket_address), sizeof(socket_address)) < 0) {
        std::cerr << "[CAN] Failed to bind socket to '" << interface_name 
                  << "': " << std::strerror(errno) << std::endl;
        close(sock);
        return -1;
    }
    
    std::cout << "[CAN] Listening on interface: " << interface_name << std::endl;
    return sock;
}

void CloseCanSocket(int sock)
{
    if (sock >= 0) {
        close(sock);
    }
}

bool ReadCanFrame(int sock, can_frame& frame)
{
    if (sock < 0) {
        std::cerr << "[CAN] Invalid socket descriptor" << std::endl;
        return false;
    }
    
    const ssize_t bytes_read = read(sock, &frame, sizeof(frame));
    
    if (bytes_read < 0) {
        // Read interrupted by signal
        if (errno == EINTR) {
            // Check if we were asked to stop
            if (g_stop_requested.load()) {
                std::cout << "[CAN] Read interrupted by shutdown signal" << std::endl;
                return false;
            }
            // Other signal (shouldn't happen normally), retry
            return false;
        }
        
        // Actual read error
        std::cerr << "[CAN] Read error: " << std::strerror(errno) << std::endl;
        return false;
    }
    
    if (bytes_read != static_cast<ssize_t>(sizeof(frame))) {
        std::cerr << "[CAN] Incomplete frame read: got " << bytes_read 
                  << " bytes, expected " << sizeof(frame) << std::endl;
        return false;
    }
    
    return true;
}

} // namespace feeder
