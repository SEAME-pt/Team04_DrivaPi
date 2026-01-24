#include "gui/kuksa_reader.hpp"
#include <fstream>
#include <atomic>

namespace kuksa {

KUKSAReader::KUKSAReader(QObject *parent)
    : QObject(parent)
{}

KUKSAReader::KUKSAReader(const KuksaOptions& opts, QObject *parent)
    : QObject(parent), m_opts_(opts)
{}

KUKSAReader::~KUKSAReader()
{}

void KUKSAReader::start()
{
    try {
        // 1. Connect to Broker (TLS or insecure)
        std::shared_ptr<grpc::ChannelCredentials> creds;
        if (!m_opts_.use_ssl) {
            creds = grpc::InsecureChannelCredentials();
            qDebug() << "KuksaReader: Using insecure connection.";
        } else {
            grpc::SslCredentialsOptions ssl_opts;
            const std::string root = loadFile(m_opts_.root_ca_path, true);
            if (!root.empty()) ssl_opts.pem_root_certs = root;
            const std::string cert = loadFile(m_opts_.client_cert_path, true);
            const std::string key  = loadFile(m_opts_.client_key_path, true);
            if (!cert.empty() && !key.empty()) {
                ssl_opts.pem_cert_chain = cert;
                ssl_opts.pem_private_key = key;
                qDebug() << "KuksaReader: Using mTLS with client certificate.";
            } else {
                qDebug() << "KuksaReader: Using TLS without client certificate.";
            }
            creds = grpc::SslCredentials(ssl_opts);
        }
        const std::string addr = m_opts_.address.isEmpty() ? std::string("localhost:55555")
                                                           : m_opts_.address.toStdString();
        auto channel = grpc::CreateChannel(addr, creds);
        m_stub_ = VAL::NewStub(channel);
        if (!m_stub_) {
            throw std::runtime_error("Failed to create gRPC stub for " + addr);
        }
        // Verify channel connectivity (blocks briefly)
        if (!channel->WaitForConnected(std::chrono::system_clock::now() + std::chrono::seconds(2))) {
            qWarning() << "KuksaReader: Channel not connected to" << QString::fromStdString(addr) 
                       << "(broker may be unreachable)";
        }
        qDebug() << "KuksaReader: Channel created to" << QString::fromStdString(addr);
    } catch (const std::exception& e) {
        qCritical() << "KuksaReader: Connection setup failed:" << QString::fromStdString(e.what());
        emit errorOccurred(QString::fromStdString(e.what()));
        return;
    }

    // 2. Subscribe to speed data using VAL v2 API
    m_context_ = std::make_unique<grpc::ClientContext>();
    attachAuth(*m_context_);
    SubscribeRequest request;
    
    // Add Vehicle.Speed to subscription paths
    request.add_signal_paths("Vehicle.Speed");

    std::unique_ptr<grpc::ClientReader<SubscribeResponse>> reader(
        m_stub_->Subscribe(m_context_.get(), request));

    SubscribeResponse response;
    qDebug() << "KuksaReader: Connected and Subscribed to Vehicle.Speed";

    // 3. Loop to read incoming speed data (blocking call - runs in QThread)
    while (!m_stop_requested_.load() && reader->Read(&response))
    {
        if (m_stop_requested_.load()) break;

        // Iterate over the map entries in the response
        const auto& entries = response.entries();
        auto it = entries.find("Vehicle.Speed");
        
        if (it != entries.end()) {
            const auto& datapoint = it->second;
            
            if (datapoint.has_value()) {
                const auto& value = datapoint.value();
                
                // Handle both float and double types from VAL v2
                float speed = 0.0f;
                if (value.has_float_()) {
                    speed = value.float_();
                } else if (value.has_double_()) {
                    speed = static_cast<float>(value.double_());
                }
                
                qDebug() << "KuksaReader: Received Vehicle.Speed =" << speed << "km/h";
                emit speedReceived(speed);
            }
        }
    }
    
    grpc::Status status = reader->Finish();
    if (m_stop_requested_.load()) {
        qInfo() << "KuksaReader: Subscription stream stopped by request.";
    } else if (!status.ok()) {
        qWarning() << "KuksaReader: Subscribe stream ended with error:" 
                   << QString::fromStdString(status.error_message());
        emit errorOccurred(QString::fromStdString(status.error_message()));
    }
}

void KUKSAReader::stop()
{
    qDebug() << "KuksaReader: Stop requested.";
    m_stop_requested_.store(true);
    if (m_context_) {
        m_context_->TryCancel();
    }
}

void KUKSAReader::attachAuth(grpc::ClientContext& ctx)
{
    if (!m_opts_.token.isEmpty()) {
        const std::string bearer = encodeBearerToken(m_opts_.token);
        ctx.AddMetadata("authorization", bearer);
        qDebug() << "KuksaReader: Authorization token attached.";
    }
}

std::string KUKSAReader::loadFile(const QString& path, bool warnOnMissing)
{
    if (path.isEmpty()) return {};
    std::ifstream ifs(path.toStdString(), std::ios::in | std::ios::binary);
    if (!ifs) {
        if (warnOnMissing) {
            qWarning() << "KuksaReader: Failed to load file:" << path;
        }
        return {};
    }
    std::string content((std::istreambuf_iterator<char>(ifs)), std::istreambuf_iterator<char>());
    qDebug() << "KuksaReader: Loaded file:" << path << "(" << content.size() << "bytes)";
    return content;
}

std::string KUKSAReader::encodeBearerToken(const QString& token)
{
    // Validate token contains no invalid whitespace
    QString validated = token.trimmed();
    if (validated.contains('\n') || validated.contains('\r')) {
        qWarning() << "KuksaReader: Bearer token contains newlines; stripping.";
        validated.replace('\n', "").replace('\r', "");
    }
    return std::string("Bearer ") + validated.toStdString();
}

}  // namespace kuksa
