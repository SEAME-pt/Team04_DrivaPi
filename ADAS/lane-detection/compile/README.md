# Hailo AI Docker Compilation

Build and optimize lane detection models with the Hailo AI Software Suite Docker container with NVIDIA GPU acceleration.

## Overview

This module provides Docker-based tools for:

- **Model Compilation**: Convert trained YOLO models to Hailo-optimized format
- **GPU Acceleration**: Hardware-accelerated compilation and quantization
- **Dataflow Compiler**: Hailo's DFC for model optimization and deployment
- **Seamless GPU Integration**: Automatic NVIDIA GPU detection and runtime setup

## Quick Start

First-time setup: See [INSTALL.md](INSTALL.md)

After installation, run the container:

```bash
cd hailo8_ai_sw_suite_*_docker
bash hailo_ai_sw_suite_docker_run.sh
```

## Key Features

- **GPU-Accelerated Compilation**: Faster model optimization with NVIDIA GPU
- **Automatic Hardware Detection**: Scripts detect and configure GPU support
- **Shared Directory Workflow**: Transfer models between host and container
- **System Validation**: Automatic requirement checking before execution

## Directory Structure

```
compile/
├── README.md          # This overview
├── INSTALL.md         # Detailed installation guide
```

## Workflow

### 1. Train Model (Lane Detection)

```bash
cd ADAS/lane-detection/scripts/train
python main.py --config training_config.yaml
```

### 2. Prepare for Compilation

```bash
# Copy trained model to shared directory
cp ADAS/lane-detection/scripts/train/runs/train/*/weights/best.pt \
   hailo8_ai_sw_suite_*_docker/shared_with_docker/
```

### 3. Run Compilation in Hailo Container

```bash
cd hailo8_ai_sw_suite_*_docker
bash hailo_ai_sw_suite_docker_run.sh

# Inside container:
cd /local/shared_with_docker
# Run Hailo compilation tools
dataflow-compiler --help
```

## Next Steps

- **Setup**: See [INSTALL.md](INSTALL.md) for complete installation
- **Hailo Documentation**: [Hailo AI](https://hailo.ai/)
- **NVIDIA Docker**: [NVIDIA Docker Docs](https://github.com/NVIDIA/nvidia-docker)
- **Issues**: Check [INSTALL.md - Troubleshooting](INSTALL.md#troubleshooting)
