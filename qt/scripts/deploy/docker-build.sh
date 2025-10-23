#!/bin/bash

set -e

cd "$(dirname "$0")/../.."

RUNTIME=${CONTAINER_RUNTIME:-docker}
command -v $RUNTIME >/dev/null 2>&1 || RUNTIME=podman

echo "🐳 Building with $RUNTIME..."

$RUNTIME build -f docker/production/Dockerfile -t seame-hmi:latest .

echo "✅ Docker build complete!"
echo ""
echo "To run: ./scripts/deploy/docker-run.sh"
