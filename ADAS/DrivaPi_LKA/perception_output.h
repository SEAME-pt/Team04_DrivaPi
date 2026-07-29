#ifndef PERCEPTION_OUTPUT_H
#define PERCEPTION_OUTPUT_H

#include <stdint.h>

typedef struct {
    float closest_front_point;
    float heading_error;
    float confidence;
    uint8_t valid;
    uint64_t timestamp;
} PerceptionOutput;

typedef struct {
    uint8_t sign_detected;
    float   confidence;
} ObstacleOutput;

#endif // PERCEPTION_OUTPUT_H
