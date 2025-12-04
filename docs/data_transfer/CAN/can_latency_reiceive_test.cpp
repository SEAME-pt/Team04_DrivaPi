#include <iostream>
#include <cstring>
#include <chrono>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <sys/ioctl.h>

int main() {
    // 1. Open CAN socket
    int s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0) {
        perror("Socket");
        return 1;
    }

    // 2. Specify CAN interface
    struct ifreq ifr;
    strcpy(ifr.ifr_name, "can0");
    ioctl(s, SIOCGIFINDEX, &ifr);

    struct sockaddr_can addr;
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("Bind");
        return 1;
    }

    std::cout << "Listening on can0...\n";

    // 3. Receive messages in a loop
    struct can_frame frame;
    while (true) {
        int nbytes = read(s, &frame, sizeof(struct can_frame));
        if (nbytes < 0) {
            perror("Read");
            continue;
        }

        if (frame.can_dlc < 4) {
            std::cerr << "Received frame too short!\n";
            continue;
        }

        // Extract timestamp from STM32 (first 4 bytes)
        uint32_t sent_time_ms = 0;
        memcpy(&sent_time_ms, frame.data, sizeof(sent_time_ms));

        // Get current time in milliseconds on Raspberry Pi
        auto now = std::chrono::steady_clock::now();
        uint64_t recv_time_ms = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();

        int64_t latency = static_cast<int64_t>(recv_time_ms) - static_cast<int64_t>(sent_time_ms);
        std::cout << "CAN latency: " << latency << " ms\n";
    }

    close(s);
    return 0;
}
