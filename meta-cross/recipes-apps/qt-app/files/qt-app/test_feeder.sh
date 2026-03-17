#!/usr/bin/env bash
# Quick test script for KUKSA CAN Feeder
set -euo pipefail

echo "========================================="
echo "KUKSA CAN Feeder - Quick Test"
echo "========================================="
echo

# 1. Check if can1 exists
if ! ip link show can1 &>/dev/null; then
    echo "[Setup] Creating can1..."
    sudo modprobe vcan
    sudo ip link add dev can1 type vcan
    sudo ip link set can1 up
    echo "[Setup] ✓ can1 created"
else
    echo "[Setup] ✓ can1 already exists"
fi

# 2. Check if KUKSA databroker is accessible
echo "[Check] Testing KUKSA databroker connection..."
if timeout 2 bash -c "echo > /dev/tcp/localhost/55555" 2>/dev/null; then
    echo "[Check] ✓ KUKSA databroker is reachable on localhost:55555"
else
    echo "[Check] ✗ KUKSA databroker not reachable on localhost:55555"
    echo "          Please start KUKSA databroker first:"
    echo "          sudo systemctl start kuksa-databroker"
    exit 1
fi

# 3. Check if can-utils is installed
if ! command -v cansend &>/dev/null; then
    echo "[Check] ✗ can-utils not installed"
    echo "          Install with: sudo apt-get install can-utils"
    exit 1
else
    echo "[Check] ✓ can-utils installed"
fi

echo
echo "========================================="
echo "Test Setup Complete!"
echo "========================================="
echo
echo "Next steps:"
echo
echo "1. Start the feeder in one terminal:"
echo "   cd build"
echo "   ./kuksa_feeder can1"
echo
echo "2. Send test CAN frames in another terminal:"
echo "   # Speed = 10.5 m/s (37.8 km/h) - 0x41280000 in LE float"
echo "   cansend can1 100#00002841"
echo
echo "   # Speed = 25.3 m/s (91.08 km/h) - 0x41CA6666 in LE float"
echo "   cansend can1 100#6666CA41"
echo
echo "3. Verify in KUKSA CLI (if installed):"
echo "   kuksa-client"
echo "   > get Vehicle.Speed"
echo
echo "4. Or run the Qt dashboard:"
echo "   ./myqtapp --kuksa"
echo
