/**
 * @file app_controller.hpp
 * @brief Application controller for dashboard lifecycle and data sources.
 */

#pragma once

#include <QString>
#include "kuksa_reader.hpp"

class QGuiApplication;

namespace drivaui {

/**
 * @struct RunConfig
 * @brief Application runtime configuration (data source, connectivity options).
 */
struct RunConfig {
    /// @brief Use KUKSA as data source (default: true).
    bool useKuksa{true};

    /// @brief CAN interface name (e.g., "can0"). Used if useKuksa is false.
    QString canInterface{QStringLiteral("can0")};

    /// @brief KUKSA connection options.
    kuksa::KuksaOptions kuksa{};
};

/**
 * @class AppController
 * @brief Orchestrates application lifecycle, data sources, and QML UI.
 * @note Thread-safe for main (GUI) thread; data readers use QThread with queued connections.
 */
class AppController {
public:
    /// @brief Construct AppController with configuration.
    explicit AppController(const RunConfig& config);

    /// @brief Run event loop (initialize KUKSA/CAN, load QML, manage shutdown).
    /// @return QGuiApplication exit code.
    int run(QGuiApplication& app);

private:
    RunConfig config_;
};

}  // namespace drivaui
