/**
 * @file kuksa_reader.hpp
 * @author DrivaPi Team
 * @brief KUKSA VAL v2 gRPC subscriber — emits Qt signals with vehicle telemetry.
 * @note Runs in a worker QThread; connect signals with Qt::QueuedConnection.
 */

#ifndef KUKSAREADER_HPP
#define KUKSAREADER_HPP

#include <QObject>
#include <QString>
#include <memory>
#include <atomic>

#include <grpcpp/grpcpp.h>
#include "kuksa/val/v2/val.grpc.pb.h"

namespace kuksa {

struct KuksaOptions {
    QString address{"localhost:55555"};
    bool use_ssl{false};
    QString root_ca_path{};
    QString client_cert_path{};
    QString client_key_path{};
    QString token{};
};

class KUKSAReader : public QObject
{
    Q_OBJECT
public:
    explicit KUKSAReader(QObject *parent = nullptr);
    explicit KUKSAReader(const KuksaOptions& opts, QObject *parent = nullptr);
    ~KUKSAReader() override;

public slots:
    void start();
    void stop();

signals:
    void speedReceived(float speedKmh);

    // 12V battery from STM32 (percent + voltage)
    void lvBatteryPercentReceived(int percent);
    void lvBatteryVoltageReceived(float volts);

	// 12V battery from RPi (percent + voltage)
    void rpiBatteryPercentReceived(int percent);
    void rpiBatteryVoltageReceived(double volts);

    // STM32 internal sensors
    void stm32TemperatureReceived(float tempC);
    void stm32HumidityReceived(float humidityPct);

    // VSS CurrentGear
    void currentGearReceived(int currentGear);

    void errorOccurred(const QString& message);

private:
    void attachAuth(grpc::ClientContext& ctx);
    static std::string loadFile(const QString& path, bool warnOnMissing = false);
    static std::string encodeBearerToken(const QString& token);

    KuksaOptions m_opts_;
    using VAL = kuksa::val::v2::VAL;
    std::unique_ptr<VAL::Stub> m_stub_;
    std::atomic<bool> m_stop_requested_{false};
    std::unique_ptr<grpc::ClientContext> m_context_;
};

}  // namespace kuksa

#endif // KUKSAREADER_HPP
