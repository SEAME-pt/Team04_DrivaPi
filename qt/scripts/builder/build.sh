#!/bin/bash

set -e

cd "$(dirname "$0")/../.."

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Building SEA:ME HMI Dashboard...${NC}"

mkdir -p build
cd build

qmake ../seame-hmi.pro CONFIG+=release
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo "Binary location:"
find . -name "SEA_ME_HMI_Dashboard*" -type f 2>/dev/null | head -1
