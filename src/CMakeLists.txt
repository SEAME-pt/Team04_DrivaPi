# Create a library from our sensor source files
add_library(motor_sensor_lib
    sensors/motor_speed.cpp
)

# Publicly expose the include directory (src/)
# This allows targets that link this library to find "sensors/motor_speed.h"
target_include_directories(motor_sensor_lib
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)
