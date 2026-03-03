#include <QGuiApplication>
#include "app_controller.hpp"
#include "cli_parser.hpp"

int main(int argc, char *argv[])
{
    qputenv("QML_DISABLE_DISK_CACHE", "1");

    QGuiApplication app(argc, argv);
    app.setApplicationName("DrivaPi Dashboard");

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
