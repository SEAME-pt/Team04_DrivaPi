#include "canreader.hpp"
#include <QSocketNotifier>
#include <QDebug>

#include <unistd.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <cstring>
#include <errno.h>

CANReader::CANReader(const QString &ifname, QObject *parent)
    : QObject(parent)
    , m_ifname(ifname)
    , m_sockfd(-1)
    , m_notifier(nullptr)
{
}

CANReader::~CANReader()
{
    stop();
}

bool CANReader::start()
{
    return openSocket();
}

void CANReader::stop()
{
    closeSocket();
}

bool CANReader::openSocket()
{
    if (m_sockfd != -1) return true; // already open

    m_sockfd = ::socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (m_sockfd < 0) {
        qWarning() << "CAN socket() failed:" << strerror(errno);
        m_sockfd = -1;
        return false;
    }

    struct ifreq ifr;
    memset(&ifr, 0, sizeof(ifr));
    QByteArray name = m_ifname.toLocal8Bit();
    strncpy(ifr.ifr_name, name.constData(), IFNAMSIZ - 1);

    if (::ioctl(m_sockfd, SIOCGIFINDEX, &ifr) < 0) {
        qWarning() << "ioctl(SIOCGIFINDEX) failed for" << m_ifname << ":" << strerror(errno);
        ::close(m_sockfd);
        m_sockfd = -1;
        return false;
    }

    struct sockaddr_can addr;
    memset(&addr, 0, sizeof(addr));
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (::bind(m_sockfd, reinterpret_cast<struct sockaddr*>(&addr), sizeof(addr)) < 0) {
        qWarning() << "bind() failed for" << m_ifname << ":" << strerror(errno);
        ::close(m_sockfd);
        m_sockfd = -1;
        return false;
    }

    // create a notifier in THIS thread's event loop
    m_notifier = new QSocketNotifier(m_sockfd, QSocketNotifier::Read, this);
    connect(m_notifier, &QSocketNotifier::activated, this, &CANReader::handleReadable);

    qInfo() << "CANReader bound to" << m_ifname << "fd=" << m_sockfd;
    return true;
}

void CANReader::closeSocket()
{
    if (m_notifier) {
        m_notifier->setEnabled(false);
        delete m_notifier;
        m_notifier = nullptr;
    }
    if (m_sockfd != -1) {
        ::close(m_sockfd);
        m_sockfd = -1;
    }
}

void CANReader::handleReadable(int)
{
    if (m_sockfd < 0) return;

    struct can_frame frame;
    ssize_t nbytes = ::read(m_sockfd, &frame, sizeof(frame));
    if (nbytes < 0) {
        qWarning() << "CAN read error:" << strerror(errno);
        return;
    }
    if (static_cast<size_t>(nbytes) < sizeof(struct can_frame)) {
        qWarning() << "Incomplete CAN frame read";
        return;
    }

    // frame.can_dlc is the length (0..8)
    QByteArray payload(reinterpret_cast<const char*>(frame.data), frame.can_dlc);
    uint32_t canId = static_cast<uint32_t>(frame.can_id & CAN_EFF_MASK);

    emit canMessageReceived(payload, canId);
}
