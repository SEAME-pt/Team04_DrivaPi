# DrivaPi ADAS Inference Usage (Raspberry Pi)

This inference stack is intended to run on a Raspberry Pi with the Hailo SDK and `rpicam-vid` available. It captures camera frames, runs Hailo inference, streams annotated MJPEG on port **8080**, and sends UDP control commands using settings in `hailo_config.py`.

## Requirements

- Raspberry Pi with camera and `rpicam-vid`
- Hailo SDK installed (`hailo_platform` Python package)
- Python 3 with `opencv-python` and `numpy`
- Model file referenced by `HEF_PATH` in `hailo_config.py`

## Run manually

```bash
cd ADAS/obstacle-detection/inference
python3 main_inference.py
```

MJPEG stream: `http://<pi-ip>:8080/`

## Configuration

Adjust thresholds, FPS cap, and control tuning in:

```
ADAS/obstacle-detection/inference/hailo_config.py
```

Key runtime knobs:
- `TARGET_FPS`, `CONFIDENCE_THRESHOLD`, `NMS_*`
- PWM limits and stop timing parameters
- UDP target and ports

## Run as a systemd service (recommended)

1. Copy the unit file:

```bash
sudo cp ADAS/obstacle-detection/inference/systemd/drivapi-inference.service /etc/systemd/system/
```

2. Edit `DRIVAPI_ROOT` in the service file to match your install path:

```bash
sudo nano /etc/systemd/system/drivapi-inference.service
```

3. Reload, enable, and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable drivapi-inference
sudo systemctl start drivapi-inference
```

4. Check logs:

```bash
sudo journalctl -u drivapi-inference -f
```

5. Stop or disable:

```bash
sudo systemctl stop drivapi-inference
sudo systemctl disable drivapi-inference
```
