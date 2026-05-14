# Obstacle Detection - Setup Guide

This guide covers environment setup, dataset preparation, and how to use `config.py`, `trainer.py`, and `main.py` for training/export.

## 1. Environment Setup (Local Machine)

From `ADAS/obstacle-detection/`:

```bash
# Create venv
python3 -m venv venv

# Activate venv (macOS/Linux)
source venv/bin/activate

# Activate venv (Windows)
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

## 2. Dataset Download

From `ADAS/obstacle-detection/`:

```bash
curl -L "https://app.roboflow.com/ds/fjnKtOu4i0?key=5MIpxJb4Mi" > roboflow.zip
unzip roboflow.zip -d ./dataset/
rm roboflow.zip
```

Update `dataset/data.yaml` if needed:

```yaml
path: ../dataset
train: train/images
val: train/images
```

> If your export includes a `valid/images` folder, set `val: valid/images`.

## 3. Training Code Structure

The training pipeline in `train/` is split into:

1. `config.py` - CLI arguments + typed `TrainConfig` (`--train`, `--export`, `--data`, `--epochs`, `--imgsz`, `--lr0`, `--batch`, `--augment`, `--patience`, `--name`, `--project`, `--best-weights`)
2. `trainer.py` - `ObstacleTrainer` class that runs training and ONNX export
3. `main.py` - entry point that reads config and executes `train()` and/or `export_onnx()`

## 4. Run Commands

From `ADAS/obstacle-detection/` with venv active:

```bash
# Train only
python3 train/main.py --train

# Train with custom settings
python3 train/main.py --train --epochs 120 --imgsz 640 --batch 16 --name yolo26_custom

# Export only (uses latest run path by default)
python3 train/main.py --export

# Export with explicit best.pt path
python3 train/main.py --export --best-weights train/runs/detect/yolo26_obstacle/weights/best.pt

# Train and export in one run
python3 train/main.py --train --export
```

## 5. Workflow Summary

| Task | Command |
| --- | --- |
| Train model | `python3 train/main.py --train` |
| Export ONNX | `python3 train/main.py --export` |
| Train + export | `python3 train/main.py --train --export` |
