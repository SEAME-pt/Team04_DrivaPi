#!/bin/bash
# flash_rsu.sh — usage:
#   ./flash_rsu.sh RSU1
#   ./flash_rsu.sh --clean

set -e

TEMPLATE="template.py"

declare -A HEADINGS=( [RSU1]=88 [RSU2]=240 [RSU3]=333 )

usage() {
    echo "Usage: $0 RSU1|RSU2|RSU3"
    echo "       $0 --clean"
    exit 1
}

# --- Handle --clean ---
if [[ "$1" == "--clean" ]]; then
    echo "Cleaning generated .py files..."
    for id in "${!HEADINGS[@]}"; do
        if [[ -f "${id}.py" ]]; then
            rm -v "${id}.py"
        fi
    done
    echo "✅ Clean complete."
    exit 0
fi

# --- Normal flash flow ---
ID=$1
if [[ -z "$ID" || -z "${HEADINGS[$ID]}" ]]; then
    usage
fi

HEADING="${HEADINGS[$ID]}"

sed -e "s/__MY_ID__/\"$ID\"/" \
    -e "s/__EXPECTED_HEADING__/$HEADING/" \
    "$TEMPLATE" > "${ID}.py"

echo "Generated ${ID}.py (heading $HEADING)."
read -p "Plug in the micro:bit for $ID, then press Enter to flash..."

uflash "${ID}.py"
echo "✅ Flashed $ID."