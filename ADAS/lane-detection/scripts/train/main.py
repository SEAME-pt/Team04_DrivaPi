
"""Main entry point for YOLO lane detection training.

This script orchestrates the training pipeline for lane detection using YOLOv11n-seg.

Configuration Methods:
    1. YAML config file (recommended): python solo_train.py --config training_config.yaml
    2. Command-line arguments: python solo_train.py --data dataset/data.yaml --epochs 150
    3. Combined (config + CLI overrides): python solo_train.py --config config.yaml --epochs 200

Output:
    Trained models and results saved to runs/train/[timestamp]/
    - best.pt: Best model checkpoint
    - results.yaml: Training metrics and model paths
    - args.yaml: Configuration used
"""
from config import get_config
from trainer import train


def main():
    """Main entry point for training.
    
    Loads configuration and starts training process.
    """
    print("Starting training...")
    args = get_config()
    train(args)


if __name__ == "__main__":
    main()