#include <QGuiApplication>
#include "gui/app_controller.hpp"
#include "gui/cli_parser.hpp"

int main(int argc, char *argv[])
{
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
