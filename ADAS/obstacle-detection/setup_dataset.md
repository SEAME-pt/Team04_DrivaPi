# Obstacle Detection - Setup Guide

This guide covers how to prepare the data and the environment for training and inference.

## 1. Environment Setup (Local Machine)

Before running the scripts, create a virtual environment to manage dependencies:

```bash
# Create venv
python3 -m venv venv

# Activate venv
# On macOS/Linux:
source venv/bin/activate
# On Windows:
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

```

## 2. Dataset Download

Run the following command from the `obstacle-detection/` directory:

```bash
curl -L "https://app.roboflow.com/ds/grk91iJX3K?key=Nioy375aY6" > roboflow.zip
unzip roboflow.zip -d ./dataset/
rm roboflow.zip

```

---

## 3. Workflow Summary

| Task | Platform | Tools |
| --- | --- | --- |
| **Training** | PC / macOS | Python venv + Ultralytics |
| **Export to ONNX** | PC / macOS | `python3 train/main.py --export` |
| **Hailo Compilation** | **Linux / Docker** | `python3 inference/compile.py --run` |
