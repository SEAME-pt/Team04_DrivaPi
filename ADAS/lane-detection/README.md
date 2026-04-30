# Lane Detection Module

This module provides a training pipeline for lane detection models using YOLO11 segmentation, a state-of-the-art approach for real-time lane boundary detection in autonomous driving applications.

## Why YOLO11?

YOLO11 (You Only Look Once v11) is chosen for lane detection because:

- **Real-time Performance**: Single-pass architecture enables fast inference suitable for autonomous driving
- **Segmentation Accuracy**: Precise pixel-level lane boundary detection vs. simple line regression
- **Transfer Learning**: Pre-trained models allow quick adaptation to new datasets with minimal training data
- **Edge Deployment**: Lightweight models (nano variant) run efficiently on embedded hardware
- **Community Support**: Well-maintained with extensive documentation and community examples

## Module Overview

The lane detection module provides:

- **Pre-trained YOLO11n-seg**: Transfer learning checkpoint for lane detection tasks
- **Training Pipeline**: Simplified single-PC training with configuration management
- **Metrics & Evaluation**: Automatic calculation of training metrics and model performance tracking
- **Reproducibility**: YAML-based configuration for consistent, repeatable training runs

## Quick Start

Navigate to the training directory and run training:

```bash
cd ADAS/lane-detection/scripts/train
source .venv/bin/activate
python main.py --config training_config.yaml
```

For complete environment setup, dataset preparation, and detailed training instructions, see [solo_train.md](scripts/train/solo_train.md).

## Contributing

Follow the [Team Coding Standards](../../.github/instructions/coding-standards.instructions.md) when contributing to this module.

## License

See [CODE_OF_CONDUCT.md](../../CODE_OF_CONDUCT.md) for project guidelines.
