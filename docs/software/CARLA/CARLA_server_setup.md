# 🚗 CARLA Simulator — Ubuntu Setup Guide

CARLA (Car Learning to Act) is an open-source autonomous driving simulator built on Unreal Engine 4. This guide covers installation and setup on Ubuntu.

---
### Step 1 — Install System Dependencies

```bash
sudo apt-get update
sudo apt-get install -y \
    wget \
    python3 \
    python3-venv \
    python3-pip \
    libvulkan1 vulkan-utils
```

### Step 2 — Download CARLA

Go to the [CARLA GitHub Releases page](https://github.com/carla-simulator/carla/releases) and grab the latest `.tar.gz` package, or use `wget` directly:

```bash
# Replace 0.9.16 with the version you want
wget https://carla-releases.b-cdn.net/Linux/CARLA_0.9.16.tar.gz
mkdir -p ~/CARLA
tar -xzf CARLA_0.9.16.tar.gz -C ~/CARLA
cd ~/CARLA
```


### Step 3 - Setup virtual environment

```bash
python3 -m venv .venv
# Don't forget to do the following on new terminals
source .venv/bin/activate
```

### Step 4 — Install Python API

```bash
pip install carla==0.9.16
```

> 💡 The pip package version must match your downloaded simulator version exactly.

Also install optional dependencies used by the example scripts:

```bash
cd PythonAPI/examples
pip3 install -r requirements.txt
```

### Step 5 — Launch the Simulator

```bash
cd ~/CARLA
./CarlaUE4.sh
```

You should see the CARLA simulation window open with a default town loaded.

### Step 6 — Run a Test Script

Open a **new terminal** and try one of the bundled examples:

```bash
cd ~/CARLA

source .venv/bin/activate

cd PythonAPI/examples

# Take manual control of a vehicle
python3 manual_control.py
```

---

## Useful Launch Flags

| Flag | Description |
|------|-------------|
| `-windowed -ResX=1280 -ResY=720` | Run in a smaller window |
| `-quality-level=Low` | Low graphics quality (better performance) |
| `-carla-rpc-port=2000` | Set the RPC port (default: 2000) |
| `-RenderOffScreen` | Headless mode — no display required |

Example:
```bash
./CarlaUE4.sh -windowed -ResX=1280 -ResY=720 -quality-level=Low
```

For headless server use:
```bash
./CarlaUE4.sh -RenderOffScreen
```

---

## Common Issues & Fixes

**Simulator crashes on launch (low VRAM)**
```bash
./CarlaUE4.sh -quality-level=Low
```

**"NVIDIA driver not found" or black screen**
Verify your GPU driver is installed and active:
```bash
nvidia-smi
# If missing, install via:
sudo ubuntu-drivers autoinstall
sudo reboot
```

**Connection refused on port 2000**
The simulator takes time to fully load. Add a delay in your script or increase the client timeout:
```python
client.set_timeout(30.0)
```

---

## Helpful Resources

- 📖 [Official CARLA Documentation](https://carla.readthedocs.io/)
- 💾 [GitHub Repository](https://github.com/carla-simulator/carla)
- 🗺️ [Python API Reference](https://carla.readthedocs.io/en/latest/python_api/)
- 💬 [CARLA Community Forum](https://github.com/carla-simulator/carla/discussions)

---
