# Installation Guide: Hailo AI Docker with GPU Support

Complete installation instructions for setting up the Hailo AI Software Suite Docker container with NVIDIA GPU acceleration.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [System Requirements Verification](#system-requirements-verification)
3. [Docker Installation](#docker-installation)
4. [NVIDIA Docker Runtime](#nvidia-docker-runtime)
5. [Download Hailo Docker Image](#download-hailo-docker-image)
6. [Build Docker Image](#build-docker-image)
7. [Running the Container](#running-the-container)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### GPU Requirements (for GPU acceleration)

- **NVIDIA GPU**: With CUDA compute capability 3.5 or higher
- **NVIDIA Driver**: Version 525 or higher
- **CUDA**: 11.8 or higher (optional, but recommended)
- **nvidia-docker**: Container toolkit for GPU support


## Docker Installation

### Install Docker

If not already installed:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y docker.io

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER
newgrp docker
```

Verify Docker installation:

```bash
docker --version
```

## NVIDIA Docker Runtime

#### Installation from Source

For advanced users or custom builds:

```bash
# Clone the repository
git clone https://github.com/NVIDIA/nvidia-container-toolkit.git
cd nvidia-container-toolkit

# Install dependencies
sudo apt install -y build-essential

# Build and install
make ubuntu
sudo make install
```

#### Verify Installation

After installation, verify nvidia-docker is installed:

```bash
# Check nvidia-docker version
nvidia-docker version
```

#### Post-Installation Setup

Ensure Docker daemon can access the NVIDIA runtime:

```bash
# Check if daemon.json exists
cat /etc/docker/daemon.json

# If not configured, add NVIDIA runtime:
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF

# Reload and restart Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

#### Verify GPU Access

After daemon setup, verify GPU access works:

```bash
# Test GPU access in container
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

Expected output: GPU information and CUDA version from nvidia-smi

## Download Hailo Docker Image

1. Visit [Hailo Developer Portal](https://hailo.ai/developer-zone/)
2. Sign in to your account
3. Navigate to the Docker images section
4. Download `hailo8_ai_sw_suite_*_docker.zip`

### 2. Verify Download

After downloading, verify the file:

```bash
# Check file exists and size
ls -lh hailo8_ai_sw_suite_*_docker.zip

# Extract and verify contents
unzip hailo8_ai_sw_suite_*_docker.zip
ls -lh hailo8_ai_sw_suite_*_docker/
```

## Running the Container

### Basic Usage

Start the Hailo container with GPU support from the extracted directory:

```bash
cd hailo8_ai_sw_suite_*_docker
bash hailo_ai_sw_suite_docker_run.sh
```

The script automatically:
- Detects NVIDIA GPU and driver version
- Enables GPU support with `--gpus all`
- Mounts shared directories
- Verifies system requirements

### Container Options

```bash
# Resume existing container
bash hailo_ai_sw_suite_docker_run.sh --resume

# Override and create new container
bash hailo_ai_sw_suite_docker_run.sh --override

# Enable HailoRT service
bash hailo_ai_sw_suite_docker_run.sh --hailort-enable-service

# Enable monitoring
bash hailo_ai_sw_suite_docker_run.sh --hailort-enable-service --service-enable-monitor
```

### Verify GPU Access Inside Container

Once inside the container:

```bash
# Check GPU availability
nvidia-smi

# Check Hailo tools
hailo --version
```

## Troubleshooting

### nvidia-docker: command not found

**Problem**: `nvidia-docker: command not found` when running nvidia-docker version

**Solution**:

The NVIDIA Container Toolkit may not be properly installed or not in your PATH. Try the following steps:

1. **Check if nvidia-container-toolkit is installed**:
   ```bash
   which nvidia-container-runtime
   dpkg -l | grep nvidia-container-toolkit
   ```

2. **If not installed, install it**:
   ```bash
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
     sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   
   sudo apt update
   sudo apt install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

3. **Update PATH and refresh environment**:
   ```bash
   /usr/bin/nvidia-container-runtime --version

   # If found just add the path to your environment
   export PATH="/usr/bin:$PATH"
   nvidia-smi  # Verify GPU is accessible
   ```

4. **Use docker with NVIDIA runtime instead**:
   If nvidia-docker command is still not found, use docker directly with NVIDIA runtime:
   ```bash
   docker run --rm --runtime=nvidia --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
   ```

5. **Verify daemon.json configuration**:
   ```bash
   cat /etc/docker/daemon.json
   # Should contain nvidia runtime configuration
   ```

6. **Rebuild the connection to Docker daemon**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   
   # Test again
   docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
   ```

### GPU Not Detected in Container

**Problem**: `nvidia-smi` shows no GPU inside container

**Solution**:
```bash
# Check host GPU
nvidia-smi

# Check nvidia-docker installation
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi

# Restart Docker daemon
sudo systemctl restart docker
```


### Docker Image Not Found

**Problem**: `Error response from daemon: image not found`

**Solution**:
```bash
# Rebuild image from extracted directory
cd hailo8_ai_sw_suite_*_docker
bash hailo_ai_sw_suite_docker_run.sh --override

# Verify
docker images | grep hailo
```

## References

- [Hailo AI Documentation](https://hailo.ai/)
- [NVIDIA Docker Documentation](https://github.com/NVIDIA/nvidia-docker)
- [Hailo Developer Portal](https://hailo.ai/developer-zone/)

## Support

For issues with:
- **Hailo Software**: Contact Hailo support via developer portal
- **NVIDIA Docker**: Check [NVIDIA Docker issues](https://github.com/NVIDIA/nvidia-docker/issues)
- **System Setup**: Review system requirements logs (system_reqs_*.log)
