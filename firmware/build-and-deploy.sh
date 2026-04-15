#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# DrivaPi Firmware Build & Deploy Script
# Compiles the ThreadX speed and sensors modules and main firmware, then flashes to STM32
# ==============================================================================

FIRMWARE_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$FIRMWARE_DIR/modules/speed_sensor_module"
SENSORS_MODULE_DIR="$FIRMWARE_DIR/modules/sensors_module"
DEBUG_DIR="$FIRMWARE_DIR/Debug"

# ==============================================================================
# Build Speed Sensor Module
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
    build   - Compile speed + sensors modules and main firmware
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
