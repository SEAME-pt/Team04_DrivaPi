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
curl -L "https://app.roboflow.com/ds/fjnKtOu4i0?key=5MIpxJb4Mi" > roboflow.zip
unzip roboflow.zip -d ./dataset/
rm roboflow.zip

```
# IMPORTANT: Fix data.yaml paths
# Roboflow exports often use absolute or incorrect relative paths.
# Ensure 'dataset/data.yaml' has:
# path: ../dataset
# train: train/images
# val: train/images (if no 'valid' folder exists)

---

## 3. Workflow Summary

| Task | Platform | Tools |
| --- | --- | --- |
| **Training** | PC / macOS | Python venv + Ultralytics |
| **Export to ONNX** | PC / macOS | `python3 train/main.py --export` |
| **Hailo Compilation** | **Linux / Docker** | `python3 inference/compile.py --run` |
