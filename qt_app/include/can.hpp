#ifndef CAN_HPP
#define CAN_HPP

#include <iostream>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>

class can {
    static std::string get_can_msg();
};

#endif
