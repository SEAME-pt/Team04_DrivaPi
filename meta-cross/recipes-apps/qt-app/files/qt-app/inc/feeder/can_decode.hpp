/**
 * @file can_decode.hpp
 * @brief Helper functions for decoding CAN payloads
 * 
 * Provides little-endian decoding utilities for CAN frame data
 */

#pragma once

#include <cstdint>
#include <cstring>

namespace can_decode {

/**
 * @brief Read a single byte
 */
inline uint8_t U8(const uint8_t* data) {
    return data[0];
}

/**
 * @brief Read a 16-bit unsigned integer (little-endian)
 */
inline uint16_t U16Le(const uint8_t* data) {
    return static_cast<uint16_t>(data[0]) |
           (static_cast<uint16_t>(data[1]) << 8);
}

/**
 * @brief Read a 16-bit signed integer (little-endian)
 */
inline int16_t I16Le(const uint8_t* data) {
    return static_cast<int16_t>(U16Le(data));
}

/**
 * @brief Read a 32-bit unsigned integer (little-endian)
 */
inline uint32_t U32Le(const uint8_t* data) {
    return static_cast<uint32_t>(data[0]) |
           (static_cast<uint32_t>(data[1]) << 8) |
           (static_cast<uint32_t>(data[2]) << 16) |
           (static_cast<uint32_t>(data[3]) << 24);
}

/**
 * @brief Read a 32-bit signed integer (little-endian)
 */
inline int32_t I32Le(const uint8_t* data) {
    return static_cast<int32_t>(U32Le(data));
}

/**
 * @brief Read a float (little-endian, 4 bytes)
 */
inline float FloatLe(const uint8_t* data) {
    float result;
    std::memcpy(&result, data, sizeof(float));
    return result;
}

/**
 * @brief Read a double (little-endian, 8 bytes)
 */
inline double DoubleLe(const uint8_t* data) {
    double result;
    std::memcpy(&result, data, sizeof(double));
    return result;
}

} // namespace can_decode
