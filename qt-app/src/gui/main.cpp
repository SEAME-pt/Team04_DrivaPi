#include <QGuiApplication>
#include <QCoreApplication>
#include <csignal>
#include "gui/app_controller.hpp"
#include "gui/cli_parser.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("DrivaPi Dashboard");

    // Qt does not install default SIGINT/SIGTERM handlers on Linux.
    // Without these, Ctrl+C kills the process abruptly — aboutToQuit never fires
    // and the worker thread / gRPC objects are never cleaned up.
    std::signal(SIGINT,  [](int) { QCoreApplication::quit(); });
    std::signal(SIGTERM, [](int) { QCoreApplication::quit(); });

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
