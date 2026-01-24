#pragma once

#include "publisher.hpp"
#include <string>

namespace feeder {

/**
 * @struct FeederConfig
 * @brief Configuration parsed from command-line arguments
 */
struct FeederConfig {
    std::string can_interface = "vcan0";
    kuksa::PublisherOptions publisher_options;
};

/**
 * @brief Parse command-line arguments into FeederConfig
 * @param argc Argument count
 * @param argv Argument values
 * @return FeederConfig with parsed values, or defaults on error
 */
FeederConfig ParseArgs(int argc, char** argv);

/**
 * @brief Print parsed configuration to stdout
 * @param config The configuration to display
 */
void PrintConfig(const FeederConfig& config);

/**
 * @brief Print usage/help message to stdout
 * @param program_name Name of the executable
 */
void PrintUsage(const std::string& program_name);

} // namespace feeder
