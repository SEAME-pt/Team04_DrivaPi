#!/bin/bash

IMAGE_NAME="drivapi-hailo"

echo "[*] Building environment (x86_64 emulation)..."
docker build --platform linux/amd64 -t $IMAGE_NAME .

echo "[*] Running compilation pipeline..."

docker run --platform linux/amd64 -it --rm \
    -v $(pwd):/workspace \
    $IMAGE_NAME \
    python3 inference/compile.py --run "$@"
