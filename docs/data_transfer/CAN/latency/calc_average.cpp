#include <iostream>
#include <fstream>
#include <string>
#include <cctype>
#include <cstdint>

int main(int argc, char* argv[]) {
    // Determine the file name based on the argument
    std::string filename = "can_rpi_to_stm_log.txt";
    if (argc > 1 && std::string(argv[1]) == "rasp")
        filename = "can_rpi_loopback_log.txt";
    else if (argc > 1 && std::string(argv[1]) == "stm")
        filename = "can_stm32_loopback_log.txt";

    std::ifstream infile(filename);
    if (!infile.is_open()) {
        std::cerr << "Failed to open file: " << filename << "\n";
        return 1;
    }

    std::string line;
    uint64_t sum = 0;
    int count = 0;

    while (std::getline(infile, line)) {
        // Remove leading/trailing spaces
        line.erase(0, line.find_first_not_of(" \t\n\r"));
        line.erase(line.find_last_not_of(" \t\n\r") + 1);

        bool numeric = !line.empty();
        for (char c : line) {
            if (!std::isdigit(c)) {
                numeric = false;
                break;
            }
        }

        if (numeric) {
            sum += std::stoull(line);
            count++;
        }
    }

    if (count > 0) {
        double average = static_cast<double>(sum) / count;
        std::cout << "Average latency: " << average << " µs over " << count << " measurements\n";
    } 
    else
        std::cout << "No numeric data found in the file.\n";
    return 0;
}
