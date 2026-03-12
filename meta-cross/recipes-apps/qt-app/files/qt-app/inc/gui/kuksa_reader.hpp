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
#include <mutex>

#include <grpcpp/grpcpp.h>
#include "kuksa/val/v2/val.grpc.pb.h"

namespace kuksa {

struct KuksaOptions {
    QString address{"localhost:55555"};
    bool useSsl{false};
    QString rootCaPath{};
    QString clientCertPath{};
    QString clientKeyPath{};
    QString token{};
};

class KuksaReader : public QObject
{
    Q_OBJECT
public:
    explicit KuksaReader(QObject *parent = nullptr);
    explicit KuksaReader(const KuksaOptions& opts, QObject *parent = nullptr);
    ~KuksaReader() override;

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
    /// @brief Run one subscribe-read loop for the given VSS paths.
    /// @return true if stopped cleanly, false if the subscription failed with an error.
    bool subscribeLoop(const std::vector<std::string>& paths);

    void attachAuth(grpc::ClientContext& ctx);
    static std::string loadFile(const QString& path, bool warnOnMissing = false);
    static std::string encodeBearerToken(const QString& token);

    KuksaOptions m_opts;
    using VAL = kuksa::val::v2::VAL;
    std::unique_ptr<VAL::Stub> m_stub;
    std::atomic<bool> m_stopRequested{false};
    std::mutex m_contextMutex;           // guards m_context across worker and stop() threads
    std::unique_ptr<grpc::ClientContext> m_context;
};

}  // namespace kuksa

#endif // KUKSAREADER_HPP
