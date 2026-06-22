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

## NVIDIA Docker Runtime Installation

To enable GPU support in Docker containers, install the NVIDIA Container Toolkit:

```bash
# 1. Add NVIDIA's GPG key and repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

# 2. Install it
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

# 3. Configure Docker to use it
sudo nvidia-ctk runtime configure --runtime=docker

# 4. Restart Docker
sudo systemctl restart docker
```

#### Verify Installation

After installation, verify nvidia-docker is installed:

```bash
# Check if nvidia-docker is available
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi
```

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


### GPU Not Detected in Container

**Problem**: `nvidia-smi` shows no GPU inside container

**Solution**:
```bash
# Check host GPU
nvidia-smi

# Check nvidia-docker installation
docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi

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
