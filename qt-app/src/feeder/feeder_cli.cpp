#include "feeder_cli.hpp"
#include <iostream>
#include <cstring>

namespace feeder {

FeederConfig ParseArgs(int argc, char** argv)
{
    FeederConfig config;
    config.publisher_options.address = "localhost:55555";
    config.publisher_options.use_ssl = false;
    config.can_interface = "vcan0";

    // Parse options starting from index 1
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        
        if (arg == "--insecure") {
            config.publisher_options.use_ssl = false;
        } 
        else if (arg == "--tls") {
            config.publisher_options.use_ssl = true;
        } 
        else if (arg == "--ca" && i + 1 < argc) {
            config.publisher_options.root_ca_path = argv[++i];
        }
        else if (arg == "--cert" && i + 1 < argc) {
            config.publisher_options.client_cert_path = argv[++i];
        }
        else if (arg == "--key" && i + 1 < argc) {
            config.publisher_options.client_key_path = argv[++i];
        }
        else if (arg == "--token" && i + 1 < argc) {
            config.publisher_options.token = argv[++i];
        }
        else if (arg == "--can-if" && i + 1 < argc) {
            config.can_interface = argv[++i];
        }
        else if (arg == "--address" && i + 1 < argc) {
            config.publisher_options.address = argv[++i];
        } 
        else if (arg == "--help" || arg == "-h") {
            PrintUsage(argv[0]);
            exit(0);
        }
        else if (arg[0] != '-') {
            // Treat as positional: first non-flag is interface, second is address
            static int positionalCount = 0;
            if (positionalCount == 0) {
                config.can_interface = arg;
                positionalCount++;
            } else if (positionalCount == 1) {
                config.publisher_options.address = arg;
                positionalCount++;
            }
        }
        else {
            std::cerr << "[CLI] Unknown option: " << arg << std::endl;
        }
    }

    return config;
}

void PrintConfig(const FeederConfig& config)
{
    std::cout << "========================================" << std::endl;
    std::cout << "  KUKSA CAN Feeder Configuration" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "CAN Interface:    " << config.can_interface << std::endl;
    std::cout << "KUKSA Address:    " << config.publisher_options.address << std::endl;
    std::cout << "Security Mode:    " << (config.publisher_options.use_ssl ? "TLS" : "Insecure") << std::endl;
    if (!config.publisher_options.root_ca_path.empty()) {
        std::cout << "Root CA:          " << config.publisher_options.root_ca_path << std::endl;
    }
    if (!config.publisher_options.client_cert_path.empty()) {
        std::cout << "Client Cert:      " << config.publisher_options.client_cert_path << std::endl;
    }
    if (!config.publisher_options.client_key_path.empty()) {
        std::cout << "Client Key:       " << config.publisher_options.client_key_path << std::endl;
    }
    if (!config.publisher_options.token.empty()) {
        std::cout << "Authorization:    Bearer <token>" << std::endl;
    }
    std::cout << "========================================" << std::endl;
}

void PrintUsage(const std::string& program_name)
{
    std::cout << "\nUsage: " << program_name 
              << " [options] [can_interface] [kuksa_address]\n" 
              << "\nPositional Arguments (optional):\n"
              << "  can_interface     CAN interface name (default: vcan0)\n"
              << "  kuksa_address     KUKSA databroker host:port (default: localhost:55555)\n"
              << "\nOptions:\n"
              << "  --insecure        Use insecure channel (default)\n"
              << "  --tls             Use TLS encrypted channel\n"
              << "  --ca <path>       Root CA certificate path (for TLS)\n"
              << "  --cert <path>     Client certificate path (for mTLS)\n"
              << "  --key <path>      Client private key path (for mTLS)\n"
              << "  --token <jwt>     Authorization token (JWT)\n"
              << "  --can-if <name>   CAN interface name\n"
              << "  --address <addr>  KUKSA databroker host:port\n"
              << "  --help, -h        Show this help message\n"
              << "\nExamples:\n"
              << "  " << program_name << " vcan0 localhost:55555\n"
              << "  " << program_name << " --tls --ca ca.crt --cert client.crt --key client.key\n"
              << "  " << program_name << " --can-if can0 --address databroker.local:55555 --tls\n"
              << std::endl;
}

} // namespace feeder
