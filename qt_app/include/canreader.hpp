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

private slots:
    void handleReadable(int fd);

private:
    bool openSocket();
    void closeSocket();

    QString m_ifname;
    int m_sockfd;
    QSocketNotifier *m_notifier;
};

#endif // CANREADER_HPP
