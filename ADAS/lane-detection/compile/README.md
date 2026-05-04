# Hailo AI Docker Setup & GPU Support

This guide covers setting up and running the Hailo AI Software Suite Docker container with NVIDIA GPU acceleration for model compilation and optimization.

## Prerequisites

### System Requirements

- **CPU**: x86_64 architecture with AVX support
- **RAM**: Minimum 16 GB (recommended 32 GB)
- **Disk Space**: 50+ GB free
- **OS**: Ubuntu 22.04 / 24.04 (or compatible Linux distribution)

### GPU Requirements (for GPU acceleration)

- **NVIDIA GPU**: With CUDA compute capability 3.5 or higher
- **NVIDIA Driver**: Version 525 or higher
- **CUDA**: 11.8 or higher (optional, but recommended)
- **nvidia-docker**: Container toolkit for GPU support

## Installation

### 1. Verify System Requirements

Run the system check script:

```bash
cd ADAS/lane-detection/scripts
bash hailo_ai_sw_suite_docker_run.sh --help
```

This will verify your system meets the Hailo Dataflow Compiler requirements.

### 2. Install Docker

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

### 3. Install NVIDIA Docker Runtime (GPU Support)

Required for GPU acceleration in containers. The NVIDIA Container Toolkit provides the necessary runtime support.

#### Option A: Automated Installation (Recommended)

```bash
# Ubuntu 22.04 / 24.04
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt update
sudo apt install -y nvidia-docker2
sudo systemctl restart docker
```

#### Option B: Manual Installation via Package Manager

```bash
# Add NVIDIA repository
sudo curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# Install
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker
```

#### Option C: Installation from Source

```bash
# Clone the repository
git clone https://github.com/NVIDIA/nvidia-docker.git
cd nvidia-docker

# Install dependencies
sudo apt install -y build-essential

# Build and install
make ubuntu
sudo make install
```

#### Verify Installation

After installation, verify nvidia-docker is working:

```bash
# Check nvidia-docker version
nvidia-docker version

# Test GPU access in container
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

Expected output: GPU information and CUDA version from nvidia-smi

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

Verify the setup:

```bash
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### 4. Download Hailo Docker Image

1. Visit [Hailo Developer Portal](https://hailo.ai/developer-zone/)
2. Sign in to your account
3. Navigate to the Docker images section
4. Copy the download link for `hailo8_ai_sw_suite_docker_2025-10.tar.gz`

#### Verify Download

After downloading, verify the file:

```bash
# Check file exists and size
ls -lh hailo8_ai_sw_suite_*_docker.zip

# Extract and verify contents
unzip hailo8_ai_sw_suite_*_docker.zip
ls -lh hailo8_ai_sw_suite_*_docker/
```

## Building the Docker Image

### Extract and Build

```bash
cd hailo8_ai_sw_suite_*_docker
bash build_hailo_docker.sh
```

This script is designed by Hailo. If you have any issues, please read their documentation or contact their support.

Verify the image was loaded:

```bash
docker images | grep hailo
# Expected: hailo8_ai_sw_suite_2025-10:1
```

## Running the Container with GPU

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
dataflow-compiler --version
```

## Shared Directory

Transfer files between host and container via:

```
lane-detection/scripts/shared_with_docker/
```

Mount path inside container:

```
/local/shared_with_docker/
```

### Example: Copy Model to Container

```bash
# Host: Copy model to shared directory
cp path/to/model.pt path_to_shared/shared_with_docker/

# Inside container

ls /local/shared_with_docker/

```

## GPU Acceleration Details

### What Gets GPU-Accelerated

- **Model Compilation**: DFC (Dataflow Compiler) uses GPU for faster compilation
- **Quantization**: GPU-accelerated quantization process
- **Inference Testing**: Inference operations can run on GPU

Monitor GPU usage inside container:

```bash
# Real-time GPU monitoring
watch -n 1 nvidia-smi
```

## Troubleshooting

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

### Permission Denied

**Problem**: Docker permission errors without sudo

**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker ps
```

## Checking System Requirements

The run script performs automatic checks:

```bash
bash hailo_ai_sw_suite_docker_run.sh
```

This generates:
- `system_reqs_table.log`: Summary of requirements
- `system_reqs_results.log`: Detailed results

View results:

```bash
cat system_reqs_table.log
cat system_reqs_results.log
```

### Manual Requirement Checks

```bash
# RAM check
free -h

# GPU driver version
nvidia-smi -q | grep "Driver Version"

# CPU architecture
lscpu | grep Architecture

# AVX support
lscpu | grep avx
```

## Integration with Training Pipeline

After model training in `lane-detection/scripts/train/`:

1. **Copy trained model to shared directory**:
   ```bash
   cp runs/train/*/weights/best.pt shared_with_docker/
   ```

2. **Start Hailo container**:
   ```bash
   bash hailo_ai_sw_suite_docker_run.sh
   ```

3. **Inside container, compile model**:
   ```bash
   cp /local/shared_with_docker/best.pt /workspace/
   # Run Hailo compilation/optimization
   ```

## References

- [Hailo AI Documentation](https://hailo.ai/)
- [NVIDIA Docker Documentation](https://github.com/NVIDIA/nvidia-docker)
- [Hailo Developer Portal](https://hailo.ai/developer-zone/)

## Next Steps

1. Verify GPU access with `nvidia-smi` inside container
2. Follow the model compilation pipeline in the main lane-detection README
3. Monitor GPU usage with `watch nvidia-smi` during compilation

## Support

For issues with:
- **Hailo Software**: Contact Hailo support via developer portal
- **NVIDIA Docker**: Check [NVIDIA Docker issues](https://github.com/NVIDIA/nvidia-docker/issues)
- **System Setup**: Review system requirements logs (system_reqs_*.log)
