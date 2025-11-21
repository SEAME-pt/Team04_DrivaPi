cmake_minimum_required(VERSION 3.16)
project(seame_qt_mel)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Use Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2)

file(GLOB_RECURSE APP_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
)

add_executable(myqtapp ${APP_SOURCES})

target_include_directories(myqtapp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_sources(myqtapp PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/resources.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/include/vehicledata.hpp"  # ensure automoc
)

target_link_libraries(myqtapp PRIVATE Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2)


install(TARGETS myqtapp RUNTIME DESTINATION bin)
