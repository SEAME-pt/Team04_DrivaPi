/**
 * @file pi_health_reader.cpp
 * @author DrivaPi Team
 * @brief Raspberry Pi system health via direct procfs/sysfs reads — no subprocess overhead.
 */

#include "pi_health_reader.hpp"
#include <QDebug>
#include <fstream>
#include <string>
#include <sys/statvfs.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

namespace drivaui {

PiHealthReader::PiHealthReader(QObject* parent)
    : QObject(parent),
      m_timer(new QTimer(this))
{
    m_timer->setInterval(2000);
    connect(m_timer, &QTimer::timeout, this, &PiHealthReader::poll);
}

PiHealthReader::~PiHealthReader() {
    stop();
}

void PiHealthReader::setIntervalMs(int ms) {
    m_timer->setInterval(ms);
}

void PiHealthReader::start() {
    m_timer->start();
    poll();
}

void PiHealthReader::stop() {
    m_timer->stop();
}

void PiHealthReader::poll() {
#ifndef Q_OS_LINUX
    return;
#endif
    readProcFs();
    emit updated();
}

void PiHealthReader::readProcFs() {
    bool ok = true;

    // millidegrees C
    {
        std::ifstream f("/sys/class/thermal/thermal_zone0/temp");
        int raw = 0;
        if (f >> raw) {
            m_cpuTemp = raw / 1000.0f;
        } else {
            m_cpuTemp = 0.0f;
            ok = false;
        }
    }

    // kHz
    {
        std::ifstream f("/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq");
        long khz = 0;
        if (f >> khz) {
            m_cpuFreq = static_cast<int>(khz / 1000);
        } else {
            m_cpuFreq = 0;
        }
    }

    {
        std::ifstream f("/proc/meminfo");
        long memTotal = 0;
        long memAvailable = 0;
        std::string key;
        long value = 0;
        std::string unit;
        while (f >> key >> value >> unit) {
            if (key == "MemTotal:")          memTotal     = value;
            else if (key == "MemAvailable:") memAvailable = value;
            if (memTotal > 0 && memAvailable > 0) break;
        }
        const long used = memTotal - memAvailable;
        m_memoryPercent = (memTotal > 0) ? static_cast<int>((used * 100L) / memTotal) : 0;
    }

    {
        struct statvfs st;
        if (statvfs("/", &st) == 0) {
            const unsigned long total = st.f_blocks * st.f_frsize;
            const unsigned long avail = st.f_bavail * st.f_frsize;
            const unsigned long used  = total - avail;
            m_diskPercent = (total > 0) ? static_cast<int>((used * 100UL) / total) : 0;
        } else {
            m_diskPercent = 0;
        }
    }

    // first field is seconds since boot
    {
        std::ifstream f("/proc/uptime");
        double uptimeSec = 0.0;
        if (f >> uptimeSec) {
            const int total   = static_cast<int>(uptimeSec);
            const int hours   = total / 3600;
            const int minutes = (total % 3600) / 60;
            m_uptime = QString("%1h %2m").arg(hours).arg(minutes, 2, 10, QLatin1Char('0'));
        }
    }

    // first non-loopback IPv4
    {
        m_ipAddress = "--";
        struct ifaddrs* ifap = nullptr;
        if (getifaddrs(&ifap) == 0) {
            for (const struct ifaddrs* ifa = ifap; ifa != nullptr; ifa = ifa->ifa_next) {
                if (!ifa->ifa_addr) continue;
                if (ifa->ifa_addr->sa_family != AF_INET) continue;
                if (ifa->ifa_flags & IFF_LOOPBACK) continue;
                char buf[INET_ADDRSTRLEN];
                const auto* sin = reinterpret_cast<const struct sockaddr_in*>(ifa->ifa_addr);
                if (inet_ntop(AF_INET, &sin->sin_addr, buf, sizeof(buf))) {
                    m_ipAddress = QString::fromLatin1(buf);
                    break;
                }
            }
            freeifaddrs(ifap);
        }
    }

    m_isOnline = ok;

    qDebug() << "PiHealthReader: CPU=" << m_cpuTemp << "°C @" << m_cpuFreq
             << "MHz, Mem=" << m_memoryPercent << "%, Disk=" << m_diskPercent
             << "%, IP=" << m_ipAddress;
}

} // namespace drivaui
