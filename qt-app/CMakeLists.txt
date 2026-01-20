cmake_minimum_required(VERSION 3.16)
project(seame_qt_mel)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Use Qt6
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 SerialBus)

# --- Find Kuksa Middleware Dependencies ---
find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)
find_program(gRPC_PLUGIN_EXECUTABLE grpc_cpp_plugin) # Tool to generate network code
find_package(absl REQUIRED) # Google common libraries (Critical dependency)

# --- Protocol Buffers Code Generation ---
# Define paths for input (.proto) and output (generated C++)
set(PROTO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/proto")
set(PROTO_SRCS "${PROTO_DIR}/val.proto" "${PROTO_DIR}/types.proto")
set(GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY ${GEN_DIR})

# Command to auto-generate C++ sources from .proto files before compilation
add_custom_command(
    OUTPUT "${GEN_DIR}/val.pb.cc" "${GEN_DIR}/val.pb.h" 
           "${GEN_DIR}/val.grpc.pb.cc" "${GEN_DIR}/val.grpc.pb.h"
           "${GEN_DIR}/types.pb.cc" "${GEN_DIR}/types.pb.h"
    # Step 1: Generate gRPC Network Stubs
    COMMAND ${Protobuf_PROTOC_EXECUTABLE} 
    ARGS --grpc_out=${GEN_DIR} --plugin=protoc-gen-grpc=${gRPC_PLUGIN_EXECUTABLE} -I${PROTO_DIR} ${PROTO_SRCS}
    # Step 2: Generate Data Serialization Classes
    COMMAND ${Protobuf_PROTOC_EXECUTABLE} 
    ARGS --cpp_out=${GEN_DIR} -I${PROTO_DIR} ${PROTO_SRCS}
    DEPENDS ${PROTO_SRCS}
)

file(GLOB_RECURSE APP_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp"
)

# --- Model Sources (new in Phase 1) ---
set(MODEL_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/system_status.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/notification_manager.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/models/can_logger.cpp"
)

add_executable(myqtapp ${APP_SOURCES} ${MODEL_SOURCES})

target_include_directories(myqtapp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/inc
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/models
    ${GEN_DIR}
)

target_sources(myqtapp PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/qml.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/resources/resources.qrc"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/vehicle_data.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/can_reader.hpp"  
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/kuksa_reader.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/system_status.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/notification_manager.hpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc/models/can_logger.hpp"
    "${GEN_DIR}/val.pb.cc"
    "${GEN_DIR}/val.grpc.pb.cc"
    "${GEN_DIR}/types.pb.cc"
)

target_link_libraries(myqtapp PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2 Qt6::SerialBus
    gRPC::grpc++           # The gRPC Transport Layer
    protobuf::libprotobuf  # The Serialization Library
    absl::base             # Abseil Base (Required by gRPC)
    absl::strings          # Abseil Strings
    absl::log_internal_check_op # <--- Critical fix for "Undefined Symbol" linker errors
)


install(TARGETS myqtapp RUNTIME DESTINATION bin)
