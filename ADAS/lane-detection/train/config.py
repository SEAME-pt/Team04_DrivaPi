"""Configuration and argument parsing utilities.

This module handles two configuration methods:
1. Command-line arguments (highest precedence)
2. YAML config file (base configuration)

Usage:
    Basic: python solo_train.py --data dataset/data.yaml
    With config: python solo_train.py --config config.yaml
    Override: python solo_train.py --config config.yaml --epochs 200
"""
import argparse
import os
import sys
import yaml


def parse_arguments(argv=None):
    """Parse command line arguments for training.
    
    Returns:
        argparse.Namespace: Parsed arguments with all parameters
    """
    parser = argparse.ArgumentParser(description="Distributed YOLO Training")
    parser.add_argument("--config", type=str, default=None, help="Path to training configuration YAML file")
    parser.add_argument("--weights", type=str, default="yolo11n-seg.pt", help="Path to model weights or model name")
    parser.add_argument("--data", type=str, default=None, help="Path to dataset YAML file")
    parser.add_argument("--img-size", type=int, default=640, help="Input image size")
    parser.add_argument("--epochs", type=int, default=100, help="Number of training epochs")
    parser.add_argument("--batch-size", type=int, default=16, help="Total batch size across all GPUs")
    parser.add_argument("--workers", type=int, default=4, help="Number of data loading workers")
    parser.add_argument("--name", type=str, default="exp", help="Experiment name for saving results")
    parser.add_argument("--val", action="store_true", help="Run validation during training")
    parser.add_argument("--patience", type=int, default=10, help="Early stopping patience in epochs")
    parser.add_argument("--optimizer", type=str, default="SGD", choices=["SGD", "Adam"], help="Optimizer choice")
    parser.add_argument("--path", type=str, default=None, help="Path to save the trained model weights")
    parser.add_argument("--lr0", type=float, default=None, help="Initial learning rate")
    parser.add_argument("--lrf", type=float, default=None, help="Final learning rate fraction")
    
    if argv is None:
        argv = sys.argv[1:]

    args = parser.parse_args(argv)
    return args


def load_config_from_yaml(config_path):
    """Load configuration from YAML file.
    
    Args:
        config_path: Path to YAML configuration file
        
    Returns:
        dict: Configuration dictionary from YAML
        
    Raises:
        FileNotFoundError: If config file does not exist
    """
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Config file not found: {config_path}")
    
    with open(config_path, "r") as f:
        config_dict = yaml.safe_load(f)
    
    return config_dict


def merge_config_with_args(args, config_dict):
    """Merge YAML config with parsed command line arguments.
    
    Priority: YAML config values override defaults, but CLI args can override config.
    This happens in get_config() which loads config first, then applies CLI args.
    
    Args:
        args: argparse.Namespace with parsed arguments
        config_dict: Dictionary loaded from YAML file
        
    Returns:
        argparse.Namespace: Updated arguments with config values
    """

    if config_dict:
        # Update args with config values (keys can use hyphens in YAML)
        for key, value in config_dict.items():
            # Only normalize hyphens when it matches a known CLI arg
            cli_key = key.replace("-", "_")
            if not hasattr(args, cli_key):
                setattr(args, key, value)
        print(f"Loaded configuration from config file")
    
    return args


def get_config():
    """Parse arguments and load configuration.
    
    Precedence order:
    1. Command-line arguments (highest)
    2. YAML config file values
    3. Argument parser defaults (lowest)
    
    Required: --data argument must be set either via --config or CLI
    
    Returns:
        argparse.Namespace: Final configuration
        
    Raises:
        ValueError: If required --data argument is not provided
    """
    args = parse_arguments()
    
    # Load config from YAML if provided
    if args.config:
        config_dict = load_config_from_yaml(args.config)
        args = merge_config_with_args(args, config_dict)
    
    # Ensure required arguments are set
    if not args.data:
        raise ValueError("--data argument is required (either via --config or command line)")
    
    return args

