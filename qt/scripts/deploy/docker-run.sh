#!/bin/bash

set -e

RUNTIME=${CONTAINER_RUNTIME:-docker}
command -v $RUNTIME >/dev/null 2>&1 || RUNTIME=podman

echo "🚀 Running with $RUNTIME..."

$RUNTIME run --rm -it \
    -e DISPLAY=${DISPLAY} \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --network host \
    seame-hmi:latest
