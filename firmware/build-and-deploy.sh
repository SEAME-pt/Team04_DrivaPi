#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# DrivaPi Firmware Build & Deploy Script
# Compiles the ThreadX speed sensor module and main firmware, then flashes to STM32
# ==============================================================================

FIRMWARE_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULE_DIR="$FIRMWARE_DIR/modules/speed_sensor_module"
BUILD_DIR="$MODULE_DIR/build"
DEBUG_DIR="$FIRMWARE_DIR/Debug"
OUT_C="$FIRMWARE_DIR/Core/Src/speed_sensor_module_image.c"

# ==============================================================================
# Build Speed Sensor Module
# ==============================================================================
function build_module() {
    echo "=================================="
    echo "Building Speed Sensor Module..."
    echo "=================================="
    
    mkdir -p "$BUILD_DIR"
    rm -f "$BUILD_DIR"/*

    CC=arm-none-eabi-gcc
    OBJCOPY=arm-none-eabi-objcopy
    NM=arm-none-eabi-nm

    THREADX_BASE="$FIRMWARE_DIR/Middlewares/ST/threadx"

    INCLUDES=(
        -I"$FIRMWARE_DIR/Core/Inc"
        -I"$THREADX_BASE/common/inc"
        -I"$THREADX_BASE/common_modules/inc"
        -I"$THREADX_BASE/ports/cortex_m33/gnu/inc"
        -I"$THREADX_BASE/ports_module/cortex_m33/gnu/inc"
    )

    CFLAGS=(
        -mcpu=cortex-m33
        -mthumb
        -mfpu=fpv5-sp-d16
        -mfloat-abi=hard
        -O2
        -g0
        -ffunction-sections
        -fdata-sections
        -fno-exceptions
        -fno-unwind-tables
        -fno-asynchronous-unwind-tables
        -fPIC
        -msingle-pic-base
        -mpic-register=r9
        -mno-pic-data-is-text-relative
        -DTXM_MODULE
    )

    ASFLAGS=(
        -mcpu=cortex-m33
        -mthumb
        -mfpu=fpv5-sp-d16
        -mfloat-abi=hard
        -x assembler-with-cpp
    )

    MODULE_SRCS=(
        "$MODULE_DIR/speed_sensor_module.c"
        "$THREADX_BASE/common_modules/module_lib/src/txm_module_application_request.c"
        "$THREADX_BASE/common_modules/module_lib/src/txm_module_callback_request_thread_entry.c"
        "$THREADX_BASE/common_modules/module_lib/src/txm_queue_receive.c"
        "$THREADX_BASE/common_modules/module_lib/src/txm_thread_resume.c"
        "$THREADX_BASE/common_modules/module_lib/src/txm_thread_sleep.c"
        "$THREADX_BASE/common_modules/module_lib/src/txm_module_thread_system_suspend.c"
        "$THREADX_BASE/ports_module/cortex_m33/gnu/module_lib/src/txm_module_thread_shell_entry.c"
    )

    echo "Compiling module sources..."
    for src in "${MODULE_SRCS[@]}"; do
        obj="$BUILD_DIR/$(basename "${src%.*}").o"
        echo "  Compiling: $(basename "$src")"
        "$CC" "${CFLAGS[@]}" "${INCLUDES[@]}" -c "$src" -o "$obj"
    done

    echo "Assembling module assembly..."
    "$CC" "${ASFLAGS[@]}" "${INCLUDES[@]}" -c "$MODULE_DIR/gcc_setup.s" -o "$BUILD_DIR/gcc_setup.o"
    "$CC" "${ASFLAGS[@]}" "${INCLUDES[@]}" -c "$MODULE_DIR/txm_module_preamble.S" -o "$BUILD_DIR/txm_module_preamble.o"

    echo "Linking module ELF..."
    "$CC" -nostdlib -Wl,--gc-sections -Wl,-Map,"$BUILD_DIR/speed_sensor_module.map" \
        -T"$MODULE_DIR/speed_sensor_module.ld" \
        -o "$BUILD_DIR/speed_sensor_module.elf" \
        "$BUILD_DIR"/*.o

    "$NM" "$BUILD_DIR/speed_sensor_module.elf" > "$BUILD_DIR/speed_sensor_module.nm"
    "$OBJCOPY" -O binary "$BUILD_DIR/speed_sensor_module.elf" "$BUILD_DIR/speed_sensor_module.bin"

    echo "Generating C image..."
    python3 - <<'PY' "$BUILD_DIR/speed_sensor_module.bin" "$OUT_C"
import pathlib
import sys

bin_path = pathlib.Path(sys.argv[1])
out_path = pathlib.Path(sys.argv[2])
raw = bin_path.read_bytes()

lines = []
lines.append('#include "speed_sensor_module_image.h"')
lines.append('')
lines.append('__attribute__((aligned(32)))')
lines.append('const UCHAR g_speed_sensor_module_image[] = {')
for i, b in enumerate(raw):
    if i % 12 == 0:
        lines.append('    ')
    lines[-1] += f'0x{b:02X}u,'
lines.append('};')
lines.append('')
lines.append(f'const ULONG g_speed_sensor_module_image_size = {len(raw)}u;')
out_path.write_text('\n'.join(lines) + '\n', encoding='ascii')
PY

    MODULE_SIZE=$(stat -f%z "$BUILD_DIR/speed_sensor_module.bin" 2>/dev/null || stat -c%s "$BUILD_DIR/speed_sensor_module.bin")
    echo "✓ Module built successfully: $MODULE_SIZE bytes"
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
# Clean build artifacts
# ==============================================================================
function clean() {
    echo "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR"/*
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
  build   - Compile speed sensor module and main firmware
  flash   - Flash existing firmware to STM32
  deploy  - Build then flash to STM32
  clean   - Remove all build artifacts

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
