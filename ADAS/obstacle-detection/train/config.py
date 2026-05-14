"""Configuration helpers for obstacle detection training and export."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Sequence


TRAIN_DIR = Path(__file__).resolve().parent
DEFAULT_DATA_RELATIVE_PATH = Path("..") / "dataset" / "data.yaml"
DEFAULT_PROJECT_RELATIVE_PATH = Path("runs") / "detect"


@dataclass(frozen=True)
class TrainConfig:
    """Training and export configuration values."""

    train: bool
    export: bool
    weights: str
    data_path: Path
    epochs: int
    imgsz: int
    lr0: float
    batch: int
    augment: bool
    patience: int
    run_name: str
    project_dir: Path
    best_weights: Path | None


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Obstacle detection training CLI")
    parser.add_argument("--train", action="store_true", help="Run model training")
    parser.add_argument("--export", action="store_true", help="Export best model to ONNX")
    parser.add_argument("--weights", type=str, default="yolo26n.pt", help="Base YOLO weights/model")
    parser.add_argument(
        "--data",
        type=Path,
        default=DEFAULT_DATA_RELATIVE_PATH,
        help="Dataset YAML path",
    )
    parser.add_argument("--epochs", type=int, default=100, help="Training epochs")
    parser.add_argument("--imgsz", type=int, default=640, help="Training/export image size")
    parser.add_argument("--lr0", type=float, default=0.01, help="Initial learning rate")
    parser.add_argument("--batch", type=int, default=16, help="Batch size")
    parser.add_argument("--augment", dest="augment", action="store_true", help="Enable augmentation")
    parser.add_argument("--no-augment", dest="augment", action="store_false", help="Disable augmentation")
    parser.set_defaults(augment=True)
    parser.add_argument("--patience", type=int, default=20, help="Early stopping patience")
    parser.add_argument("--name", type=str, default="yolo26_obstacle", help="Training run name")
    parser.add_argument(
        "--project",
        type=Path,
        default=DEFAULT_PROJECT_RELATIVE_PATH,
        help="Directory where training runs are stored",
    )
    parser.add_argument(
        "--best-weights",
        type=Path,
        default=None,
        help="Optional path to best.pt for export (defaults to latest run path)",
    )
    return parser


def get_config(argv: Sequence[str] | None = None) -> TrainConfig:
    """Parse command line arguments and return a typed configuration."""
    parser = _build_parser()
    args = parser.parse_args(argv)

    if not args.train and not args.export:
        parser.error("At least one action is required: --train and/or --export")

    data_path = args.data
    if not data_path.is_absolute():
        data_path = (TRAIN_DIR / data_path).resolve()

    project_dir = args.project
    if not project_dir.is_absolute():
        project_dir = (TRAIN_DIR / project_dir).resolve()

    best_weights = args.best_weights
    if best_weights is not None and not best_weights.is_absolute():
        best_weights = (TRAIN_DIR / best_weights).resolve()

    return TrainConfig(
        train=args.train,
        export=args.export,
        weights=args.weights,
        data_path=data_path,
        epochs=args.epochs,
        imgsz=args.imgsz,
        lr0=args.lr0,
        batch=args.batch,
        augment=args.augment,
        patience=args.patience,
        run_name=args.name,
        project_dir=project_dir,
        best_weights=best_weights,
    )
