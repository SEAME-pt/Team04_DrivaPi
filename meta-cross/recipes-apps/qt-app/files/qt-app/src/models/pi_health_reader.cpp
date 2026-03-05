/**
 * @file pi_health_reader.cpp
 * @author DrivaPi Team
 * @brief Raspberry Pi system health polling implementation.
 */

#include "pi_health_reader.hpp"
#include <QJsonDocument>
#include <QDebug>
#include <QSysInfo>

namespace drivaui {

PiHealthReader::PiHealthReader(QObject* parent)
    : QObject(parent),
      m_process(new QProcess(this)),
      m_timer(new QTimer(this))
{
    m_timer->setInterval(2000);

    connect(m_timer, &QTimer::timeout, this, &PiHealthReader::poll);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &PiHealthReader::onProcessFinished);
    connect(m_process, &QProcess::errorOccurred, this, &PiHealthReader::onProcessError);  // <--- Fixed
}

PiHealthReader::~PiHealthReader() {
    stop();
}

void PiHealthReader::setLocalScript(const QString& path) {
    m_mode = Local;
    m_localScript = path;
}

void PiHealthReader::setRemoteSsh(const QString& userAtHost, const QString& remotePath) {
    m_mode = Remote;
    m_sshTarget = userAtHost;
    m_remoteScript = remotePath;
}

void PiHealthReader::setIntervalMs(int ms) {
    m_timer->setInterval(ms);
}

void PiHealthReader::start() {
    if (m_timer) {
        m_timer->start();
        poll();  // Immediate first poll
    }
}

void PiHealthReader::stop() {
    if (m_timer) m_timer->stop();
    if (m_process && m_process->state() != QProcess::NotRunning) {
        m_process->kill();
        m_process->waitForFinished(300);
    }
}

void PiHealthReader::poll() {
    if (!m_process || m_process->state() != QProcess::NotRunning) {
        return;  // Already running
    }

#ifndef Q_OS_LINUX
    return;  // Process-based health reading only supported on Linux (AGL target)
#endif

    if (m_mode == Local) {
        m_process->start(m_localScript, QStringList());
    } else {
        // Remote SSH: ssh user@host /usr/bin/pi_health.sh
        m_process->start("ssh", QStringList() << m_sshTarget << m_remoteScript);
    }
}

void PiHealthReader::onProcessError(QProcess::ProcessError err) {
    Q_UNUSED(err);
    qWarning() << "PiHealthReader: Process error" << err;
    m_isOnline = false;
    emit error("Pi health process error (ssh/script failed)");
    emit updated();
}

void PiHealthReader::onProcessFinished(int exitCode, QProcess::ExitStatus status) {
    if (status != QProcess::NormalExit || exitCode != 0) {
        qWarning() << "PiHealthReader: Exit code" << exitCode;
        m_isOnline = false;
        emit updated();
        return;
    }

    const QByteArray output = m_process->readAllStandardOutput().trimmed();
    const QJsonDocument doc = QJsonDocument::fromJson(output);

    if (!doc.isObject()) {
        qWarning() << "PiHealthReader: Invalid JSON output";
        m_isOnline = false;
        emit error("Invalid JSON from pi_health");
        emit updated();
        return;
    }

    parseJson(doc.object());
    m_isOnline = true;
    emit updated();
}

void PiHealthReader::parseJson(const QJsonObject& obj) {
    // CPU
    const QJsonObject cpu = obj.value("cpu").toObject();
    m_cpuTemp = static_cast<float>(cpu.value("temp_c").toDouble(0.0));
    m_cpuFreq = cpu.value("freq_mhz").toInt(0);

    // Memory
    const QJsonObject mem = obj.value("mem").toObject();
    const int memUsed = mem.value("used_mb").toInt(0);
    const int memTotal = mem.value("total_mb").toInt(1);
    m_memoryPercent = (memTotal > 0) ? (memUsed * 100) / memTotal : 0;

    // Disk
    const QJsonObject disk = obj.value("disk").toObject();
    const int diskUsed = disk.value("used_gb").toInt(0);
    const int diskTotal = disk.value("total_gb").toInt(1);
    m_diskPercent = (diskTotal > 0) ? (diskUsed * 100) / diskTotal : 0;

    // Uptime (convert seconds to h:m:s format)
    const int uptimeSec = obj.value("uptime_s").toInt(0);
    const int hours = uptimeSec / 3600;
    const int minutes = (uptimeSec % 3600) / 60;
    m_uptime = QString("%1h %2m").arg(hours).arg(minutes, 2, 10, QLatin1Char('0'));

    // Network
    const QJsonObject net = obj.value("net").toObject();
    m_ipAddress = net.value("ip").toString("--");

    qDebug() << "PiHealthReader: CPU=" << m_cpuTemp << "°C, Mem=" << m_memoryPercent
             << "%, Disk=" << m_diskPercent << "%, IP=" << m_ipAddress;
}

} // namespace drivaui
