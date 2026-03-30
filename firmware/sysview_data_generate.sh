#!/bin/bash
# dump_sysview.sh - Dump SystemView post-mortem data from STM32 via OpenOCD

set -euo pipefail

TIMESTAMP_UTC="$(date -u +%Y%m%dT%H%M%SZ)"
TIMESTAMP_EPOCH_MS="$(date +%s%3N)"
TIMESTAMP="${TIMESTAMP_EPOCH_MS}_${TIMESTAMP_UTC}"
OUTFILE="${1:-sysview_${TIMESTAMP}.SVDat}"
CAPTURE_MS="${2:-5000}"
RESET_TARGET="${3:-0}"
MAP_FILE="Debug/firmware.map"
FIRMWARE_DIR="$(cd "$(dirname "$0")" && pwd)"
OPENOCD_CFG="/tmp/ocd_dump_${TIMESTAMP}.cfg"
PART1_FILE="/tmp/sysview_part1_${TIMESTAMP}.bin"
PART2_FILE="/tmp/sysview_part2_${TIMESTAMP}.bin"

cd "$FIRMWARE_DIR"

# Avoid reusing stale files from previous runs.
rm -f "$OUTFILE" "$PART1_FILE" "$PART2_FILE" "$OPENOCD_CFG"

if [[ ! -f "$MAP_FILE" ]]; then
    echo "ERROR: Map file not found: $MAP_FILE"
    echo "Build first so Debug/firmware.map exists."
    exit 1
fi

# Get RTT control block address from map file.
RTT_ADDR=$(awk '/_SEGGER_RTT$/ {print $1}' "$MAP_FILE" | tail -n1)
if [[ -z "$RTT_ADDR" ]]; then
    echo "ERROR: Cannot find _SEGGER_RTT symbol in $MAP_FILE"
    exit 1
fi

echo "RTT control block: $RTT_ADDR"
echo "Recording timestamp: $TIMESTAMP"
echo "Capture duration: ${CAPTURE_MS} ms"
echo "Reset before capture: ${RESET_TARGET}"

# Create OpenOCD dump script.
cat > "$OPENOCD_CFG" << OCDEOF
source [find interface/stlink.cfg]
source [find target/stm32u5x.cfg]

adapter speed 4000
init

if {$RESET_TARGET == 1} {
    reset halt
    sleep 50
    resume
} else {
    # Make state deterministic before resuming capture window.
    catch {halt}
    sleep 50
    resume
}

sleep $CAPTURE_MS

# Halt and ensure we are stopped before reading RTT memory.
if {[catch {halt} halt_err]} {
    echo "WARN: halt failed after capture window: \$halt_err"
    echo "WARN: forcing reset halt fallback"
    reset halt
}
sleep 50

# Set RTT base address.
set RTT_BASE "$RTT_ADDR"
set SYSVIEW_BUF_DESC [expr {\$RTT_BASE + 0x30}]

# Read buffer descriptor for up-channel 1 (SystemView stream).
set buf_ptr   [mrw [expr {\$SYSVIEW_BUF_DESC + 4}]]
set buf_size  [mrw [expr {\$SYSVIEW_BUF_DESC + 8}]]
set wr_off    [mrw [expr {\$SYSVIEW_BUF_DESC + 12}]]
set rd_off    [mrw [expr {\$SYSVIEW_BUF_DESC + 16}]]

echo "SysView buffer: ptr=\$buf_ptr size=\$buf_size WrOff=\$wr_off RdOff=\$rd_off"

if {\$buf_size > 0 && \$wr_off >= 0 && \$rd_off >= 0} {
    if {\$wr_off >= \$rd_off} {
        set dump_size [expr {\$wr_off - \$rd_off}]
        set dump_start [expr {\$buf_ptr + \$rd_off}]
        echo "Dumping contiguous region: size=\$dump_size from 0x[format %08x \$dump_start]"
        dump_image "$OUTFILE" \$dump_start \$dump_size
    } else {
        set part1_size [expr {\$buf_size - \$rd_off}]
        set part1_start [expr {\$buf_ptr + \$rd_off}]
        set part2_size \$wr_off

        echo "Dumping wrapped region part1: size=\$part1_size from 0x[format %08x \$part1_start]"
        dump_image "$PART1_FILE" \$part1_start \$part1_size

        if {\$part2_size > 0} {
            echo "Dumping wrapped region part2: size=\$part2_size from 0x[format %08x \$buf_ptr]"
            dump_image "$PART2_FILE" \$buf_ptr \$part2_size
        }
    }
} else {
    echo "ERROR: No data in SysView buffer (size=\$buf_size WrOff=\$wr_off RdOff=\$rd_off)"
}

# Resume target only if currently halted.
catch {resume}
shutdown
OCDEOF

echo "Connecting to target and dumping SystemView data..."
openocd -f "$OPENOCD_CFG" 2>&1

if [[ -f "$PART1_FILE" ]]; then
    if [[ -f "$PART2_FILE" ]]; then
        cat "$PART1_FILE" "$PART2_FILE" > "$OUTFILE"
    else
        cp "$PART1_FILE" "$OUTFILE"
    fi
fi

rm -f "$PART1_FILE" "$PART2_FILE" "$OPENOCD_CFG"

if [[ -f "$OUTFILE" ]]; then
    SIZE=$(stat -c%s "$OUTFILE")
    echo ""
    echo "=== Capture complete ==="
    echo "File: $OUTFILE ($SIZE bytes)"
    echo "Open in SystemView: File -> Open -> select $OUTFILE"
else
    echo ""
    echo "ERROR: No output file created"
    exit 1
fi