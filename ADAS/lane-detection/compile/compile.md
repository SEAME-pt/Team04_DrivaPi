# Model Compilation Guide

Complete workflow for compiling trained YOLO lane detection models using the Hailo AI Software Suite.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Workflow](#workflow)
4. [Compilation Process](#compilation-process)
5. [Optimization Techniques](#optimization-techniques)
6. [Troubleshooting](#troubleshooting)

## Overview

The compilation process converts PyTorch-trained YOLO11 models into Hailo-optimized formats suitable for deployment on edge devices.

### Process Steps

1. **Model Preparation**: Export trained YOLO model
2. **Docker Setup**: Ensure Hailo container is running with GPU support
3. **Transfer Model**: Move model to shared directory
4. **Compilation**: Run Hailo's dataflow compiler
5. **Optimization**: Apply quantization and hardware-specific optimizations
6. **Deployment**: Output optimized model for target hardware

## Prerequisites

- Trained YOLO11 model (`.pt` file)
- Hailo Docker container running (see [install.md](install.md))
- GPU access inside container (verify with `nvidia-smi`)

## Workflow

### Step 1: Train Model

Train your lane detection model using the training pipeline:

```bash
cd ../train
# See README.md for complete training instructions
python main.py --config training_config.yaml
```

Your trained model will be saved in `runs/train/*/weights/best.pt`

### Step 2: Locate Trained Model

Find your best model checkpoint:

```bash
ls -lh ../train/runs/train/*/weights/best.pt
```

### Step 3: Prepare Hailo Container

Extract and start the Hailo Docker container:

```bash
cd hailo8_ai_sw_suite_*_docker
bash hailo_ai_sw_suite_docker_run.sh
```

For detailed installation and container setup, see [install.md](install.md).

### Step 4: Translate and transfer Model to Container

Copy the trained model to the shared directory accessible from the container:

```bash
# Translate from PyTorch to ONNX
yolo export model=/path/to/your/model/best.pt format=onnx

# Copy from custom location
cp /path/to/your/model/best.onnx ./shared_with_docker/
```

### Step 5: Run Compilation Inside Container

Inside the running Hailo container:

```bash
cd /local/shared_with_docker

# List available models
ls -lh best.onnx

# Verify Hailo tools are available
dataflow-compiler --version
```

### Step 6: Compile Model

The actual compilation depends on your specific Hailo workflow. Example:

```bash
# Convert PyTorch to ONNX
```

For detailed compilation options, consult Hailo documentation:

```bash
dataflow-compiler --help
hailoc --help
```

## Compilation Process

### Basic Compilation

```bash
# Compile ONNX model to .har format
hailo parser onnx best.onnx

# Optimize with calibration data
hailo optimize best.har --calib-set-path calibration_images.npy

# Compile to .hef format for deployment
hailo optimize best_optimized.har --calib-set-path calibration_images.npy

```

### Performance Monitoring

Monitor GPU usage during compilation:

```bash
# In separate terminal on host
watch -n 1 nvidia-smi

# Or inside container
watch -n 1 nvidia-smi
```

## Output Files

After successful compilation, check the shared directory:

```bash
ls -lh ./shared_with_docker/

# Should contain:
# - best_compiled.hef (compiled model)
# - *.log (compilation logs)
```

Copy results back to host:

```bash
cp ./shared_with_docker/best_compiled.hef /path/for/deployment/
```

## Troubleshooting

### GPU Not Detected

**Problem**: `NVIDIA GPU not found`

**Solution**:
- Ensure nvidia-docker is installed on host
- Verify GPU with `nvidia-smi` on host
- Check container was started with GPU support: `docker run --gpus all ...`

## Integration with Deployment

After compilation, the `.hef` file is ready for deployment:

```bash
# Copy to deployment directory
scp best_compiled.hef root@target_device:/path/to/deployment/

# Follow edge deployment guide for your target hardware
# (e.g., Hailo8, AGX, etc.)
```

## References

- [Hailo AI Documentation](https://hailo.ai/)
- [Hailo Dataflow Compiler](https://hailo.ai/products/)
- [Training Guide](../train/README.md)
- [Installation Guide](install.md)
