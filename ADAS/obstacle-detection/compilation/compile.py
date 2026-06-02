"""CLI entry point for Hailo-8 model compilation."""

import argparse
import sys
from pathlib import Path
from hailo_compiler import HailoCompiler
from hailo_config import HailoConfig

def main() -> None:
    parser = argparse.ArgumentParser(description="DrivaPi Hailo Compiler")
    parser.add_argument("--run", action="store_true", required=True)
    parser.add_argument("--onnx", type=Path, help="Path to ONNX model")
    parser.add_argument("--output-hef", type=Path, help="Custom output path")

    args = parser.parse_args()

    config = HailoConfig(onnx_path=args.onnx, output_hef=args.output_hef)
    print(f"[*] Config initialized: {config}")

    compiler = HailoCompiler(config)
    try:
        compiler.run_pipeline()
    except Exception as e:
        print(f"[-] Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
