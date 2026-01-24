cmake_minimum_required(VERSION 3.16)
project(seame_qt_mel)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Use Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 SerialBus)

# --- Find Kuksa Middleware Dependencies ---
# Note: gRPC will also find Protobuf, so let gRPC do it first to avoid conflicts
find_package(gRPC REQUIRED)
find_program(gRPC_PLUGIN_EXECUTABLE grpc_cpp_plugin) # Tool to generate network code
find_package(absl REQUIRED) # Google common libraries (Critical dependency)

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
    # Step 1: Generate gRPC Network Stubs
    COMMAND ${Protobuf_PROTOC_EXECUTABLE} 
        --grpc_out=${GEN_DIR} 
        --plugin=protoc-gen-grpc=${gRPC_PLUGIN_EXECUTABLE} 
        -I${PROTO_DIR} 
        ${PROTO_V2_SRCS}
    # Step 2: Generate Data Serialization Classes
    COMMAND ${Protobuf_PROTOC_EXECUTABLE} 
        --cpp_out=${GEN_DIR} 
        -I${PROTO_DIR} 
        ${PROTO_V2_SRCS}
    DEPENDS ${PROTO_V2_SRCS}
)

# --- Qt Application Sources ---
option(ENABLE_CAN_MODE "Enable CAN mode in the Qt app (off for production)" OFF)

set(QT_APP_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/app_controller.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/cli_parser.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/vehicle_data.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/kuksa_reader.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/spotify_controller.cpp"
)

if(ENABLE_CAN_MODE)
    list(APPEND QT_APP_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/gui/can_reader.cpp")
endif()

# --- Model Sources (new in Phase 1) ---
set(MODEL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/system_status.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/notification_manager.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/can_logger.cpp"
)

# --- Feeder Sources ---
set(FEEDER_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/main.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/publisher.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/handlers.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/feeder_cli.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/feeder_signal.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/feeder/feeder_can.cpp"
)

# --- Qt Application Target ---
add_executable(myqtapp ${QT_APP_SOURCES} ${MODEL_SOURCES})

# --- Feeder Target ---
add_executable(kuksa_feeder ${FEEDER_SOURCES})

target_include_directories(myqtapp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/inc
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/models
    ${GEN_DIR}
)

if(ENABLE_CAN_MODE)
    target_compile_definitions(myqtapp PRIVATE ENABLE_CAN_MODE=1)
endif()

target_include_directories(kuksa_feeder PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/feeder
    ${GEN_DIR}
)

target_sources(myqtapp PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/resources.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/vehicle_data.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/kuksa_reader.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/spotify_controller.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/system_status.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/notification_manager.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/can_logger.hpp"
    "${GEN_DIR}/kuksa/val/v2/val.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/types.pb.cc"
)

if(ENABLE_CAN_MODE)
    target_sources(myqtapp PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/inc/gui/can_reader.hpp")
endif()

target_sources(kuksa_feeder PRIVATE
    "${GEN_DIR}/kuksa/val/v2/val.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/val.grpc.pb.cc"
    "${GEN_DIR}/kuksa/val/v2/types.pb.cc"
)

target_link_libraries(myqtapp PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2 Qt6::SerialBus
    gRPC::grpc++           # The gRPC Transport Layer
    protobuf::libprotobuf  # The Serialization Library
    absl::base             # Abseil Base (Required by gRPC)
    absl::strings          # Abseil Strings
    absl::log_internal_check_op # <--- Critical fix for "Undefined Symbol" linker errors
)

target_link_libraries(kuksa_feeder PRIVATE
    gRPC::grpc++           # The gRPC Transport Layer
    protobuf::libprotobuf  # The Serialization Library
    absl::base             # Abseil Base (Required by gRPC)
    absl::strings          # Abseil Strings
    absl::log_internal_check_op
)

install(TARGETS myqtapp kuksa_feeder RUNTIME DESTINATION bin)
