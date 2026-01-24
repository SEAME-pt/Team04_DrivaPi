#include "gui/cli_parser.hpp"
#include <QDebug>

namespace drivaui {

QString buildDescription()
{
    QString desc = "Hybrid Dashboard (KUKSA default, CAN optional)\n\nExamples:\n";
#ifdef ENABLE_CAN_MODE
    desc += "  myqtapp --can --can-if vcan0\n";
#endif
    desc += "  myqtapp --kuksa --kuksa-addr localhost:55555\n";
    desc += "  myqtapp --kuksa --kuksa-tls --kuksa-ca /path/to/ca.crt";
    return desc;
}

void configureParser(QCommandLineParser& parser, const CliOptions& opts)
{
    parser.setApplicationDescription(buildDescription());
    parser.addHelpOption();
#ifdef ENABLE_CAN_MODE
    parser.addOption(opts.canModeOption);
    parser.addOption(opts.canIfOption);
#endif
    parser.addOption(opts.kuksaAddrOption);
    parser.addOption(opts.kuksaTlsOption);
    parser.addOption(opts.kuksaInsecureOption);
    parser.addOption(opts.kuksaCaOption);
    parser.addOption(opts.kuksaCertOption);
    parser.addOption(opts.kuksaKeyOption);
    parser.addOption(opts.kuksaTokenOption);
}

RunConfig buildRunConfig(const QCommandLineParser& parser, const CliOptions& opts)
{
    RunConfig config;
#ifdef ENABLE_CAN_MODE
    config.useKuksa = !parser.isSet(opts.canModeOption);
    config.canInterface = parser.value(opts.canIfOption);
#else
    config.useKuksa = true;
#endif
    const QString addr = parser.value(opts.kuksaAddrOption);
    config.kuksa.address = addr.isEmpty()
        ? QStringLiteral("localhost:55555")
        : addr;
    config.kuksa.use_ssl = parser.isSet(opts.kuksaTlsOption) && !parser.isSet(opts.kuksaInsecureOption);
    config.kuksa.root_ca_path = parser.value(opts.kuksaCaOption);
    config.kuksa.client_cert_path = parser.value(opts.kuksaCertOption);
    config.kuksa.client_key_path = parser.value(opts.kuksaKeyOption);
    config.kuksa.token = parser.value(opts.kuksaTokenOption);
    return config;
}

static bool hasRawFlag(const QStringList& args, const QString& flag)
{
    for (const auto& arg : args) {
        if (arg == flag || arg.startsWith(flag + "=")) {
            return true;
        }
    }
    return false;
}

bool validateOptions(const QCommandLineParser& parser, const CliOptions& opts, 
                     const RunConfig& config, const QStringList& rawArgs)
{
    bool ok = true;

    if (parser.isSet(opts.kuksaTlsOption) && parser.isSet(opts.kuksaInsecureOption)) {
        qCritical() << "Cannot combine --kuksa-tls with --kuksa-insecure.";
        ok = false;
    }
    if (parser.isSet(opts.kuksaTlsOption) && config.kuksa.root_ca_path.isEmpty()) {
        qCritical() << "--kuksa-tls requires --kuksa-ca to specify a root CA.";
        ok = false;
    }
#ifdef ENABLE_CAN_MODE
    if (!parser.isSet(opts.canModeOption) && parser.isSet(opts.canIfOption)) {
        qCritical() << "--can-if requires --can when CAN support is enabled.";
        ok = false;
    }
#else
    if (hasRawFlag(rawArgs, "--can") || hasRawFlag(rawArgs, "--can-if") || hasRawFlag(rawArgs, "-c")) {
        qCritical() << "CAN options require building with -DENABLE_CAN_MODE=ON.";
        ok = false;
    }
#endif

    return ok;
}

}  // namespace drivaui
