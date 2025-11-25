#include "canreader.hpp"

CANReader::CANReader(const QString &ifname, QObject *parent)
    : QObject(parent)
    , m_ifname(ifname)
    , m_device(nullptr)
{
}

CANReader::~CANReader()
{
    stop();
}

bool CANReader::start()
{
    return openDevice();
}

void CANReader::stop()
{
    closeDevice();
}

bool CANReader::openDevice()
{
    if (m_device) return true; // already open

    QString errorString;
    m_device = QCanBus::instance()->createDevice(QStringLiteral("socketcan"), m_ifname, &errorString);
    if (!m_device)
    {
        qWarning() << "Failed to create CAN device:" << errorString;
        emit errorOccurred(QStringLiteral("createDevice failed: %1").arg(errorString));
        return false;
    }

    connect(m_device, &QCanBusDevice::framesReceived, this, &CANReader::handleFramesReceived);
    connect(m_device, &QCanBusDevice::errorOccurred, this, &CANReader::handleErrorOccurred);

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

void CANReader::closeDevice()
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

void CANReader::handleFramesReceived()
{
    if (!m_device) return;

    while (m_device->framesAvailable())
    {
        QCanBusFrame frame = m_device->readFrame();
        QByteArray payload = frame.payload();
        uint32_t canId = static_cast<uint32_t>(frame.frameId());
        emit canMessageReceived(payload, canId);
        qDebug() << "Received CAN frame: ID=0x" << QString::number(canId, 16) << " Payload=" << payload.toHex();
    }
}

void CANReader::handleErrorOccurred(QCanBusDevice::CanBusError error)
{
    Q_UNUSED(error);
    if (!m_device) return;

    QString errorMsg = QStringLiteral("CAN Bus Error: %1")
                           .arg(m_device->errorString());
    qWarning() << errorMsg;
    emit errorOccurred(errorMsg);
}