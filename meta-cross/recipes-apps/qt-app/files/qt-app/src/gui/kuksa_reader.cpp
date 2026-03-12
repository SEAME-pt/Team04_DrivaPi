/**
 * @file kuksa_reader.cpp
 * @author DrivaPi Team
 * @brief KUKSA VAL v2 gRPC subscriber implementation.
 */

#include "kuksa_reader.hpp"
#include <QThread>
#include <fstream>
#include <chrono>

namespace kuksa {

using kuksa::val::v2::SubscribeRequest;
using kuksa::val::v2::SubscribeResponse;
using kuksa::val::v2::Datapoint;

static constexpr const char* PATH_SPEED        = "Vehicle.Speed";

// STM32 12V battery (custom VSS nodes under STM32 control unit — mirrors signals.hpp)
static constexpr const char* PATH_BATTERY_PERCENT   = "Vehicle.ControlUnit.STM32.Health.Resources.BatteryLevel";
static constexpr const char* PATH_BATTERY_VOLT      = "Vehicle.ControlUnit.STM32.Health.Resources.BatteryVoltage";

static constexpr const char* PATH_CURRENT_GEAR = "Vehicle.Powertrain.Transmission.CurrentGear";

static constexpr const char* PATH_STM32_TEMP   = "Vehicle.ControlUnit.STM32.Health.Resources.Temperature";
static constexpr const char* PATH_STM32_HUM    = "Vehicle.ControlUnit.STM32.Health.Resources.Humidity";

static constexpr const char* PATH_RPI_BATTERY_PERCENT = "Vehicle.ControlUnit.Central.Health.Resources.BatteryLevel";
static constexpr const char* PATH_RPI_BATTERY_VOLTAGE = "Vehicle.ControlUnit.Central.Health.Resources.BatteryVoltage";

KuksaReader::KuksaReader(QObject *parent)
    : QObject(parent)
{}

KuksaReader::KuksaReader(const KuksaOptions& opts, QObject *parent)
    : QObject(parent), m_opts(opts)
{}

KuksaReader::~KuksaReader()
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

void KuksaReader::start()
{
    m_stopRequested.store(false);

    try {
        const std::string addr = m_opts.address.isEmpty()
            ? std::string("localhost:55555")
            : m_opts.address.toStdString();

        std::shared_ptr<grpc::ChannelCredentials> creds;
        if (!m_opts.useSsl) {
            const bool isLoopback = addr.find("localhost") == 0
                                 || addr.find("127.") == 0
                                 || addr.find("[::1]") == 0;
            if (!isLoopback) {
                qWarning("[KUKSA] WARNING: insecure channel requested for non-loopback address '%s'. "
                         "Vehicle telemetry will be transmitted in plaintext. Enable TLS via useSsl=true.",
                         addr.c_str());
            }
            creds = grpc::InsecureChannelCredentials();
        } else {
            grpc::SslCredentialsOptions ssl_opts;
            const std::string root = loadFile(m_opts.rootCaPath, true);
            if (!root.empty()) ssl_opts.pem_root_certs = root;

            const std::string cert = loadFile(m_opts.clientCertPath, true);
            const std::string key  = loadFile(m_opts.clientKeyPath, true);
            if (!cert.empty() && !key.empty()) {
                ssl_opts.pem_cert_chain = cert;
                ssl_opts.pem_private_key = key;
            }
            creds = grpc::SslCredentials(ssl_opts);
        }

        auto channel = grpc::CreateChannel(addr, creds);
        m_stub = VAL::NewStub(channel);
        if (!m_stub) throw std::runtime_error("Failed to create gRPC stub");

        channel->WaitForConnected(std::chrono::system_clock::now() + std::chrono::seconds(2));
    } catch (const std::exception& e) {
        emit errorOccurred(QString::fromStdString(e.what()));
        return;
    }

    // Required paths (guaranteed by kuksa_feeder — must exist in the databroker VSS).
    const std::vector<std::string> requiredPaths = {
        PATH_SPEED, PATH_BATTERY_PERCENT, PATH_BATTERY_VOLT, PATH_CURRENT_GEAR
    };
    // Optional paths (custom VSS extensions — may not be registered in every deployment).
    const std::vector<std::string> allPaths = {
        PATH_SPEED, PATH_BATTERY_PERCENT, PATH_BATTERY_VOLT, PATH_CURRENT_GEAR,
        PATH_STM32_TEMP, PATH_STM32_HUM, PATH_RPI_BATTERY_PERCENT, PATH_RPI_BATTERY_VOLTAGE
    };

    while (!m_stopRequested.load()) {
        bool ok = subscribeLoop(allPaths);
        if (!ok && !m_stopRequested.load()) {
            // Optional paths likely not registered in the databroker's VSS; fall back to
            // required paths so speed/gear/battery still reach the dashboard.
            qWarning("[KUKSA] Full subscription failed — retrying with required paths only");
            ok = subscribeLoop(requiredPaths);
        }
        if (m_stopRequested.load()) break;
        // Brief pause before reconnect attempt to avoid busy-looping on persistent errors.
        for (int i = 0; i < 20 && !m_stopRequested.load(); ++i)
            QThread::msleep(100);
    }
}

bool KuksaReader::subscribeLoop(const std::vector<std::string>& paths)
{
    // Guard the assignment: stop() may call TryCancel() concurrently from another thread.
    {
        std::lock_guard<std::mutex> lock(m_contextMutex);
        m_context = std::make_unique<grpc::ClientContext>();
        attachAuth(*m_context);
    }

    SubscribeRequest request;
    for (const auto& p : paths)
        request.add_signal_paths(p);

    auto reader = m_stub->Subscribe(m_context.get(), request);
    SubscribeResponse response;

    while (!m_stopRequested.load() && reader->Read(&response)) {
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
    if (!m_stopRequested.load() && !status.ok()) {
        emit errorOccurred(QString("[KUKSA] gRPC error %1: %2")
            .arg(status.error_code())
            .arg(QString::fromStdString(status.error_message())));
        return false;
    }
    return true;
}

void KuksaReader::stop()
{
    m_stopRequested.store(true);
    std::lock_guard<std::mutex> lock(m_contextMutex);
    if (m_context) m_context->TryCancel();
}

void KuksaReader::attachAuth(grpc::ClientContext& ctx)
{
    if (!m_opts.token.isEmpty()) {
        ctx.AddMetadata("authorization", encodeBearerToken(m_opts.token));
    }
}

std::string KuksaReader::loadFile(const QString& path, bool /*warnOnMissing*/)
{
    if (path.isEmpty()) return {};
    std::ifstream ifs(path.toStdString(), std::ios::in | std::ios::binary);
    if (!ifs) return {};
    return std::string((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());
}

std::string KuksaReader::encodeBearerToken(const QString& token)
{
    QString t = token.trimmed();
    t.replace('\n', "").replace('\r', "");
    return std::string("Bearer ") + t.toStdString();
}

} // namespace kuksa
