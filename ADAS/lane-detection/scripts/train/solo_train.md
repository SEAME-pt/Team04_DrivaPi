# YOLO11n-seg Lane Detection — Training Guide (Single PC)

## Overview
This guide covers the full workflow for training a YOLOv11n-seg model for lane detection on a single machine, from environment setup to exporting the best checkpoint for deployment.

---

## Requirements

### Hardware
- NVIDIA GPU with at least 8GB VRAM (recommended)
- 16GB RAM minimum
- 50GB free disk space for dataset and checkpoints

### Software
- Ubuntu 22.04 / 24.04 (recommended)
- Python 3.10+
- CUDA 11.8+ and cuDNN
- Git

---

## 1. Environment Setup

### 1.1 Clone the repository
```bash
git clone https://github.com/SEAME-pt/Team04_DrivaPi.git
cd Team04_DrivaPi/lane-detection/scripts/train
```

### 1.2 Create and activate a virtual environment
```bash
python -m venv .venv
source .venv/bin/activate
```

### 1.3 Install dependencies
```bash
pip install ultralytics
```

### 1.4 Verify GPU is available
```bash
python -c "import torch; print(torch.cuda.is_available())"
# Expected output: True
```

---

## 2. Dataset Preparation

### 2.1 Directory structure
Ensure your dataset follows the YOLO segmentation format:

dataset/
├── data.yaml
├── images/
│   ├── train/
│   ├── val/
│   └── test/
└── labels/
├── train/
├── val/
└── test/


---

## 3. Training

### 3.1 Baseline training run
```bash
python3 main.py --data dataset/data.yaml
```

### 3.2 Configuration Methods

#### Option A: Command-line arguments
```bash
python3 main.py \
  --data dataset/data.yaml \
  --epochs 150 \
  --img-size 640 \
  --batch-size 16 \
  --name lane_detection_v1 \
  --val
```

#### Option B: YAML configuration file (Recommended for reproducibility)
Create `training_config.yaml`:
```yaml
# Model and data
weights: yolo11n-seg.pt
data: dataset/data.yaml

# Training parameters
epochs: 150
img-size: 640
batch-size: 16
workers: 4

# Learning rate
lr0: 0.01
lrf: 0.01

# Output and validation
name: lane_detection_v1
path: ./runs/
val: true

# Model optimization
patience: 20
optimizer: SGD
```

Then run:
```bash
python3 main.py --config training_config.yaml
```

You can override config values with CLI args:
```bash
python3 main.py --config training_config.yaml --epochs 200
```

### 3.3 Key hyperparameters

### 3.3 Key hyperparameters
| Parameter | Default | Notes |
|-----------|---------|-------|
| `epochs` | 100 | Increase to 150+ for larger datasets |
| `imgsz` | 640 | Use 320 if VRAM is limited |
| `batch` | 16 | Reduce if OOM errors occur |
| `lr0` | 0.01 | Initial learning rate |
| `lrf` | 0.01 | Final learning rate factor |
| `device` | 0 | GPU index; use `cpu` if no GPU |

### 3.4 Common Usage Scenarios

**Quick training (testing setup):**
```bash
python3 main.py --data dataset/data.yaml --epochs 10 --batch-size 8
```

**Production training with validation:**
```bash
python3 main.py --config training_config.yaml --val --patience 25
```

**Continue training from checkpoint:**
```bash
python3 main.py --config training_config.yaml --weights runs/train/exp1/weights/best.pt
```

**Reduce memory usage:**
```bash
python3 main.py --data dataset/data.yaml --batch-size 4 --img-size 320
```

**Custom learning rate schedule:**
```bash
python3 main.py --config training_config.yaml --lr0 0.001 --lrf 0.0001
```

### 3.5 Output Structure
After training, check the results:
```
runs/
└── train/
    └── 20260429_120345/  # Timestamp directory
        ├── args.yaml          # Training configuration used
        ├── results.yaml       # Final metrics & model paths
        └── weights/
            ├── best.pt        # Best checkpoint
            └── last.pt        # Latest checkpoint
```

---

## 4. Evaluation

After training, evaluate the best checkpoint on the test set:
```bash
yolo segment val \
  data=lanes.yaml \
  model=runs/segment/train/weights/best.pt \
  split=test
```

### Expected output metrics
| Metric | Target |
|--------|--------|
| mAP50 | ≥ 0.80 |
| mAP50-95 | ≥ 0.55 |
| Mask loss | Converged and stable |

---

## 5. Results & Evidence Checklist

Before closing this task, attach the following to the issue or PR:

- [ ] `lanes.yaml` config and hyperparameter overrides used
- [ ] Loss and mAP curves (TensorBoard or W&B screenshot)
- [ ] Visual sample of segmentation masks on held-out test images
- [ ] Final mAP50 and mAP50-95 scores
- [ ] Best checkpoint saved at `runs/segment/train/weights/best.pt`

---

## 6. Troubleshooting

**CUDA out of memory:**
- Reduce `batch` size (e.g. `batch=8` or `batch=4`)
- Reduce `imgsz` to `320`

**Low mAP after training:**
- Verify dataset annotations are correct
- Increase `epochs` and check loss curves for convergence
- Enable augmentation: add `mosaic=1.0 hsv_h=0.015 hsv_s=0.7` to training command

**Model not found error:**
- Ultralytics will auto-download `yolo11n-seg.pt` on first run; ensure internet access

---

## References
- [Ultralytics YOLO11 Docs](https://docs.ultralytics.com)
- [YOLO Segmentation Training Guide](https://docs.ultralytics.com/tasks/segment/)
- [Weights & Biases Integration](https://docs.ultralytics.com/integrations/weights-biases/)