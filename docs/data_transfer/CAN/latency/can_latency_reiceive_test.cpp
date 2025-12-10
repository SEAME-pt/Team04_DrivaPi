#include <iostream>
#include <cstring>
#include <chrono>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <poll.h>
#include <fcntl.h>

uint64_t now_us() {
    return std::chrono::duration_cast<std::chrono::microseconds>(
    std::chrono::steady_clock::now().time_since_epoch()).count();
}

void pack_uint64(uint64_t value, uint8_t *data) {
    for (int i = 0; i < 8; i++)
        data[i] = (value >> (8 * i)) & 0xFF;
}

uint64_t unpack_uint64(const uint8_t *data) {
    uint64_t value = 0;
    for (int i = 0; i < 8; i++)
        value |= ((uint64_t)data[i]) << (8 * i);
    return value;
}

int main() {
    int s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0) { 
        perror("socket"); 
        return 1; 
    }

    struct ifreq ifr;
    strcpy(ifr.ifr_name, "can1");
    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) { 
        perror("ioctl"); 
        return 1;
    }

    struct sockaddr_can addr;
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) 
        perror("bind"); return 1;

    struct can_frame frame, rx;
    frame.can_id = 0x123;
    frame.can_dlc = 8;

    const int iterations = 1000;
    const int timeout_ms = 100;

    struct pollfd pfd = { s, POLLIN, 0 };

    for (int i = 0; i < iterations; i++) {
        uint64_t t0 = now_us();
        pack_uint64(t0, frame.data);

        ssize_t n;
        do {
            n = write(s, &frame, sizeof(frame));
            if (n < 0 && (errno == EAGAIN || errno == ENOBUFS)) 
                usleep(100);
            else if (n < 0){ 
                perror("write"); 
                break; 
            }
        } 
        while (n != sizeof(frame));

        int poll_ret = poll(&pfd, 1, timeout_ms);
        if (poll_ret > 0 && (pfd.revents & POLLIN)) {
            int nr = read(s, &rx, sizeof(rx));
            if (nr == sizeof(rx) && rx.can_id == 0x123) {
                uint64_t t1 = now_us();
                uint64_t sent_time = unpack_uint64(rx.data);
                std::cout << (t1 - sent_time) << std::endl;
            } 
            else
                std::cout << "RX_ERROR" << std::endl;
        } 
        else
            std::cout << "TIMEOUT" << std::endl;

        usleep(100000); // 100ms between frames
    }

    close(s);
    return 0;
}