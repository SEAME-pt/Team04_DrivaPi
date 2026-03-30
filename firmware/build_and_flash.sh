#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRMWARE_ROOT_DIR="$SCRIPT_DIR"
DEBUG_DIR="$FIRMWARE_ROOT_DIR/Debug"

# ==== CONFIG ====
ELF="$DEBUG_DIR/firmware.elf"
BIN="$DEBUG_DIR/firmware.bin"
FLASH_ADDR="0x08000000"
BUILD_CMD=(make -C "$DEBUG_DIR" all)
CLEAN_CMD=(make -C "$DEBUG_DIR" clean)
# =================

function build() {
    echo "===== Building (make all) ====="
    "${BUILD_CMD[@]}"
    echo ""
    echo "===== Converting ELF to BIN ====="
    if [ ! -f "$ELF" ]; then
        echo "Error: $ELF not found after build!"
        exit 1
    fi
    arm-none-eabi-objcopy -O binary "$ELF" "$BIN"
    echo "Binary ready: $BIN"
}

function flash() {
    if [ ! -f "$BIN" ]; then
        echo "Error: $BIN not found. Build first!"
        exit 1
    fi

    echo "===== Flashing $BIN ====="
    if ! st-flash write "$BIN" "$FLASH_ADDR"; then
        echo "Flash failed. Trying reset workaround and one retry..."
        # Some STM32U5 sessions recover after a forced reset/read cycle.
        st-flash --reset read /tmp/stlink_reset_probe.bin "$FLASH_ADDR" 16 >/dev/null 2>&1 || true
        st-flash --reset write "$BIN" "$FLASH_ADDR"
    fi
    echo "Flash complete!"
}

function clean() {
    echo "===== Cleaning (make clean) ====="
    "${CLEAN_CMD[@]}"
    rm -f "$BIN"
    echo "Clean complete!"
}

function usage() {
    echo "Usage: $0 {build|flash|deploy|clean}"
    echo ""
    echo "  build   - run 'make all' and generate BIN"
    echo "  flash   - flash existing BIN"
    echo "  deploy  - build then flash"
    echo "  clean   - run 'make clean' and remove BIN"
}

case "$1" in
    build)
        build
        ;;
    flash)
        flash
        ;;
    deploy)
        build
        flash
        ;;
    clean)
        clean
        ;;
    *)
        usage
        exit 1
        ;;
esac
