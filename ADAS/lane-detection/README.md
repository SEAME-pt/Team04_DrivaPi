# Lane Following (RPi5 = Raspberry Pi 5 + Hailo-8)

Lane detection for the Piracer: a CSI (Camera Serial Interface) camera frame
runs through a YOLOv8n-seg (You Only Look Once v8 nano, segmentation) model on
the Hailo-8 NPU (Neural Processing Unit); the host (Pi CPU) decodes it into
per-class lane masks, keeps recent masks alive for a few frames to bridge short
detection gaps (temporal persistence), and fits one or more continuous lines per
lane class. The output is the **lane geometry** (`lane_lines`), each class maps
to a list of fitted line arrays, ready for a steering controller.

The heavy work (the neural net) runs on the Hailo chip. Everything else
(decode, masks, temporal persistence, line fitting) is lightweight NumPy/OpenCV
post-processing on the CPU.

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
python3 deploy_lanes_headless.py                          # driving (headless, ~30 FPS)
python3 deploy_lanes_headless.py --debug --record dbg.avi # save annotated debug video (masks, lines, steering)
python3 deploy_lanes_headless.py --source clip.mp4        # test on a video file
```

There is no on-screen window (headless). `--debug` builds the annotated overlay
but it is only useful when saved with `--record`; `--debug` on its own just adds
the first-inference output logging.

Requirements on the Pi: `hailo_platform` (HailoRT), `opencv-python`, `numpy`,
and `rpicam-vid` for the CSI camera.

### Output for the controller
Each frame the loop produces:
- `lane_lines` — `{class_name: [ (N,2) float arrays in frame pixels ]}` — the
  fitted lane geometry (this is what a steering controller consumes).
- `steering` — `(target_x, err)` experimental starter signal. `err` is the
  normalized lateral offset of the detected target from the image center:
  negative = target left of center, positive = target right of center (not
  explicitly clamped to [-1, 1]). This is **not** a final steering controller —
  replace it at the `# TODO: send to control` hook.

`crosswalk` is detected as a segmentation class (for scene awareness / debug),
but it is excluded from the lane-line geometry (`lane_lines`) consumed by the
future steering controller — only the lane classes are fitted into lines.

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

> **Why v8 and not v11?** YOLO11n-seg was tested but did not produce a deployable
> Hailo-8 `.hef` with the standard DFC flow, because of its `C2PSA` attention
> block. YOLOv8n-seg is pure-convolutional, compiles cleanly, and met the runtime
> target, so the **deployed model is v8**.
> (Exact DFC error and details in [compile/compilation.md](compile/compilation.md).)

If you ever touch the pipeline, the one thing that's easy to get wrong: **the
chip expects the raw image in 0–255 and does the /255 itself**, so the code must
not divide by 255 (already handled in `deploy_lanes_headless.py`).

Full reproducible recipe (ONNX export → DFC compile → HEF, with the exact
commands, I/O layers and troubleshooting): see **[compilation.md](compilation.md)**.
Source artifacts (weights, dataset) live in the team's model/data store.

## Notes
- Steering (Stanley) is intentionally **not** included yet — the runtime
  exposes `lane_lines`, so the controller plugs in later.

