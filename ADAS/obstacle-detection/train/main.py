"""CLI entry point for obstacle detection training and export."""

from __future__ import annotations

from config import get_config
from trainer import ObstacleTrainer


def main() -> None:
    """Execute requested CLI actions."""
    try:
        config = get_config()
        trainer = ObstacleTrainer(config)

        best_pt_path = None

        if config.train:
            print(f"[*] Starting training: {config.run_name}")
            best_pt_path = trainer.train()

        if config.export:
            print("[*] Starting export to ONNX...")
            trainer.export_onnx(best_weights=best_pt_path)

    except Exception as e:
        print(f"Error occurred: {e}")
        return


if __name__ == "__main__":
    main()
