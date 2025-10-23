#!/bin/bash

# SEA:ME Piracer HMI Dashboard Rebuild Script
# Clean, build, and run

set -e

# Colors
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         Rebuild Everything            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Clean
./clean.sh

echo ""

# Build
./build.sh

echo ""

# Ask if user wants to run
read -p "Run application now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./run.sh
fi
