cmake_minimum_required(VERSION 3.14)
project(DrivaPi_MotorSensor)

# GoogleTest requires at least C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable CTest
enable_testing()

# --- GoogleTest ---
# Use FetchContent to download and configure GoogleTest
# This avoids system-wide installation issues
include(FetchContent)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG    release-1.14.0 # A known stable tag
)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# Add our source code library
add_subdirectory(src)

# Add our tests
add_subdirectory(tests)
