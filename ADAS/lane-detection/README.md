# Lane Following (RPi5 = Raspberry Pi 5 + Hailo-8)

Lane detection for the Piracer: a CSI (Camera Serial Interface) camera frame
runs through a YOLOv8n-seg (You Only Look Once v8 nano, segmentation) model on
the Hailo-8 NPU (Neural Processing Unit); the host (Pi CPU) decodes it into
per-class lane masks, smooths them over time, and fits a continuous line per
lane. The output
is the **lane geometry** (`lane_lines`), ready for a steering controller.

The heavy work (the neural net) runs on the Hailo chip. Everything else
(decode, masks, temporal smoothing, line fitting) is light NumPy on the CPU.

## Layout

```
ADAS/lane-detection/
├── models/lane_seg.hef          # compiled INT8 model (Hailo-8)
├── deploy_lanes_headless.py      # the runtime: camera → Hailo → lane geometry
├── media/lane_demo_int8.mp4      # what the deployed model produces (validation ref)
└── README.md
```

To deploy: copy `lane_seg.hef` + `deploy_lanes_headless.py` to the Pi and run.

## Demo / validation
`media/lane_demo_int8.mp4` shows the **deployed INT8 model** (the same path that
runs on the car) detecting lanes and fitting the lines — a reference for what a
correct run should look like.

## Run (on the Pi)

```bash
python3 deploy_lanes_headless.py            # driving (headless, ~30 FPS)
python3 deploy_lanes_headless.py --debug    # also draw masks/lines + steering overlay
python3 deploy_lanes_headless.py --source clip.mp4   # test on a video
```

Requirements on the Pi: `hailo_platform` (HailoRT), `opencv-python`, `numpy`,
and `rpicam-vid` for the CSI camera.

### Output for the controller
Each frame the loop produces:
- `lane_lines` — `{class_name: [ (N,2) float arrays in frame pixels ]}` — the
  fitted lane geometry (this is what a steering controller consumes).
- `steering` — `(target_x, err)` starter signal (`err ∈ [-1 left, +1 right]`).
  Replace with control logic at the `# TODO: send to control` hook.

Config knobs (top of the file): `ROTATE_180` (camera mounting), `ROI_RATIO`
(ROI = Region of Interest), `CONF_THRESH_PER_CLASS`, `TEMPORAL_MAX_AGE`,
`LOOKAHEAD_FRAC`.

## Model facts
- YOLOv8n-seg, 5 classes: `center_continuous_lane, center_dashed_lane,
  crosswalk, left_lane, right_lane`. Input 640×640, **[0,255]** (the HEF (Hailo
  Executable Format) normalizes /255 on-chip — do **not** divide by 255 in
  software).
- Validated (DFC = Dataflow Compiler, INT8 emulation): INT8-vs-FP32 (32-bit
  floating point) mask IoU (Intersection over Union) **0.895**;
  INT8-vs-ground-truth mask IoU **0.641** (vs 0.650 FP32 — quantization costs <1pt).
- Measured on the car: **~29 FPS** (frames per second) headless.

## How the model was made

You don't need to rebuild anything to drive — `lane_seg.hef` is shipped ready to
use. This is just context.

It's a **YOLOv8n-seg** segmentation model, trained on labelled track footage to
find the 5 lane types, then converted to **INT8** and compiled for the Hailo-8
chip (train → export to ONNX (Open Neural Network Exchange) → quantize →
compile). The training weights and dataset are kept in the team's model/data
store, not in this repo.

> **Why v8 and not v11?** The module was originally planned around YOLO11n-seg.
> Tested on the Hailo DFC (3.33): YOLO11n-seg **parses and quantizes**, but
> **fails at compile** — its `C2PSA` attention block's matmul hits a Hailo-8
> limitation (`More than one output is not supported for layer matmul1`, and it
> can't reach the required FPS), so it never produces a working `.hef` with the
> standard flow. YOLOv8n-seg is pure-conv, compiles cleanly (~60% utilization)
> and is validated — hence the **deployed model is v8**.

If you ever touch the pipeline, the one thing that's easy to get wrong: **the
chip expects the raw image in 0–255 and does the /255 itself**, so the code must
not divide by 255 (already handled in `deploy_lanes_headless.py`).

Full reproducible recipe (ONNX export → DFC compile → HEF, with the exact
commands, I/O layers and troubleshooting): see **[compilation.md](compilation.md)**.
Source artifacts (weights, dataset) live in the team's model/data store.

## Notes
- Steering (Stanley) is intentionally **not** included yet — the runtime
  exposes `lane_lines`, so the controller plugs in later.

