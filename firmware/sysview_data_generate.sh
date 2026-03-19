#!/bin/bash
# dump_sysview.sh — Dump SystemView post-mortem data from STM32 via OpenOCD

set -euo pipefail

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
OUTFILE="${1:-sysview_${TIMESTAMP}.SVDat}"
MAP_FILE="Debug/firmware.map"
FIRMWARE_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$FIRMWARE_DIR"

# Get RTT control block address from map file
# Example: find line with _SEGGER_RTT and take the hex address
RTT_ADDR=$(awk '/_SEGGER_RTT$/ {print $1}' "$MAP_FILE" | tail -n1)
if [[ -z "$RTT_ADDR" ]]; then
    echo "ERROR: Cannot find _SEGGER_RTT symbol in $MAP_FILE"
    exit 1
fi
echo "RTT control block: $RTT_ADDR"

# Create OpenOCD dump script
cat > /tmp/ocd_dump.cfg << OCDEOF
source [find interface/stlink.cfg]
source [find target/stm32u5x.cfg]

adapter speed 4000
init
halt

# Set RTT base address
set RTT_BASE "$RTT_ADDR"
set SYSVIEW_BUF_DESC [expr {\$RTT_BASE + 0x30}]

# Read buffer descriptor for up-channel 1 (SysView)
set buf_ptr   [mrw [expr {\$SYSVIEW_BUF_DESC + 4}]]
set buf_size  [mrw [expr {\$SYSVIEW_BUF_DESC + 8}]]
set wr_off    [mrw [expr {\$SYSVIEW_BUF_DESC + 12}]]
set rd_off    [mrw [expr {\$SYSVIEW_BUF_DESC + 16}]]

echo "SysView buffer: ptr=\$buf_ptr size=\$buf_size WrOff=\$wr_off RdOff=\$rd_off"

if {\$buf_size > 0 && \$wr_off >= 0} {
    if {\$wr_off >= \$rd_off} {
        set dump_size [expr {\$wr_off - \$rd_off}]
        set dump_start [expr {\$buf_ptr + \$rd_off}]
    } else {
        # Wrapped buffer, dump entire buffer
        set dump_size \$buf_size
        set dump_start \$buf_ptr
    }
    echo "Dumping \$dump_size bytes from 0x[format %08x \$dump_start]"
    dump_image "$OUTFILE" \$dump_start \$dump_size
    echo "Saved to $OUTFILE"
} else {
    echo "ERROR: No data in SysView buffer (WrOff=\$wr_off)"
}

resume
shutdown
OCDEOF

echo "Connecting to target and dumping SystemView data..."
openocd -f /tmp/ocd_dump.cfg 2>&1

if [[ -f "$OUTFILE" ]]; then
    SIZE=$(stat -c%s "$OUTFILE")
    echo ""
    echo "=== Capture complete ==="
    echo "File: $OUTFILE ($SIZE bytes)"
    echo "Open in SystemView: File → Open → select $OUTFILE"
else
    echo ""
    echo "ERROR: No output file created"
    exit 1
fi