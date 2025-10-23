#!/bin/bash

cd "$(dirname "$0")/../.."

echo "🧹 Cleaning build artifacts..."
rm -rf build/
rm -f .qmake.stash Makefile
echo "✅ Clean complete!"
