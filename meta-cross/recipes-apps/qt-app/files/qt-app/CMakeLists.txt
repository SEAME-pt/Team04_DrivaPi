cmake_minimum_required(VERSION 3.16)
project(seame_qt_mel)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Use Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 SerialBus Network Multimedia)

# Find TagLib for MP3 metadata extraction
find_package(PkgConfig REQUIRED)
pkg_check_modules(TAGLIB REQUIRED IMPORTED_TARGET taglib)

# --- Find Kuksa Middleware Dependencies ---
# In Yocto/AGL, we need to handle protobuf/gRPC differently
# Check if the variables are passed from the recipe
if(NOT DEFINED Protobuf_PROTOC_EXECUTABLE)
    find_package(Protobuf REQUIRED)
else()
    message(STATUS "Using protoc from recipe: ${Protobuf_PROTOC_EXECUTABLE}")
endif()

if(NOT DEFINED gRPC_PLUGIN_EXECUTABLE)
    find_package(gRPC REQUIRED)
    find_program(GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
else()
    set(GRPC_CPP_PLUGIN_EXECUTABLE ${gRPC_PLUGIN_EXECUTABLE})
    message(STATUS "Using grpc_cpp_plugin from recipe: ${gRPC_PLUGIN_EXECUTABLE}")
endif()

find_package(absl REQUIRED) # Google common libraries

# --- Protocol Buffers Code Generation (VAL v2) ---
# Define paths for input (.proto) and output (generated C++)
set(PROTO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/proto")
set(PROTO_V2_SRCS
    "${PROTO_DIR}/kuksa/val/v2/val.proto"
    "${PROTO_DIR}/kuksa/val/v2/types.proto"
)
set(GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY ${GEN_DIR})

# Command to auto-generate C++ sources from VAL v2 .proto files before compilation
add_custom_command(
    OUTPUT "${GEN_DIR}/kuksa/val/v2/val.pb.cc" "${GEN_DIR}/kuksa/val/v2/val.pb.h"
           "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.cc" "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.h"
           "${GEN_DIR}/kuksa/val/v2/types.pb.cc" "${GEN_DIR}/kuksa/val/v2/types.pb.h"
    # Use the protoc executable from the recipe variable
    COMMAND ${Protobuf_PROTOC_EXECUTABLE}
        "--grpc_out=${GEN_DIR}"
        "--plugin=protoc-gen-grpc=${GRPC_CPP_PLUGIN_EXECUTABLE}"
        "-I${PROTO_DIR}"
        "${PROTO_DIR}/kuksa/val/v2/val.proto"
        "${PROTO_DIR}/kuksa/val/v2/types.proto"
    # Generate protobuf serialization code
    COMMAND ${Protobuf_PROTOC_EXECUTABLE}
        "--cpp_out=${GEN_DIR}"
        "-I${PROTO_DIR}"
        "${PROTO_DIR}/kuksa/val/v2/val.proto"
        "${PROTO_DIR}/kuksa/val/v2/types.proto"
    DEPENDS ${PROTO_V2_SRCS}
    VERBATIM
)

# --- Qt Application Sources ---
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

# --- Model Sources (new in Phase 1) ---
set(MODEL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/system_status.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/notification_manager.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/can_logger.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/pi_health_reader.cpp"
)

# --- Qt Application Target ---
add_executable(myqtapp ${QT_APP_SOURCES} ${MODEL_SOURCES})

target_include_directories(myqtapp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/gui
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/models
    ${GEN_DIR}
)

if(ENABLE_CAN_MODE)
    target_compile_definitions(myqtapp PRIVATE ENABLE_CAN_MODE=1)
endif()

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
    "${GEN_DIR}/kuksa/val/v2/val.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/types.pb.cc"
)

if(ENABLE_CAN_MODE)
    target_sources(myqtapp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/can_reader.hpp")
endif()

# Use pkg-config for gRPC and Abseil to get all dependencies automatically
find_package(PkgConfig REQUIRED)
pkg_check_modules(GRPC REQUIRED grpc++)
pkg_check_modules(PROTOBUF REQUIRED protobuf)
pkg_check_modules(ABSL REQUIRED absl_hash absl_strings absl_base absl_log_internal_check_op absl_synchronization absl_time)

# Then link with pkg-config imported targets
target_link_libraries(myqtapp PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2 Qt6::SerialBus Qt6::Network Qt6::Multimedia
    PkgConfig::TAGLIB
    ${GRPC_LIBRARIES}
    ${ABSL_LIBRARIES}
	${PROTOBUF_LIBRARIES}
)

include(GNUInstallDirs)

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml/"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/qt-app/resources/qml"
        FILES_MATCHING PATTERN "*.qml" PATTERN "*.js" PATTERN "*.png" PATTERN "*.jpg" PATTERN "*.svg")

install(TARGETS myqtapp
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
