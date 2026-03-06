cmake_minimum_required(VERSION 3.16)
project(seame_qt LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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
# zlib (Qt6Gui uses it - ensure it is on the final link line)
# ------------------------
find_package(ZLIB REQUIRED)

# ------------------------
# gRPC / Protobuf / Abseil
#
# Strategy:
# - Native host build: prefer CMake CONFIG packages (consistent toolchain/versions).
# - Cross/Yocto build: default to pkg-config (Yocto-friendly).
#
# You can force either path with:
#   -DUSE_PKGCONFIG_GRPC=ON/OFF
# ------------------------
if(NOT DEFINED USE_PKGCONFIG_GRPC)
    if(CMAKE_CROSSCOMPILING)
        set(USE_PKGCONFIG_GRPC ON)
    else()
        set(USE_PKGCONFIG_GRPC OFF)
    endif()
endif()

message(STATUS "USE_PKGCONFIG_GRPC = ${USE_PKGCONFIG_GRPC}")

set(HAVE_CMAKE_GRPC_STACK OFF)

if(NOT USE_PKGCONFIG_GRPC)
    # Prefer CONFIG packages (often from /usr/local when you have newer Abseil/Protobuf/gRPC there)
    find_package(Protobuf CONFIG QUIET)
    find_package(gRPC CONFIG QUIET)
    find_package(absl CONFIG QUIET)

    if(TARGET protobuf::libprotobuf AND TARGET gRPC::grpc++ AND TARGET absl::log_internal_check_op)
        set(HAVE_CMAKE_GRPC_STACK ON)
        message(STATUS "Using CMake CONFIG targets for Protobuf/gRPC/Abseil")
    else()
        message(STATUS "CMake CONFIG targets not complete. Falling back to pkg-config.")
        set(USE_PKGCONFIG_GRPC ON)
    endif()
endif()

# --- Codegen tools (protoc + grpc_cpp_plugin) ---
# Allow overrides from command line / bitbake:
#   -DProtobuf_PROTOC_EXECUTABLE=...
#   -DGRPC_CPP_PLUGIN_EXECUTABLE=...
set(_PROTOC "")
set(_GRPC_CPP_PLUGIN "")

if(DEFINED Protobuf_PROTOC_EXECUTABLE AND Protobuf_PROTOC_EXECUTABLE)
    set(_PROTOC "${Protobuf_PROTOC_EXECUTABLE}")
elseif(HAVE_CMAKE_GRPC_STACK AND TARGET protobuf::protoc)
    set(_PROTOC "$<TARGET_FILE:protobuf::protoc>")
else()
    find_program(_PROTOC protoc REQUIRED)
endif()

if(DEFINED GRPC_CPP_PLUGIN_EXECUTABLE AND GRPC_CPP_PLUGIN_EXECUTABLE)
    set(_GRPC_CPP_PLUGIN "${GRPC_CPP_PLUGIN_EXECUTABLE}")
elseif(HAVE_CMAKE_GRPC_STACK AND TARGET gRPC::grpc_cpp_plugin)
    set(_GRPC_CPP_PLUGIN "$<TARGET_FILE:gRPC::grpc_cpp_plugin>")
else()
    find_program(_GRPC_CPP_PLUGIN grpc_cpp_plugin REQUIRED)
endif()

if(NOT _PROTOC)
    message(FATAL_ERROR "protoc not found (set -DProtobuf_PROTOC_EXECUTABLE=...)")
endif()
if(NOT _GRPC_CPP_PLUGIN)
    message(FATAL_ERROR "grpc_cpp_plugin not found (set -DGRPC_CPP_PLUGIN_EXECUTABLE=...)")
endif()

message(STATUS "Using protoc: ${_PROTOC}")
message(STATUS "Using grpc_cpp_plugin: ${_GRPC_CPP_PLUGIN}")

# --- Linking stack selection ---
if(USE_PKGCONFIG_GRPC)
    # Yocto-friendly: rely on pkg-config
    pkg_check_modules(GRPC REQUIRED IMPORTED_TARGET grpc++)
    pkg_check_modules(PROTOBUF REQUIRED IMPORTED_TARGET protobuf)

    # You said you NEED this (functions used in your code). Keep REQUIRED.
    pkg_check_modules(ABSL REQUIRED IMPORTED_TARGET
        absl_hash
        absl_strings
        absl_base
        absl_log_internal_check_op
        absl_synchronization
        absl_time
    )
else()
    # Native host: use CMake targets (better transitive deps, avoids static link hell)
    # Enforce required Abseil components as TARGETS:
    set(_ABSL_REQUIRED_TARGETS
        absl::hash
        absl::strings
        absl::base
        absl::log_internal_check_op
        absl::synchronization
        absl::time
    )
    foreach(_t IN LISTS _ABSL_REQUIRED_TARGETS)
        if(NOT TARGET ${_t})
            message(FATAL_ERROR "Required Abseil target missing: ${_t}. Install a newer Abseil (with logging) or use -DUSE_PKGCONFIG_GRPC=ON with matching .pc files.")
        endif()
    endforeach()
endif()

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
    COMMAND ${_PROTOC}
        "--grpc_out=${GEN_DIR}"
        "--plugin=protoc-gen-grpc=${_GRPC_CPP_PLUGIN}"
        "-I${PROTO_DIR}"
        "${PROTO_DIR}/kuksa/val/v2/val.proto"
        "${PROTO_DIR}/kuksa/val/v2/types.proto"
    COMMAND ${_PROTOC}
        "--cpp_out=${GEN_DIR}"
        "-I${PROTO_DIR}"
        "${PROTO_DIR}/kuksa/val/v2/val.proto"
        "${PROTO_DIR}/kuksa/val/v2/types.proto"
    DEPENDS ${PROTO_V2_SRCS}
    VERBATIM
)

set(GEN_PROTO_SRCS
    "${GEN_DIR}/kuksa/val/v2/val.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/types.pb.cc"
)

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
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/pi_health_reader.cpp"
)

# ------------------------
# Feeder Sources
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

target_include_directories(myqtapp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/gui
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/models
    ${GEN_DIR}
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
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/app_controller.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/cli_parser.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/vehicle_data.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/kuksa_reader.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/settings_manager.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/music_player_controller.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/pi_health_reader.hpp"
)

if(ENABLE_CAN_MODE)
    target_sources(myqtapp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/can_reader.hpp")
endif()

# ------------------------
# Linking
# ------------------------

# Important for the Qt6Gui -> zlib:
# - Make sure zlib is explicitly linked
# - And avoid --as-needed discarding it due to order
if(UNIX AND NOT APPLE)
    target_link_options(myqtapp PRIVATE "-Wl,--no-as-needed")
endif()

target_link_libraries(myqtapp PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2
    Qt6::SerialBus Qt6::Network Qt6::Multimedia
    PkgConfig::TAGLIB
)

if(USE_PKGCONFIG_GRPC)
    target_link_libraries(myqtapp PRIVATE
        PkgConfig::GRPC
        PkgConfig::PROTOBUF
        PkgConfig::ABSL
    )
    target_link_libraries(kuksa_feeder PRIVATE
        PkgConfig::GRPC
        PkgConfig::PROTOBUF
        PkgConfig::ABSL
    )
else()
    target_link_libraries(myqtapp PRIVATE
        gRPC::grpc++
        protobuf::libprotobuf
        absl::hash
        absl::strings
        absl::base
        absl::log_internal_check_op
        absl::synchronization
        absl::time
    )
    target_link_libraries(kuksa_feeder PRIVATE
        gRPC::grpc++
        protobuf::libprotobuf
        absl::hash
        absl::strings
        absl::base
        absl::log_internal_check_op
        absl::synchronization
        absl::time
    )
endif()

# Put ZLIB at the end to guarantee correct link order
target_link_libraries(myqtapp PRIVATE ZLIB::ZLIB)

# ------------------------
# Install
# ------------------------
include(GNUInstallDirs)

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml/"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/qt-app/resources/qml"
        FILES_MATCHING
            PATTERN "*.qml" PATTERN "*.js" PATTERN "*.png" PATTERN "*.jpg" PATTERN "*.svg"
            PATTERN "qmldir" PATTERN "*.frag" PATTERN "*.qsb"
)

install(TARGETS myqtapp kuksa_feeder
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
