/**
 * @file can_reader.hpp
 * @author DrivaPi Team
 * @brief CAN bus reader using QCanBus (SocketCAN).
 */

#ifndef CANREADER_HPP
#define CANREADER_HPP

#include <QObject>
#include <QVariant>
#include <QByteArray>
#include <QString>
#include <QCanBus>
#include <QCanBusDevice>
#include <QCanBusFrame>

class QSocketNotifier;

namespace drivaui {

/**
 * @class CanReader
 * @brief Asynchronous CAN frame reader (run in worker thread, connect with Qt::QueuedConnection).
 */
class CanReader : public QObject
{
    Q_OBJECT
public:
    /// @brief Construct CanReader for a CAN interface.
    explicit CanReader(const QString &ifname = QStringLiteral("can0"), QObject *parent = nullptr);
    ~CanReader() override;

public slots:
    /// @brief Open device and start frame reception. Must be called from reader's thread.
    /// @return true on success, false if device unavailable or open failed.
    bool start();

    /// @brief Close device and stop frame reception. Safe to call multiple times.
    void stop();

signals:
    /// @brief Emitted for each received CAN frame.
    void canMessageReceived(const QByteArray &payload, uint32_t canId);

    /// @brief Emitted on device error (permission, missing interface, etc.).
    void errorOccurred(const QString &msg);

private slots:
    void handleFramesReceived();
    void handleErrorOccurred(QCanBusDevice::CanBusError error);

private:
    bool openDevice();
    void closeDevice();

    QString m_ifname;
    QCanBusDevice *m_device;
};

}  // namespace drivaui

#endif // CANREADER_HPP
