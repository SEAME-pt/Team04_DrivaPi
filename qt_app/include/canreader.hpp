#ifndef CANREADER_HPP
#define CANREADER_HPP

#include <QObject>
#include <QByteArray>
#include <QString>

class QSocketNotifier;

class CANReader : public QObject
{
    Q_OBJECT
public:
    explicit CANReader(const QString &ifname = QStringLiteral("can01"), QObject *parent = nullptr);
    ~CANReader() override;

public slots:
    bool start();    // will open socket and create notifier (call from the thread this object lives in)
    void stop();

signals:
    void canMessageReceived(const QByteArray &payload, uint32_t canId);
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

#endif // CANREADER_HPP
