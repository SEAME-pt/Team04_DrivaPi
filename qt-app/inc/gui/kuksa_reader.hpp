/**
 * @file kuksa_reader.hpp
 * @brief KUKSA Val v2 gRPC client (TLS/mTLS + JWT authentication).
 */

#ifndef KUKSAREADER_HPP
#define KUKSAREADER_HPP

#include <QObject>
#include <QDebug>
#include <grpcpp/grpcpp.h>
#include "kuksa/val/v2/val.grpc.pb.h"

namespace kuksa {

// KUKSA Val v2 gRPC namespace
using namespace kuksa::val::v2;

/**
 * @struct KuksaOptions
 * @brief KUKSA databroker connection configuration.
 */
struct KuksaOptions {
    QString address = QStringLiteral("localhost:55555");     ///< Server address:port.
    bool use_ssl = false;                                     ///< Enable TLS.
    QString root_ca_path;                                     ///< CA certificate (TLS).
    QString client_cert_path;                                 ///< Client cert (mTLS).
    QString client_key_path;                                  ///< Client key (mTLS).
    QString token;                                            ///< JWT bearer token.
};

/**
 * @class KUKSAReader
 * @brief KUKSA Val v2 gRPC client (run in worker thread).
 * @note Thread-safe stop flag; use Qt::QueuedConnection for signals to GUI thread.
 */
class KUKSAReader : public QObject
{
    Q_OBJECT
public:
    /// @brief Construct with default config (localhost:55555, insecure).
    explicit KUKSAReader(QObject *parent = nullptr);

    /// @brief Construct with custom config.
    explicit KUKSAReader(const KuksaOptions& opts, QObject *parent = nullptr);

    ~KUKSAReader() override;

public slots:
    /// @brief Start gRPC connection and subscribe to speed updates (blocking).
    void start();

    /// @brief Signal graceful stop of subscription (thread-safe atomic flag).
    void stop();

signals:
    /// @brief Emitted when speed update received (float m/s).
    void speedReceived(float speed);

    /// @brief Emitted on fatal connection or configuration error.
    void errorOccurred(const QString& message);

private:
    void attachAuth(grpc::ClientContext& ctx);
    static std::string loadFile(const QString& path, bool warnOnMissing = false);
    static std::string encodeBearerToken(const QString& token);

    KuksaOptions m_opts_;
    std::unique_ptr<VAL::Stub> m_stub_;
    std::atomic<bool> m_stop_requested_{false};
    std::unique_ptr<grpc::ClientContext> m_context_;
};

}  // namespace kuksa

#endif // KUKSAREADER_HPP