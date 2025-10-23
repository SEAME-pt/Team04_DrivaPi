#!/bin/bash

cd "$(dirname "$0")/../.."

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Try multiple possible binary locations
BINARY=""

# macOS .app bundle
if [ -f "build/bin/SEA_ME_HMI_Dashboard.app/Contents/MacOS/SEA_ME_HMI_Dashboard" ]; then
    BINARY="build/bin/SEA_ME_HMI_Dashboard.app/Contents/MacOS/SEA_ME_HMI_Dashboard"
# Linux binary
elif [ -f "build/bin/SEA_ME_HMI_Dashboard" ]; then
    BINARY="build/bin/SEA_ME_HMI_Dashboard"
# Search in build directory
else
    BINARY=$(find build -name "SEA_ME_HMI_Dashboard" -type f -perm +111 2>/dev/null | grep -v "\.dSYM" | head -1)
fi

if [ -z "$BINARY" ]; then
    echo -e "${RED}❌ Binary not found. Build first:${NC}"
    echo "   ./scripts/build/build.sh"
    exit 1
fi

echo -e "${CYAN}🚀 Running SEA:ME HMI Dashboard...${NC}"
echo -e "${GREEN}   Binary: $BINARY${NC}"
echo ""

# Run the application
"$BINARY" "$@"
