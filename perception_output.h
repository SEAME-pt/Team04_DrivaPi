#ifndef PERCEPTION_OUTPUT_H
#define PERCEPTION_OUTPUT_H

#include <stdint.h>

typedef struct {
    float cte;
    float heading_error;
    float confidence;
    uint8_t valid;
    uint64_t timestamp;
} PerceptionOutput;

#endif // PERCEPTION_OUTPUT_H
