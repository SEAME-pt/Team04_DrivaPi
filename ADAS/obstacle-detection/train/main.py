"""CLI entry point for obstacle detection training and export."""

from __future__ import annotations

from config import get_config
from trainer import ObstacleTrainer


def main() -> None:
    """Execute requested CLI actions."""
    config = get_config()
    trainer = ObstacleTrainer(config)

    if config.train:
        trainer.train()

    if config.export:
        trainer.export_onnx()


if __name__ == "__main__":
    main()
