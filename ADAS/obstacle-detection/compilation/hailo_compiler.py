import pkgutil
from pathlib import Path
from random import Random

import numpy as np
from PIL import Image
from hailo_sdk_client import ClientRunner
from hailo_sdk_common.paths_manager.paths import SDKPaths

from hailo_config import HailoConfig


class HailoCompiler:
    """Hailo-8 compiler implementation for obstacle detection."""

    def __init__(self, config: HailoConfig):
        self._apply_sdk_paths_compatibility()
        self._config = config
        self._runner = ClientRunner(hw_arch="hailo8")

    @staticmethod
    def _apply_sdk_paths_compatibility() -> None:
        """
        Ensure Hailo tools are resolved on dist-packages based installs.

        Some Ubuntu images install the SDK under dist-packages. In that case,
        SDKPaths may not classify it as a release install and returns None
        for the compiler binary path.
        """
        sdk_paths = SDKPaths()
        if sdk_paths.join_hailo_tools_path("build/compiler") is not None:
            return

        loader = pkgutil.get_loader("hailo_sdk_common")
        if loader is None:
            raise RuntimeError("hailo_sdk_common is not available in this environment")

        sdk_root = Path(loader.get_filename()).resolve().parent.parent
        compiler_path = sdk_root / "hailo_tools" / "build" / "compiler"
        if not compiler_path.exists():
            raise FileNotFoundError(f"Hailo compiler binary not found at: {compiler_path}")

        # Force release layout resolution when packages are under dist-packages.
        sdk_paths._is_release = True

    def parse(self):
        """Parse ONNX and load Hailo model script."""
        print(f"[*] Starting parsing: {self._config.onnx_path.name}")

        self._runner.translate_onnx_model(
            str(self._config.onnx_path),
            self._config.model_name,
            end_node_names=self._config.end_node_names
        )

        alls_path = self._config.inference_dir / "optimize.alls"

        print(f"[*] Loading model script: {alls_path}")
        print("--- optimize.alls ---")
        print(alls_path.read_text())
        print("---------------------")

        self._runner.load_model_script(str(alls_path))

        print("[+] Parsing completed successfully!")

    def optimize(self):
        """Run INT8 quantization."""
        print(f"[*] Loading {self._config.calib_count} images for calibration...")

        dataset = self._load_data()

        print("[*] Starting Quantization (INT8)...")

        self._runner.optimize(dataset)

    def compile(self):
        """Compile model into HEF."""
        print("[*] Compiling to HEF...")

        hef = self._runner.compile()

        if hef is None:
            raise RuntimeError(
                "Compilation failed: Hailo SDK returned None "
                "(likely graph/resource issue)"
            )

        self._config.output_hef.write_bytes(hef)

        print(f"✅ SUCCESS! Generated: {self._config.output_hef}")

    def run_pipeline(self):
        self.parse()
        self.optimize()
        self.compile()

    def _load_data(self):
        """
        Load calibration images.

        IMPORTANT:
        Keep values in [0,255].
        normalization() in optimize.alls handles scaling.
        """

        files = []

        for d in self._config.calib_dirs:
            if d.exists():
                files.extend([
                    p for p in d.rglob("*")
                    if p.suffix.lower() in {".jpg", ".jpeg", ".png"}
                ])

        if not files:
            raise FileNotFoundError(
                "No calibration images found!"
            )

        Random(42).shuffle(files)

        selected = files[:self._config.calib_count]

        images = []

        for p in selected:
            img = (
                Image.open(p)
                .convert("RGB")
                .resize((640, 640))
            )

            # RAW PIXELS [0,255]
            arr = np.array(img).astype(np.float32)

            images.append(arr)

        return np.array(images)
