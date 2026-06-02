"""Configuration objects for Hailo-8 obstacle model compilation."""

from __future__ import annotations
from pathlib import Path
from typing import ClassVar, Sequence

INFERENCE_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = INFERENCE_DIR.parent


class HailoConfig:
    """Typed configuration for parsing, optimization, and HEF compilation."""

    MODEL_NAME: ClassVar[str] = "yolo26_obstacle"

    END_NODE_NAMES: ClassVar[list[str]] = [
        "/model.23/Sigmoid",
        "/model.23/Slice",
        "/model.23/Slice_1",
    ]

    CALIB_DIRS: ClassVar[tuple[Path, ...]] = (
        Path("dataset") / "train" / "images",
        Path("dataset") / "tune_set" / "obstacle-tunning-team4-3" / "train" / "images",
    )

    CALIB_COUNT: ClassVar[int] = 512

    def __init__(
        self,
        onnx_path: Path | None = None,
        output_hef: Path | None = None,
        calib_dirs: Sequence[Path] | None = None,
        calib_count: int = CALIB_COUNT,
    ) -> None:
        self.project_root = PROJECT_ROOT
        self.inference_dir = INFERENCE_DIR
        self.model_name = self.MODEL_NAME

        default_onnx = (
            Path("train") / "runs" / "detect" / self.MODEL_NAME / "weights" / "best.onnx"
        )
        self.onnx_path = self._resolve_path(onnx_path or default_onnx)

        if not self.onnx_path.exists():
            print(f"\n[!] WARNING: ONNX model not found at: {self.onnx_path}")
            print(f"    Check if the path is relative to the project root.\n")

        self.output_hef = self._resolve_path(output_hef or Path(f"{self.MODEL_NAME}.hef"))

        self.end_node_names = list(self.END_NODE_NAMES)
        self.calib_dirs = [self._resolve_path(path) for path in (calib_dirs or self.CALIB_DIRS)]
        self.calib_count = calib_count

    def _resolve_path(self, path: Path) -> Path:
        """
        Resolves paths intelligently:
        1. If absolute, use it.
        2. If exists relative to project root, use that.
        3. Otherwise, fallback to relative to inference dir.
        """
        if path.is_absolute():
            return path

        path_from_root = (self.project_root / path).resolve()
        if path_from_root.exists() or "train/runs" in str(path):
            return path_from_root

        return (self.inference_dir / path).resolve()

    def __repr__(self) -> str:
        return f"HailoConfig(onnx={self.onnx_path.name}, calib_dirs={len(self.calib_dirs)})"
