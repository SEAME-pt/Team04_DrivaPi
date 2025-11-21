# Create the test executable
add_executable(motor_speed_test
    unit/test_motor_speed.cpp
)

# Link our test executable against our library and GoogleTest
target_link_libraries(motor_speed_test
    PRIVATE
        motor_sensor_lib
        GTest::gtest_main # This target is created by FetchContent
)

# Add the test to CTest (for the 'ctest' command)
include(GoogleTest)
gtest_discover_tests(motor_speed_test)
