#!/bin/bash

echo "🚗 SEA:ME HMI Dashboard - Quick Start"
echo ""
echo "Choose an option:"
echo "  1) Build and run locally"
echo "  2) Build Docker image"
echo "  3) Clean build artifacts"
echo "  4) Run tests"
echo "  5) Generate documentation"
echo ""
read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        ./scripts/build/build.sh && ./scripts/build/run.sh
        ;;
    2)
        ./scripts/deploy/docker-build.sh
        ;;
    3)
        ./scripts/build/clean.sh
        ;;
    4)
        echo "Tests not yet implemented"
        ;;
    5)
        echo "Documentation generation not yet implemented"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
