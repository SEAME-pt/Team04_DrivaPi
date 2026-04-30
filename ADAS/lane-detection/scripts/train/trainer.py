"""Training utilities and main training logic.

This module orchestrates the YOLO training pipeline:
1. Loads model and dataset configuration
2. Builds training parameters from config
3. Runs the training loop
4. Saves best results and model paths
"""
import os
import yaml
from datetime import datetime
import torch
from ultralytics import YOLO
from metrics import should_save_results


def build_train_kwargs(args, local_rank):
    """Build training keyword arguments from configuration.
    
    Constructs the parameter dictionary passed to YOLO.train().
    Includes optional learning rate parameters if specified.
    
    Args:
        args: Configuration namespace from config module
        local_rank: GPU device index (for distributed training)
        
    Returns:
        dict: Complete training parameters for YOLO
    """
    train_kwargs = dict(
        task="segment",
        data=args.data,
        imgsz=args.img_size,
        epochs=args.epochs,
        batch=args.batch_size,
        device=f"cuda:{local_rank}",
        workers=args.workers,
        name=args.name,
        val=args.val,
        plots=False,
        save=True,
        patience=args.patience,
        optimizer=args.optimizer,
        project=args.path + "train/" + datetime.now().strftime("%Y%m%d_%H%M%S"),
        resume=True
    )

    # Add optional learning rate parameters if specified
    if args.lr0 is not None:
        train_kwargs["lr0"] = args.lr0
    if args.lrf is not None:
        train_kwargs["lrf"] = args.lrf

    return train_kwargs


def save_training_results(model, results, args, local_rank):
    """Save training results and arguments to YAML files.
    
    Only writes to disk on the main process (rank 0) in distributed training.
    Compares new results with previous best to avoid overwriting good models.
    
    Saves two files:
    - results.yaml: Training metrics, model paths, and comparison summary
    - args.yaml: Configuration parameters used (only if new results are better)
    
    Args:
        model: YOLO model object (contains trainer and best model info)
        results: Training results object from model.train()
        args: Configuration namespace
        local_rank: Process rank (only rank 0 saves results)
    """
    if int(local_rank) != 0:
        return
    
    save_dir = os.path.join(args.path, args.name)
    os.makedirs(save_dir, exist_ok=True)
    
    # Build results dictionary with all training information
    results_dict = {
        "training_complete": True,
        "final_metrics": results.results_dict if hasattr(results, 'results_dict') else {},
        "model_path": args.weights  # Initial model used
    }
    
    # Try to get trainer metrics if available (custom metrics during training)
    if hasattr(model, 'trainer') and hasattr(model.trainer, 'metrics'):
        results_dict["trainer_metrics"] = dict(model.trainer.metrics)
    
    # Try to get best model path discovered during training
    if hasattr(model, 'trainer') and hasattr(model.trainer, 'best'):
        results_dict["best_model_path"] = str(model.trainer.best)
    
    # Check if new results are better than previous results
    # This prevents overwriting good models with marginally worse ones
    should_save, message = should_save_results(save_dir, results_dict)
    print(f"Result comparison: {message}")
    
    if should_save:
        # Save results metrics
        results_file = os.path.join(save_dir, "results.yaml")
        with open(results_file, "w") as f:
            yaml.dump(results_dict, f, default_flow_style=False)
        print(f"Results saved to {results_file}")
        
        # Save args only if results are better
        # (allows tracking what config produced the best model)
        args_dict = vars(args)
        args_file = os.path.join(save_dir, "args.yaml")
        with open(args_file, "w") as f:
            yaml.dump(args_dict, f, default_flow_style=False)
        print(f"Arguments saved to {args_file}")
    else:
        print("Results not saved (not better than previous best)")


def train(args):
    """Execute training on the current process.
    
    Main training orchestration function:
    1. Sets up GPU device for this process
    2. Loads the model
    3. Builds training parameters
    4. Runs training
    5. Saves results and model paths
    
    Args:
        args: Configuration namespace from config module
    """
    local_rank = os.environ.get("LOCAL_RANK", "0")
    print(f"Process {local_rank} starting training...")
    torch.cuda.set_device(int(local_rank))
    
    # Load model (auto-downloads if needed)
    model = YOLO(args.weights)

    # Set default path if not provided
    if args.path is None:
        args.path = os.getcwd() + "/runs/"

    # Build training kwargs from configuration
    train_kwargs = build_train_kwargs(args, local_rank)

    # Run training loop
    results = model.train(**train_kwargs)
    
    # Save results and metrics to YAML files
    save_training_results(model, results, args, local_rank)
    
    print(f"Process {local_rank} completed training.")

