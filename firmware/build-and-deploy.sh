#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# DrivaPi Firmware Build & Deploy Script
# Compiles ThreadX modules and main firmware, then flashes to STM32
# ==============================================================================

FIRMWARE_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$FIRMWARE_DIR/modules/speed_sensor_module"
SENSORS_MODULE_DIR="$FIRMWARE_DIR/modules/sensors_module"
ULTRASONIC_MODULE_DIR="$FIRMWARE_DIR/modules/ultrasonic_module"
DC_MOTOR_MODULE_DIR="$FIRMWARE_DIR/modules/dc_motor_module"
SERVO_MOTOR_MODULE_DIR="$FIRMWARE_DIR/modules/servo_motor_module"
HEALTH_MODULE_DIR="$FIRMWARE_DIR/modules/health_module"
DEBUG_DIR="$FIRMWARE_DIR/Debug"

# ==============================================================================
# Build ThreadX Modules
# ==============================================================================
function build_module() {
    echo "=================================="
    echo "Building ThreadX Modules..."
    echo "=================================="

    "$MODULE_DIR/build-speed-sensor-module.sh"
    SPEED_MODULE_SIZE=$(stat -f%z "$MODULE_DIR/build/speed_sensor_module.bin" 2>/dev/null || stat -c%s "$MODULE_DIR/build/speed_sensor_module.bin")
    echo "✓ Speed module built: $SPEED_MODULE_SIZE bytes"

    "$SENSORS_MODULE_DIR/build-sensors-module.sh"
    SENSORS_MODULE_SIZE=$(stat -f%z "$SENSORS_MODULE_DIR/build/sensors_module.bin" 2>/dev/null || stat -c%s "$SENSORS_MODULE_DIR/build/sensors_module.bin")
    echo "✓ Sensors module built: $SENSORS_MODULE_SIZE bytes"

    "$ULTRASONIC_MODULE_DIR/build-ultrasonic-module.sh"
    ULTRASONIC_MODULE_SIZE=$(stat -f%z "$ULTRASONIC_MODULE_DIR/build/ultrasonic_module.bin" 2>/dev/null || stat -c%s "$ULTRASONIC_MODULE_DIR/build/ultrasonic_module.bin")
    echo "✓ Ultrasonic module built: $ULTRASONIC_MODULE_SIZE bytes"

    "$DC_MOTOR_MODULE_DIR/build-dc-motor-module.sh"
    DC_MOTOR_MODULE_SIZE=$(stat -f%z "$DC_MOTOR_MODULE_DIR/build/dc_motor_module.bin" 2>/dev/null || stat -c%s "$DC_MOTOR_MODULE_DIR/build/dc_motor_module.bin")
    echo "✓ DC motor module built: $DC_MOTOR_MODULE_SIZE bytes"

    "$SERVO_MOTOR_MODULE_DIR/build-servo-motor-module.sh"
    SERVO_MOTOR_MODULE_SIZE=$(stat -f%z "$SERVO_MOTOR_MODULE_DIR/build/servo_motor_module.bin" 2>/dev/null || stat -c%s "$SERVO_MOTOR_MODULE_DIR/build/servo_motor_module.bin")
    echo "✓ Servo motor module built: $SERVO_MOTOR_MODULE_SIZE bytes"

    "$HEALTH_MODULE_DIR/build-health-module.sh"
    HEALTH_MODULE_SIZE=$(stat -f%z "$HEALTH_MODULE_DIR/build/health_module.bin" 2>/dev/null || stat -c%s "$HEALTH_MODULE_DIR/build/health_module.bin")
    echo "✓ Health module built: $HEALTH_MODULE_SIZE bytes"
}

# ==============================================================================
# Build Main Firmware
# ==============================================================================
function build_firmware() {
    echo ""
    echo "=================================="
    echo "Building Main Firmware..."
    echo "=================================="
    
    cd "$DEBUG_DIR"
    make all
    
    ELF="firmware.elf"
    BIN="firmware.bin"
    
    if [ ! -f "$ELF" ]; then
        echo "Error: $ELF not found after build!"
        exit 1
    fi
    
    arm-none-eabi-objcopy -O binary "$ELF" "$BIN"
    
    FIRMWARE_SIZE=$(stat -f%z "$BIN" 2>/dev/null || stat -c%s "$BIN")
    echo "✓ Firmware built successfully: $FIRMWARE_SIZE bytes"
}

# ==============================================================================
# Flash to STM32
# ==============================================================================
function flash_firmware() {
    echo ""
    echo "=================================="
    echo "Flashing to STM32..."
    echo "=================================="
    
    BIN="$DEBUG_DIR/firmware.bin"
    FLASH_ADDR="0x08000000"
    
    if [ ! -f "$BIN" ]; then
        echo "Error: $BIN not found. Build first!"
        exit 1
    fi
    
    st-flash write "$BIN" "$FLASH_ADDR"
    echo "✓ Flash complete!"
}

# ==============================================================================
# Clean module build artifacts
# ==============================================================================
function clean_modules() {
    echo "Cleaning module build artifacts..."
    rm -rf "$MODULE_DIR/build"
    rm -rf "$SENSORS_MODULE_DIR/build"
    rm -rf "$ULTRASONIC_MODULE_DIR/build"
    rm -rf "$DC_MOTOR_MODULE_DIR/build"
    rm -rf "$SERVO_MOTOR_MODULE_DIR/build"
    rm -rf "$HEALTH_MODULE_DIR/build"
    echo "✓ Module clean complete!"
}

# ==============================================================================
# Clean all build artifacts
# ==============================================================================
function clean() {
    echo "Cleaning build artifacts..."

    clean_modules

    cd "$DEBUG_DIR"
    make clean
    rm -f firmware.bin
    echo "✓ Clean complete!"
}

# ==============================================================================
# Usage and main
# ==============================================================================
function usage() {
    cat <<EOF
DrivaPi Firmware Build & Deploy Script

Usage: $0 {build|flash|deploy|clean}

Commands:
        build   - Compile all modules and main firmware
  flash   - Flash existing firmware to STM32
  deploy  - Build then flash to STM32
    clean   - Remove all build artifacts (modules + firmware)

Examples:
  $0 build              # Just compile
  $0 deploy             # Compile and flash (full deployment)
  $0 clean              # Clean build files

EOF
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

case "$1" in
    build)
        build_module
        build_firmware
        ;;
    flash)
        flash_firmware
        ;;
    deploy)
        build_module
        build_firmware
        flash_firmware
        ;;
    clean)
        clean
        ;;
    *)
        echo "Unknown command: $1"
        usage
        exit 1
        ;;
esac

echo ""
echo "✓ Done!"
