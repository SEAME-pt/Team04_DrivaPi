/**
 * @file pi_health_reader.hpp
 * @author DrivaPi Team
 * @brief Polls Raspberry Pi system health metrics directly from procfs/sysfs.
 * @note No subprocess spawning — reads /proc and /sys via std::ifstream for deterministic latency.
 */

#pragma once

#include <QObject>
#include <QTimer>
#include <QString>

namespace drivaui {

class PiHealthReader : public QObject {
    Q_OBJECT

    Q_PROPERTY(float cpuTemp READ cpuTemp NOTIFY updated)
    Q_PROPERTY(int cpuFreq READ cpuFreq NOTIFY updated)
    Q_PROPERTY(int memoryPercent READ memoryPercent NOTIFY updated)
    Q_PROPERTY(int diskPercent READ diskPercent NOTIFY updated)
    Q_PROPERTY(QString ipAddress READ ipAddress NOTIFY updated)
    Q_PROPERTY(QString uptime READ uptime NOTIFY updated)
    Q_PROPERTY(bool isOnline READ isOnline NOTIFY updated)

public:
    explicit PiHealthReader(QObject* parent = nullptr);
    ~PiHealthReader() override;

    float cpuTemp() const { return m_cpuTemp; }
    int cpuFreq() const { return m_cpuFreq; }
    int memoryPercent() const { return m_memoryPercent; }
    int diskPercent() const { return m_diskPercent; }
    QString ipAddress() const { return m_ipAddress; }
    QString uptime() const { return m_uptime; }
    bool isOnline() const { return m_isOnline; }

    void setIntervalMs(int ms);

public slots:
    void start();
    void stop();

signals:
    void updated();
    void error(const QString& msg);

private slots:
    void poll();

private:
    void readProcFs();

    float m_cpuTemp = 0.0f;
    int m_cpuFreq = 0;
    int m_memoryPercent = 0;
    int m_diskPercent = 0;
    QString m_ipAddress{"--"};
    QString m_uptime{"--"};
    bool m_isOnline = false;

    QTimer* m_timer = nullptr;
};

} // namespace drivaui
