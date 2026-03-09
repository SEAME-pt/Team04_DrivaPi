/**
 * @file can_reader.cpp
 * @author DrivaPi Team
 * @brief Asynchronous CAN frame reader implementation using QCanBus.
 */

#include "can_reader.hpp"
#include <cstring>

namespace drivaui {

CanReader::CanReader(const QString &ifname, QObject *parent)
    : QObject(parent)
    , m_ifname(ifname)
    , m_device(nullptr)
{
}

CanReader::~CanReader()
{
    stop();
}

bool CanReader::start()
{
    return openDevice();
}

void CanReader::stop()
{
    closeDevice();
}

bool CanReader::openDevice()
{
    if (m_device) return true; // already open

    QString errorString;
    // 1. Create the QCanBusDevice instance
    m_device = QCanBus::instance()->createDevice(QStringLiteral("socketcan"), m_ifname, &errorString);

    if (!m_device)
    {
        qWarning() << "Failed to create CAN device:" << errorString;
        emit errorOccurred(QStringLiteral("createDevice failed: %1").arg(errorString));
        return false;
    }

    // --- CRITICAL: NO CONFIGURATION CALLS ---
    // The device must be configured externally (via 'ip link') before running the app.
    // Qt will simply attempt to connect to the existing, configured socket.

    connect(m_device, &QCanBusDevice::framesReceived, this, &CanReader::handleFramesReceived);
    connect(m_device, &QCanBusDevice::errorOccurred, this, &CanReader::handleErrorOccurred);

    // 2. Connect the device
    if (!m_device->connectDevice())
    {
        qWarning() << "Failed to connect CAN device:" << m_device->errorString();
        emit errorOccurred(QStringLiteral("connectDevice failed: %1").arg(m_device->errorString()));
        closeDevice();
        return false;
    }

    qInfo() << "CAN device opened on interface" << m_ifname;
    return true;
}

void CanReader::closeDevice()
{
    if (!m_device) return;

    if (m_device->state() == QCanBusDevice::ConnectedState)
    {
        m_device->disconnectDevice();
    }
    m_device->deleteLater();
    m_device = nullptr;
    qInfo() << "CAN device closed";
}

void CanReader::handleFramesReceived()
{
    if (!m_device) return;

    while (m_device->framesAvailable())
    {
        QCanBusFrame frame = m_device->readFrame();
        QByteArray payload = frame.payload();
        uint32_t canId = static_cast<uint32_t>(frame.frameId());

        emit canMessageReceived(payload, canId);
    }
}

void CanReader::handleErrorOccurred(QCanBusDevice::CanBusError error)
{
    Q_UNUSED(error);
    if (!m_device) return;

    QString errorMsg = QStringLiteral("CAN Bus Error: %1")
                           .arg(m_device->errorString());
    qWarning() << errorMsg;
    emit errorOccurred(errorMsg);
}

}  // namespace drivaui
