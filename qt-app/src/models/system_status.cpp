#include "system_status.hpp"
#include <QDebug>
#include <QDateTime>
#include <fstream>
#include <sstream>

SystemStatus::SystemStatus(QObject *parent)
    : QObject(parent),
      m_connectionState("disconnected"),
      m_connectionMode("CAN"),
      m_latency(0.0),
      m_signalsStaleness(0),
      m_frameRate(0),
      m_cpuUsage(0),
      m_memoryUsage(0),
      m_renderingFps(0)
{
    // Timer for system metrics update (CPU, memory every 1 sec)
    m_metricsTimer = new QTimer(this);
    connect(m_metricsTimer, &QTimer::timeout, this, &SystemStatus::updateSystemMetrics);
    m_metricsTimer->start(1000);
    
    // Timer for frame rate calculation (every 1 sec)
    m_frameCountTimer = new QTimer(this);
    connect(m_frameCountTimer, &QTimer::timeout, this, &SystemStatus::calculateFrameRate);
    m_frameCountTimer->start(1000);
}

SystemStatus::~SystemStatus()
{
    if (m_metricsTimer) m_metricsTimer->stop();
    if (m_frameCountTimer) m_frameCountTimer->stop();
}

void SystemStatus::setConnectionState(const QString &state)
{
    if (m_connectionState != state) {
        m_connectionState = state;
        emit connectionStateChanged();
    }
}

void SystemStatus::setConnectionMode(const QString &mode)
{
    if (m_connectionMode != mode) {
        m_connectionMode = mode;
        emit connectionModeChanged();
    }
}

void SystemStatus::setFrameRate(int fps)
{
    if (m_frameRate != fps) {
        m_frameRate = fps;
        emit frameRateChanged();
    }
}

void SystemStatus::setLatency(double ms)
{
    if (m_latency != ms) {
        m_latency = ms;
        emit latencyChanged();
    }
}

void SystemStatus::setSignalsStaleness(int count)
{
    if (m_signalsStaleness != count) {
        m_signalsStaleness = count;
        emit stalnessChanged();
    }
}

void SystemStatus::setCpuUsage(int percent)
{
    if (m_cpuUsage != percent) {
        m_cpuUsage = percent;
        emit cpuUsageChanged();
    }
}

void SystemStatus::setMemoryUsage(int percent)
{
    if (m_memoryUsage != percent) {
        m_memoryUsage = percent;
        emit memoryUsageChanged();
    }
}

void SystemStatus::setRenderingFps(int fps)
{
    if (m_renderingFps != fps) {
        m_renderingFps = fps;
        emit renderingFpsChanged();
    }
}

void SystemStatus::recordFrame()
{
    m_frameCount++;
}

void SystemStatus::calculateFrameRate()
{
    int fps = m_frameCount.exchange(0);
    setFrameRate(fps);
}

void SystemStatus::updateSystemMetrics()
{
    // Read CPU usage from /proc/stat (Linux only)
    // Calculate CPU usage as percentage based on delta since last read
    #ifdef Q_OS_LINUX
    try {
        std::ifstream stat("/proc/stat");
        std::string line;
        if (std::getline(stat, line)) {
            // Parse: cpu  user nice system idle iowait irq softirq
            std::istringstream iss(line);
            std::string cpu;
            long long user, nice, system, idle, iowait, irq, softirq;
            iss >> cpu >> user >> nice >> system >> idle >> iowait >> irq >> softirq;
            
            long long total = user + nice + system + idle + iowait + irq + softirq;
            long long idleTime = idle + iowait;
            
            // Calculate delta
            if (m_prevTotal > 0) {
                long long totalDelta = total - m_prevTotal;
                long long idleDelta = idleTime - m_prevIdle;
                
                if (totalDelta > 0) {
                    int cpuPercent = 100 * (totalDelta - idleDelta) / totalDelta;
                    setCpuUsage(cpuPercent);
                }
            }
            
            m_prevTotal = total;
            m_prevIdle = idleTime;
        }
        
        std::ifstream meminfo("/proc/meminfo");
        int memTotal = 0, memAvail = 0;
        while (std::getline(meminfo, line)) {
            std::istringstream iss(line);
            std::string key;
            int value;
            if (iss >> key >> value) {
                if (key == "MemTotal:") memTotal = value;
                if (key == "MemAvailable:") memAvail = value;
            }
        }
        if (memTotal > 0) {
            int usedPercent = 100 * (memTotal - memAvail) / memTotal;
            setMemoryUsage(usedPercent);
        }
    } catch (...) {
        // Silently ignore parse errors
    }
    #endif
}
