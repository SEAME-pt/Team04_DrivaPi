"""Training and export orchestration for obstacle detection."""

from __future__ import annotations

from pathlib import Path

from ultralytics import YOLO

from config import TrainConfig


class ObstacleTrainer:
    """Class-based trainer for YOLO obstacle detection."""

    def __init__(self, config: TrainConfig) -> None:
        self._config = config

    def train(self) -> Path:
        """Run YOLO training and return best weights path."""
        model = YOLO(self._config.weights)
        model.train(
            data=str(self._config.data_path),
            epochs=self._config.epochs,
            imgsz=self._config.imgsz,
            lr0=self._config.lr0,
            batch=self._config.batch,
            augment=self._config.augment,
            patience=self._config.patience,
            name=self._config.run_name,
            project=str(self._config.project_dir),
        )
        return self._default_best_weights_path()

    def export_onnx(self, best_weights: Path | None = None) -> Path:
        """Export best checkpoint to ONNX and return the output path."""
        weights_path = (best_weights or self._config.best_weights or self._default_best_weights_path()).resolve()
        model = YOLO(str(weights_path))
        model.export(format="onnx", imgsz=640, opset=12, simplify=True)
        return weights_path.with_suffix(".onnx")

    def _default_best_weights_path(self) -> Path:
        return self._config.project_dir / self._config.run_name / "weights" / "best.pt"
