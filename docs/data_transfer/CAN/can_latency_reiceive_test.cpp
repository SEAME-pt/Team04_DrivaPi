#include <iostream>
#include <cstring>
#include <chrono>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <errno.h>

// Get current time in microseconds
uint64_t now_us() {
    return std::chrono::duration_cast<std::chrono::microseconds>(
        std::chrono::steady_clock::now().time_since_epoch()
    ).count();
}

// Pack uint64_t into CAN data array (little-endian)
void pack_uint64(uint64_t value, uint8_t *data) {
    for (int i = 0; i < 8; i++)
        data[i] = (value >> (8 * i)) & 0xFF;
}

// Unpack uint64_t from CAN data array (little-endian)
uint64_t unpack_uint64(const uint8_t *data) {
    uint64_t value = 0;
    for (int i = 0; i < 8; i++)
        value |= ((uint64_t)data[i]) << (8 * i);
    return value;
}

int main() {
    // --- Open CAN socket ---
    int s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0) {
        perror("socket");
        return 1;
    }

    // --- Set interface ---
    struct ifreq ifr;
    strcpy(ifr.ifr_name, "can1");
    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
        perror("ioctl");
        return 1;
    }

    // --- Enable loopback so we can measure RTT ---
    int loopback = 1;
    if (setsockopt(s, SOL_CAN_RAW, CAN_RAW_LOOPBACK, &loopback, sizeof(loopback)) < 0) {
        perror("setsockopt loopback");
        return 1;
    }

    // --- Bind socket ---
    struct sockaddr_can addr;
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind");
        return 1;
    }

    // --- Enable non-blocking reads ---
    fcntl(s, F_SETFL, O_NONBLOCK);

    struct can_frame frame, rx;

    while (true) {
        // Flush old frames
        while (read(s, &rx, sizeof(rx)) > 0) { /* discard */ }

        // --- Prepare timestamp message ---
        uint64_t t0 = now_us();
        frame.can_id = 0x123;
        frame.can_dlc = 8;
        pack_uint64(t0, frame.data);

        // --- Send frame ---
        ssize_t n = write(s, &frame, sizeof(frame));
        if (n != sizeof(frame)) {
            if (errno != EAGAIN && errno != EWOULDBLOCK) perror("write");
            usleep(100); // wait a bit if TX FIFO is full
            continue;
        }

        // --- Wait for echo with timeout ---
        const int timeout_ms = 10;
        bool received = false;
        uint64_t t1;
        for (int i = 0; i < timeout_ms * 100; i++) { // 10 ms timeout
            int nr = read(s, &rx, sizeof(rx));
            if (nr == sizeof(rx) && rx.can_id == 0x123) {
                t1 = now_us();
                received = true;
                break;
            } 
            else if (nr < 0 && errno != EAGAIN && errno != EWOULDBLOCK) {
                perror("read");
                break;
            }
            usleep(10); // sleep 10us and try again
        }

        if (received) {
            uint64_t sent = unpack_uint64(rx.data);
            uint64_t latency_us = t1 - sent;
            std::cout << "CAN RTT latency: " << latency_us << " us" << std::endl;
        } 
        else
            std::cerr << "No echo received" << std::endl;

        usleep(100000); // 100ms interval
    }

    return 0;
}
