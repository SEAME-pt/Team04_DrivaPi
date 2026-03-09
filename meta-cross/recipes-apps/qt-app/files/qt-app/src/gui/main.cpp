/**
 * @file main.cpp
 * @author DrivaPi Team
 * @brief Qt dashboard application entry point — parses CLI args, runs AppController.
 */

#include <QGuiApplication>
#include <QDir>
#include <QStandardPaths>
#include "app_controller.hpp"
#include "cli_parser.hpp"

int main(int argc, char *argv[])
{
    qputenv("QML_DISABLE_DISK_CACHE", "1");
    qputenv("QT_QUICK_CONTROLS_STYLE", "Fusion");

    QGuiApplication app(argc, argv);
    app.setApplicationName("DrivaPi Dashboard");

    // Ensure OSM tile cache directories exist before the map plugin initialises
    const QString cacheBase = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QDir().mkpath(cacheBase + "/osm-dark");
    QDir().mkpath(cacheBase + "/osm-light");

    drivaui::CliOptions opts;
    QCommandLineParser parser;
    drivaui::configureParser(parser, opts);
    parser.process(app);

    drivaui::RunConfig config = drivaui::buildRunConfig(parser, opts);

    if (!drivaui::validateOptions(parser, opts, config, app.arguments())) {
        return 1;
    }

    drivaui::AppController controller(config);
    return controller.run(app);
}
