#!/bin/bash
set -e

# ==== CONFIG ====
ELF="Threadx.elf"
BIN="Threadx.bin"
FLASH_ADDR="0x08000000"
BUILD_CMD="make all"        # <-- always run make all
# =================

function build() {
    echo "===== Building (make all) ====="
    $BUILD_CMD
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
    st-flash write "$BIN" "$FLASH_ADDR"
    echo "Flash complete!"
}

function usage() {
    echo "Usage: $0 {build|flash|deploy}"
    echo ""
    echo "  build   - run 'make all' and generate BIN"
    echo "  flash   - flash existing BIN"
    echo "  deploy  - build then flash"
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
    *)
        usage
        exit 1
        ;;
esac
