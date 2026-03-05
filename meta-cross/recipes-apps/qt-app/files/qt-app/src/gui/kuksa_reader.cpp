/**
 * @file kuksa_reader.cpp
 * @author DrivaPi Team
 * @brief KUKSA VAL v2 gRPC subscriber implementation.
 */

#include "kuksa_reader.hpp"
#include <fstream>
#include <chrono>

namespace kuksa {

using kuksa::val::v2::SubscribeRequest;
using kuksa::val::v2::SubscribeResponse;
using kuksa::val::v2::Datapoint;

static constexpr const char* PATH_SPEED        = "Vehicle.Speed";

// Match the actual KUKSA feeder output paths
static constexpr const char* PATH_BATTERY_PERCENT   = "Vehicle.Powertrain.TractionBattery.StateOfCharge.Displayed";
static constexpr const char* PATH_BATTERY_VOLT      = "Vehicle.Powertrain.TractionBattery.CurrentVoltage";

static constexpr const char* PATH_CURRENT_GEAR = "Vehicle.Powertrain.Transmission.CurrentGear";

static constexpr const char* PATH_STM32_TEMP   = "Vehicle.ControlUnit.STM32.Health.Resources.Temperature";
static constexpr const char* PATH_STM32_HUM    = "Vehicle.ControlUnit.STM32.Health.Resources.Humidity";

static constexpr const char* PATH_RPI_BATTERY_PERCENT = "Vehicle.ControlUnit.Central.Health.Resources.BatteryLevel";
static constexpr const char* PATH_RPI_BATTERY_VOLTAGE = "Vehicle.ControlUnit.Central.Health.Resources.BatteryVoltage";

KUKSAReader::KUKSAReader(QObject *parent)
    : QObject(parent)
{}

KUKSAReader::KUKSAReader(const KuksaOptions& opts, QObject *parent)
    : QObject(parent), m_opts_(opts)
{}

KUKSAReader::~KUKSAReader()
{
    stop();
}
static float readFloat(const Datapoint& dp, float fallback = 0.0f)
{
    if (!dp.has_value()) return fallback;
    const auto& v = dp.value();

    // float/double are typically generated as float_ / double_
    if (v.has_float_())  return v.float_();
    if (v.has_double_()) return static_cast<float>(v.double_());

    // integers are generated without trailing underscore
    if (v.has_int32())   return static_cast<float>(v.int32());
    if (v.has_int64())   return static_cast<float>(v.int64());
    if (v.has_uint32())  return static_cast<float>(v.uint32());
    if (v.has_uint64())  return static_cast<float>(v.uint64());

    return fallback;
}

static int readInt(const Datapoint& dp, int fallback = 0)
{
    if (!dp.has_value()) return fallback;
    const auto& v = dp.value();

    if (v.has_int32())   return v.int32();
    if (v.has_int64())   return static_cast<int>(v.int64());
    if (v.has_uint32())  return static_cast<int>(v.uint32());
    if (v.has_uint64())  return static_cast<int>(v.uint64());

    if (v.has_float_())  return static_cast<int>(v.float_());
    if (v.has_double_()) return static_cast<int>(v.double_());

    return fallback;
}

void KUKSAReader::start()
{
    m_stop_requested_.store(false);

    try {
        std::shared_ptr<grpc::ChannelCredentials> creds;
        if (!m_opts_.use_ssl) {
            creds = grpc::InsecureChannelCredentials();
        } else {
            grpc::SslCredentialsOptions ssl_opts;
            const std::string root = loadFile(m_opts_.root_ca_path, true);
            if (!root.empty()) ssl_opts.pem_root_certs = root;

            const std::string cert = loadFile(m_opts_.client_cert_path, true);
            const std::string key  = loadFile(m_opts_.client_key_path, true);
            if (!cert.empty() && !key.empty()) {
                ssl_opts.pem_cert_chain = cert;
                ssl_opts.pem_private_key = key;
            }
            creds = grpc::SslCredentials(ssl_opts);
        }

        const std::string addr = m_opts_.address.isEmpty()
            ? std::string("localhost:55555")
            : m_opts_.address.toStdString();

        auto channel = grpc::CreateChannel(addr, creds);
        m_stub_ = VAL::NewStub(channel);
        if (!m_stub_) throw std::runtime_error("Failed to create gRPC stub");

        channel->WaitForConnected(std::chrono::system_clock::now() + std::chrono::seconds(2));
    } catch (const std::exception& e) {
        emit errorOccurred(QString::fromStdString(e.what()));
        return;
    }

    m_context_ = std::make_unique<grpc::ClientContext>();
    attachAuth(*m_context_);

    SubscribeRequest request;

    // Subscribe to the required signals (plus speed if used elsewhere)
    request.add_signal_paths(PATH_SPEED);

    request.add_signal_paths(PATH_BATTERY_PERCENT);
    request.add_signal_paths(PATH_BATTERY_VOLT);

    request.add_signal_paths(PATH_CURRENT_GEAR);

    request.add_signal_paths(PATH_STM32_TEMP);
    request.add_signal_paths(PATH_STM32_HUM);

    request.add_signal_paths(PATH_RPI_BATTERY_PERCENT);
    request.add_signal_paths(PATH_RPI_BATTERY_VOLTAGE);

    auto reader = m_stub_->Subscribe(m_context_.get(), request);
    SubscribeResponse response;

    while (!m_stop_requested_.load() && reader->Read(&response)) {
        const auto& entries = response.entries();

        if (auto it = entries.find(PATH_SPEED); it != entries.end()) {
            emit speedReceived(readFloat(it->second, 0.0f));
        }

        if (auto it = entries.find(PATH_BATTERY_PERCENT); it != entries.end()) {
            emit lvBatteryPercentReceived(readInt(it->second, 0));
        }

        if (auto it = entries.find(PATH_BATTERY_VOLT); it != entries.end()) {
            emit lvBatteryVoltageReceived(readFloat(it->second, 0.0f));
        }

        if (auto it = entries.find(PATH_CURRENT_GEAR); it != entries.end()) {
            emit currentGearReceived(readInt(it->second, 0));
        }

        if (auto it = entries.find(PATH_STM32_TEMP); it != entries.end()) {
            emit stm32TemperatureReceived(readFloat(it->second, 0.0f));
        }

        if (auto it = entries.find(PATH_STM32_HUM); it != entries.end()) {
            emit stm32HumidityReceived(readFloat(it->second, 0.0f));
        }

        if (auto it = entries.find(PATH_RPI_BATTERY_PERCENT); it != entries.end()) {
            emit rpiBatteryPercentReceived(readInt(it->second, 0));
        }
        if (auto it = entries.find(PATH_RPI_BATTERY_VOLTAGE); it != entries.end()) {
            emit rpiBatteryVoltageReceived(static_cast<double>(readFloat(it->second, 0.0f)));
        }
    }

    grpc::Status status = reader->Finish();
    if (!m_stop_requested_.load() && !status.ok()) {
        emit errorOccurred(QString::fromStdString(status.error_message()));
    }
}

void KUKSAReader::stop()
{
    m_stop_requested_.store(true);
    if (m_context_) m_context_->TryCancel();
}

void KUKSAReader::attachAuth(grpc::ClientContext& ctx)
{
    if (!m_opts_.token.isEmpty()) {
        ctx.AddMetadata("authorization", encodeBearerToken(m_opts_.token));
    }
}

std::string KUKSAReader::loadFile(const QString& path, bool /*warnOnMissing*/)
{
    if (path.isEmpty()) return {};
    std::ifstream ifs(path.toStdString(), std::ios::in | std::ios::binary);
    if (!ifs) return {};
    return std::string((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());
}

std::string KUKSAReader::encodeBearerToken(const QString& token)
{
    QString t = token.trimmed();
    t.replace('\n', "").replace('\r', "");
    return std::string("Bearer ") + t.toStdString();
}

} // namespace kuksa
