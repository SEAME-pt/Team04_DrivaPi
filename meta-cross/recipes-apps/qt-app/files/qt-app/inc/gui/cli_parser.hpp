/**
 * @file cli_parser.hpp
 * @brief Command-line argument parsing and validation.
 */

#pragma once

#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QString>
#include <QStringList>
#include "app_controller.hpp"

namespace drivaui {

/**
 * @struct CliOptions
 * @brief Container for command-line options.
 */
struct CliOptions {
#ifdef ENABLE_CAN_MODE
    QCommandLineOption canModeOption{QStringList() << "can",
        "Force CAN mode (default is KUKSA)"};
    QCommandLineOption canIfOption{QStringList() << "c" << "can-if",
        "CAN interface name", "ifname", "can0"};
#endif
    QCommandLineOption kuksaAddrOption{QStringList() << "kuksa-addr",
        "Kuksa databroker address (host:port)", "addr"};
    QCommandLineOption kuksaTlsOption{QStringList() << "kuksa-tls",
        "Use TLS for Kuksa connection"};
    QCommandLineOption kuksaInsecureOption{QStringList() << "kuksa-insecure",
        "Use insecure connection (default)"};
    QCommandLineOption kuksaCaOption{QStringList() << "kuksa-ca",
        "Root CA certificate path", "path"};
    QCommandLineOption kuksaCertOption{QStringList() << "kuksa-cert",
        "Client certificate path (mTLS)", "path"};
    QCommandLineOption kuksaKeyOption{QStringList() << "kuksa-key",
        "Client private key path (mTLS)", "path"};
    QCommandLineOption kuksaTokenOption{QStringList() << "kuksa-token",
        "Authorization token (JWT)", "token"};
};

/// @brief Build application description.
QString buildDescription();

/// @brief Configure parser with available options.
void configureParser(QCommandLineParser& parser, const CliOptions& opts);

/// @brief Build RunConfig from parsed arguments.
RunConfig buildRunConfig(const QCommandLineParser& parser, const CliOptions& opts);

/// @brief Validate option consistency (TLS conflicts, CA path, CAN mode).
/// @return true if valid, false on error.
bool validateOptions(const QCommandLineParser& parser, const CliOptions& opts, 
                     const RunConfig& config, const QStringList& rawArgs);

}  // namespace drivaui
