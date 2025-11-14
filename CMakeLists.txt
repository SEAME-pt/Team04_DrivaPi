cmake_minimum_required(VERSION 3.14)
project(DrivaPi_MotorSensor)

# GoogleTest requires at least C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable CTest
enable_testing()

# --- GoogleTest ---
# UPDATED: Switched from GIT_REPOSITORY to URL
# This is more robust in CI environments and avoids sub-build git failures.
# This URL is from the official GoogleTest quickstart
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Add our source code library
add_subdirectory(src)

# Add our tests
add_subdirectory(tests)
