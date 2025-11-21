// #include "../include/can.hpp"

// std::string can::get_can_msg() {
//     const char *ifname = "can01";
//     int s;
//     struct sockaddr_can addr;
//     struct ifreq ifr;

//     // Create CAN raw socket
//     if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
//         perror("socket");
//         return std::string();
//     }

//     // Specify interface
//     strncpy(ifr.ifr_name, ifname, IFNAMSIZ - 1);
//     ifr.ifr_name[IFNAMSIZ - 1] = '\0';
//     if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
//         perror("ioctl");
//         close(s);
//         return std::string();
//     }

//     addr.can_family = AF_CAN;
//     addr.can_ifindex = ifr.ifr_ifindex;

//     // Bind the socket
//     if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
//         perror("bind");
//         close(s);
//         return std::string();
//     }

//     // Read frames until we get at least 2 bytes (message is always two chars)
//     struct can_frame frame;
//     while (true) {
//         ssize_t nbytes = read(s, &frame, sizeof(struct can_frame));
//         if (nbytes < 0) {
//             perror("read");
//             close(s);
//             return std::string();
//         }
//         if (static_cast<size_t>(nbytes) < sizeof(struct can_frame)) {
//             std::cerr << "Incomplete CAN frame\n";
//             continue;
//         }
//         if (frame.can_dlc >= 2) {
//             // Build and return a 2-char std::string from first two bytes
//             std::string msg;
//             msg.push_back(static_cast<char>(frame.data[0]));
//             msg.push_back(static_cast<char>(frame.data[1]));
//             close(s);
//             return msg;
//         }
//         // otherwise keep waiting for a frame with >=2 bytes
//     }
//     close(s);
//     return std::string();
// }
