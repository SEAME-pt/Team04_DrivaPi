cmake_minimum_required(VERSION 3.16)
project(seame_qt_mel)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# ------------------------
# Qt6
# ------------------------
find_package(Qt6 REQUIRED COMPONENTS
    Core Gui Quick Qml QuickControls2 SerialBus Network Multimedia
)

# ------------------------
# TagLib (MP3 metadata)
# ------------------------
find_package(PkgConfig REQUIRED)
pkg_check_modules(TAGLIB REQUIRED IMPORTED_TARGET taglib)

# ------------------------
# gRPC / Protobuf / Abseil (Yocto-friendly)
# ------------------------
# Find gRPC FIRST (it will find Protobuf as a dependency)
find_package(gRPC QUIET)

# Only call find_package(Protobuf) if gRPC didn't find it
if(NOT TARGET protobuf::protoc)
    find_package(Protobuf REQUIRED)
endif()

# Get grpc_cpp_plugin executable
if(TARGET gRPC::grpc_cpp_plugin)
    get_target_property(GRPC_CPP_PLUGIN_EXECUTABLE gRPC::grpc_cpp_plugin LOCATION)
else()
    # Fallback for Yocto: search PATH for the plugin
    find_program(GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin REQUIRED)
endif()

if(NOT GRPC_CPP_PLUGIN_EXECUTABLE)
    message(FATAL_ERROR "grpc_cpp_plugin not found")
endif()

message(STATUS "Using protoc: ${Protobuf_PROTOC_EXECUTABLE}")
message(STATUS "Using grpc_cpp_plugin: ${GRPC_CPP_PLUGIN_EXECUTABLE}")

# Use pkg-config for linking (more reliable on Yocto)
pkg_check_modules(GRPC REQUIRED IMPORTED_TARGET grpc++)
pkg_check_modules(PROTOBUF REQUIRED IMPORTED_TARGET protobuf)
pkg_check_modules(ABSL REQUIRED IMPORTED_TARGET
    absl_hash
    absl_strings
    absl_base
    absl_log_internal_check_op
    absl_synchronization
    absl_time
)

# ------------------------
# Protocol Buffers Code Generation (VAL v2)
# ------------------------
set(PROTO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/proto")
set(PROTO_V2_SRCS
    "${PROTO_DIR}/kuksa/val/v2/val.proto"
    "${PROTO_DIR}/kuksa/val/v2/types.proto"
)

set(GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY ${GEN_DIR})

add_custom_command(
    OUTPUT
        "${GEN_DIR}/kuksa/val/v2/val.pb.cc" "${GEN_DIR}/kuksa/val/v2/val.pb.h"
        "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.cc" "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.h"
        "${GEN_DIR}/kuksa/val/v2/types.pb.cc" "${GEN_DIR}/kuksa/val/v2/types.pb.h"
    COMMAND ${Protobuf_PROTOC_EXECUTABLE}
        "--grpc_out=${GEN_DIR}"
        "--plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN_EXECUTABLE}"
        "-I${PROTO_DIR}"
        "${PROTO_DIR}/kuksa/val/v2/val.proto"
        "${PROTO_DIR}/kuksa/val/v2/types.proto"
    COMMAND ${Protobuf_PROTOC_EXECUTABLE}
        "--cpp_out=${GEN_DIR}"
        "-I${PROTO_DIR}"
        "${PROTO_DIR}/kuksa/val/v2/val.proto"
        "${PROTO_DIR}/kuksa/val/v2/types.proto"
    DEPENDS ${PROTO_V2_SRCS}
    VERBATIM
)

# Convenience list so both targets can depend on generated sources
set(GEN_PROTO_SRCS
    "${GEN_DIR}/kuksa/val/v2/val.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/types.pb.cc"
)

# Mark generated files as generated
set_source_files_properties(${GEN_PROTO_SRCS} PROPERTIES GENERATED TRUE)

# ------------------------
# App Sources
# ------------------------
option(ENABLE_CAN_MODE "Enable CAN mode in the Qt app (off for production)" OFF)

set(QT_APP_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/app_controller.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/cli_parser.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/vehicle_data.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/kuksa_reader.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/settings_manager.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/music_player_controller.cpp"
)

if(ENABLE_CAN_MODE)
    list(APPEND QT_APP_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/can_reader.cpp")
endif()

set(MODEL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/system_status.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/notification_manager.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/can_logger.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/pi_health_reader.cpp"
)

# ------------------------
# Feeder Sources (Kuksa provider / feeder)
# ------------------------
set(FEEDER_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/publisher.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/handlers.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/feeder_cli.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/feeder_signal.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/feeder_can.cpp"
)

# ------------------------
# Targets
# ------------------------
add_executable(myqtapp
    ${QT_APP_SOURCES}
    ${MODEL_SOURCES}
    ${GEN_PROTO_SRCS}
)

add_executable(kuksa_feeder
    ${FEEDER_SOURCES}
    ${GEN_PROTO_SRCS}
)

# Ensure generated files exist before compiling
add_dependencies(myqtapp)

target_include_directories(myqtapp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/gui
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/models
    ${GEN_DIR}
    ${GRPC_INCLUDE_DIRS}
    ${PROTOBUF_INCLUDE_DIRS}
    ${ABSL_INCLUDE_DIRS}
)

target_include_directories(kuksa_feeder PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/feeder
    ${GEN_DIR}
)

if(ENABLE_CAN_MODE)
    target_compile_definitions(myqtapp PRIVATE ENABLE_CAN_MODE=1)
endif()

# QRC sources only needed for app
target_sources(myqtapp PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/resources.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/app_controller.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/cli_parser.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/vehicle_data.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/kuksa_reader.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/settings_manager.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/music_player_controller.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/system_status.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/notification_manager.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/can_logger.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/pi_health_reader.hpp"
)

if(ENABLE_CAN_MODE)
    target_sources(myqtapp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/can_reader.hpp")
endif()

# ------------------------
# Linking
# ------------------------
target_link_libraries(myqtapp PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2
    Qt6::SerialBus Qt6::Network Qt6::Multimedia
    PkgConfig::TAGLIB
    PkgConfig::GRPC
    PkgConfig::PROTOBUF
    PkgConfig::ABSL
)

target_link_libraries(kuksa_feeder PRIVATE
    PkgConfig::GRPC
    PkgConfig::PROTOBUF
    PkgConfig::ABSL
)

# Remove the old include_directories calls - pkg-config targets handle them automatically

# ------------------------
# Install
# ------------------------
include(GNUInstallDirs)

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml/"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/qt-app/resources/qml"
        FILES_MATCHING PATTERN "*.qml" PATTERN "*.js" PATTERN "*.png" PATTERN "*.jpg" PATTERN "*.svg")

install(TARGETS myqtapp kuksa_feeder
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
