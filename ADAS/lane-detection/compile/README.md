# Hailo AI Docker Compilation

Build and optimize lane detection models with the Hailo AI Software Suite Docker container with NVIDIA GPU acceleration.

## Overview

This module provides Docker-based tools for compiling and optimizing trained YOLO lane detection models using Hailo's dataflow compiler with GPU acceleration.

### What This Module Does

- **Model Compilation**: Convert trained YOLO models to Hailo-optimized format
- **GPU Acceleration**: Hardware-accelerated compilation and quantization
- **Dataflow Compiler**: Hailo's DFC for model optimization and deployment
- **Seamless GPU Integration**: Automatic NVIDIA GPU detection and runtime setup

## Quick Start

### 1. Setup (First Time Only)

Install Docker, NVIDIA runtime, and download the Hailo container:

```bash
# See complete installation instructions
# INSTALL.md covers all setup steps
```

See [install.md](install.md) for detailed setup.

### 2. Compile Your Model

```bash
# See complete compilation workflow
# compile.md walks through the entire process
```

See [compile.md](compile.md) for step-by-step compilation guide.

## Key Features

- **GPU-Accelerated Compilation**: Faster model optimization with NVIDIA GPU
- **Automatic Hardware Detection**: Scripts detect and configure GPU support automatically
- **Shared Directory Workflow**: Easy file transfer between host and container
- **System Validation**: Automatic requirement checking before execution

## Documentation

- **[install.md](install.md)** - Complete installation and setup guide
  - Docker installation
  - NVIDIA Docker runtime setup
  - Hailo container download and build
  - Troubleshooting setup issues

- **[compile.md](compile.md)** - Model compilation workflow
  - Training integration
  - Model preparation
  - Compilation process
  - Optimization techniques
  - Deployment integration

## Directory Structure

```
compile/
├── README.md          # This overview
├── install.md         # Detailed installation guide
├── compile.md         # Detailed compilation guide
```

## Workflow Overview

1. **Train** → See [../train/README.md](../train/README.md)
2. **Install** → See [install.md](install.md)
3. **Compile** → See [compile.md](compile.md)
4. **Deploy** → Follow your target hardware deployment guide

## Next Steps

- **First time?** Start with [install.md](install.md)
- **Ready to compile?** Follow [compile.md](compile.md)
- **Need help?** Check [install.md - Troubleshooting](install.md#troubleshooting)

## Resources

- [Hailo AI Documentation](https://hailo.ai/)
- [NVIDIA Docker](https://github.com/NVIDIA/nvidia-docker)
- [Lane Detection Training](../train/README.md)
