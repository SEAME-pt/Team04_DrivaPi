/**
 * @file main.cpp
 * @author DrivaPi Team
 * @brief Qt dashboard application entry point — parses CLI args, runs AppController.
 */

#include <QGuiApplication>
#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>
#include <csignal>
#include "app_controller.hpp"
#include "cli_parser.hpp"

int main(int argc, char *argv[])
{
    qputenv("QML_DISABLE_DISK_CACHE", "1");
    qputenv("QT_QUICK_CONTROLS_STYLE", "Fusion");

    QGuiApplication app(argc, argv);
    app.setApplicationName("DrivaPi Dashboard");

    // Qt does not install default SIGINT/SIGTERM handlers on Linux.
    // Without these, Ctrl+C kills the process abruptly — aboutToQuit never fires
    // and the worker thread / gRPC objects are never cleaned up.
    std::signal(SIGINT,  [](int) { QCoreApplication::quit(); });
    std::signal(SIGTERM, [](int) { QCoreApplication::quit(); });

    // Ensure OSM tile cache directories exist before the map plugin initialises
    const QString cacheBase = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QDir().mkpath(cacheBase + "/osm-dark");
    QDir().mkpath(cacheBase + "/osm-light");

    drivaui::CliOptions opts;
    drivaui::RunConfig config;
    {
        QCommandLineParser parser;
        drivaui::configureParser(parser, opts);
        parser.process(app);
        config = drivaui::buildRunConfig(parser, opts);
        if (!drivaui::validateOptions(parser, opts, config, app.arguments())) {
            return 1;
        }
    } // parser destroyed here — before the event loop starts

    drivaui::AppController controller(config);
    return controller.run(app);
}
