# Compiling the lane model: trained checkpoint → `.hef` (Hailo-8)

End-to-end recipe to turn a trained YOLO-seg checkpoint into a deployable
`lane_seg.hef`, with no prior context required. Targets **Hailo-8**.

> **Use a YOLOv8n-seg checkpoint, not YOLO11.** YOLO11n-seg parses and quantizes
> but **fails to compile** on the Hailo-8: its `C2PSA` attention block produces
> `More than one output is not supported for layer matmul1`. YOLOv8n-seg is
> pure-conv and compiles cleanly. (Tested on DFC 3.33 — see Troubleshooting.)

## Acronyms

| Term | Meaning |
|---|---|
| **YOLOv8n-seg** | The model. YOLO = object-detector family · `-seg` = segmentation variant (outputs pixel masks, not just boxes) · `n` = nano (smallest/fastest) |
| **checkpoint** | The saved trained model file (`best.pt`) — the weights produced by training |
| **NPU** | Neural accelerator — the Hailo-8 chip that runs the model |
| **DFC** | Hailo **D**ataflow **C**ompiler — the toolchain that turns an ONNX into a `.hef` |
| **HailoRT** | Hailo Runtime — the on-device library that loads and runs the `.hef` |
| **ONNX** | Open model format exported from PyTorch (the input to the DFC) |
| **HAR** | Hailo Archive — intermediate file between the parse / optimize / compile steps |
| **HEF** | Hailo Executable Format — the **final compiled model** that runs on the chip |
| **INT8 / FP32** | 8-bit integer vs 32-bit float — INT8 is the quantized precision the chip runs; FP32 is full precision on a PC |
| **calibration set** | A few hundred sample images the DFC uses to choose the INT8 ranges |
| **model script (`.alls`)** | A small Hailo config file applied during *optimize* (e.g. on-chip normalization) |
| **head** | An output branch of the network — here the box / class / mask / proto branches |
| **stride** | How much a feature map is shrunk vs the input (8/16/32 → coarser grids) |
| **DFL** | YOLO's box encoding — predicts each box edge as a small distribution, not a single number |
| **anchor** | A reference point on the feature grid that box predictions are measured from |
| **proto** | The mask "prototype" bank — 32 basis masks the per-detection coefficients combine into a lane mask |
| **SiLU / sigmoid** | Activation functions — SiLU is used inside YOLO; sigmoid squashes a value to a 0–1 probability |
| **C2PSA** | YOLO11's attention block (the part that does **not** compile for Hailo) |
| **matmul** | Matrix multiply — the operation inside attention that Hailo can't compile (it multiplies data×data, unlike a conv which is data×fixed-weights) |
| **pure-conv** | A network built only from convolutions (no attention) — what the NPU compiles cleanly; YOLOv8 is this |
| **ROI** | Region of interest — here, blacking out the top 35% (sky/ceiling) so the model only sees the road |
| **NHWC** | Tensor layout: batch, height, width, channels (the order Hailo uses for I/O) |

## Prerequisites

- The **Hailo AI SW Suite** Docker image (this guide used `hailo8_ai_sw_suite_2025-10:1`, DFC 3.33 / HailoRT 4.23).
- A trained **YOLOv8n-seg** checkpoint `best.pt` (5 lane classes).
- Python with `ultralytics` to export the ONNX.
- A folder of representative **calibration images** (~256 frames, same view/ROI as deployment).

Pick a working directory; everything below writes into it:
```bash
export WORKDIR=$(pwd)/workspace && mkdir -p "$WORKDIR"
```

## 1. Export the trained checkpoint → ONNX

```python
# export_onnx.py   (run: python3 export_onnx.py)
from ultralytics import YOLO
m = YOLO("best.pt")
m.export(format="onnx", imgsz=640, opset=11, simplify=True, dynamic=False, half=False)
# → best.onnx
```
- `opset=11`, fixed batch (`dynamic=False`), FP32 (`half=False`) — the DFC does its own INT8.
- If `best.pt` was trained with a custom loss/model class, that class must be importable for `torch` to unpickle it (otherwise the load fails).

Move `best.onnx` into `$WORKDIR`.

## 2. Build the calibration set

A single stacked `.npy` of shape `(N, 640, 640, 3)` in **[0, 255]** (the chip does
the /255 — see step 3 / Troubleshooting):

```python
# prepare_calib.py
import cv2, numpy as np, glob
imgs = sorted(glob.glob("calib_images/*.jpg"))[:256]
arr = []
for p in imgs:
    im = cv2.imread(p)
    im[: int(im.shape[0]*0.35)] = 0                 # same ROI as training (top 35%)
    im = cv2.cvtColor(im, cv2.COLOR_BGR2RGB)
    arr.append(cv2.resize(im, (640, 640)).astype(np.float32))   # keep [0,255]
np.save("calib_set.npy", np.stack(arr))             # (N,640,640,3)
```
Put `calib_set.npy` in `$WORKDIR`.

## 3. Model script (`lane_seg.alls`)

Create `$WORKDIR/lane_seg.alls` with exactly:
```
normalization1 = normalization([0.0, 0.0, 0.0], [255.0, 255.0, 255.0])
allocator_param(width_splitter_defuse=disabled)
```
- `normalization1` makes the chip do **/255** on-chip → feed it raw **[0,255]**.
- **No** `change_output_activation(sigmoid)` here: the runtime applies the class
  sigmoid in software, so baking it in too would double-sigmoid.

## 4. DFC: parse → optimize (INT8) → compile

Run inside the Hailo container. Mount `$WORKDIR` as `/workspace`; make it
world-writable first (see Troubleshooting → permissions):

```bash
chmod 777 "$WORKDIR"
docker run --rm -w /workspace -v "$WORKDIR":/workspace \
    hailo8_ai_sw_suite_2025-10:1 bash -lc '
set -e
ARCH=hailo8

# 4a. PARSE — cut the 10 RAW heads (the runtime decodes these). Proto is cut
#     AFTER its SiLU activation (the Mul node), not at the conv.
hailo parser onnx best.onnx --hw-arch $ARCH --net-name lane_seg --har-path lane_seg.har \
  --end-node-names \
    /model.22/cv2.0/cv2.0.2/Conv /model.22/cv3.0/cv3.0.2/Conv /model.22/cv4.0/cv4.0.2/Conv \
    /model.22/cv2.1/cv2.1.2/Conv /model.22/cv3.1/cv3.1.2/Conv /model.22/cv4.1/cv4.1.2/Conv \
    /model.22/cv2.2/cv2.2.2/Conv /model.22/cv3.2/cv3.2.2/Conv /model.22/cv4.2/cv4.2.2/Conv \
    /model.22/proto/cv3/act/Mul

# 4b. OPTIMIZE — INT8 quantization with the calib set + the model script
hailo optimize lane_seg.har --hw-arch $ARCH \
  --calib-set-path calib_set.npy \
  --model-script lane_seg.alls \
  --output-har-path lane_seg_optimized.har

# 4c. COMPILE → .hef
hailo compiler lane_seg_optimized.har --hw-arch $ARCH --output-dir /workspace
'
# result: $WORKDIR/lane_seg.hef
```

Notes:
- The end-node names are the YOLOv8-seg head (`model.22`). For YOLO11 they would
  be `model.23`, but YOLO11 fails at compile anyway (see top).
- Per-stride: `cv2.*` = box (DFL, 64ch), `cv3.*` = classes (5ch), `cv4.*` = mask
  coefficients (32ch); `proto` = the 160×160 mask prototype bank.
- A successful compile prints `Successful Mapping` with a utilization total
  (this model: ~60%) and `Successful Compilation`.

Copy `lane_seg.hef` to `deploy/models/` and you're done.

## 5. HEF I/O layers (after compilation)

Verify with:
```python
from hailo_platform import HEF
h = HEF("lane_seg.hef")
print([(i.name, i.shape) for i in h.get_input_vstream_infos()])
print([(o.name, o.shape) for o in h.get_output_vstream_infos()])
```

**Input** — 1 layer, NHWC, fed as **float32 [0,255]**:

| name | shape |
|---|---|
| `lane_seg/input_layer1` | `(640, 640, 3)` |

**Outputs** — 10 layers (NHWC). The runtime identifies them **by shape, not by
name** (the `convNN` names are auto-assigned by the DFC and can change if you
recompile — do not hard-code them):

| name | shape | meaning | stride |
|---|---|---|---|
| `lane_seg/conv44` | `(80, 80, 64)` | box (DFL, 4×16) | 8 |
| `lane_seg/conv45` | `(80, 80, 5)`  | class scores    | 8 |
| `lane_seg/conv46` | `(80, 80, 32)` | mask coeffs     | 8 |
| `lane_seg/conv60` | `(40, 40, 64)` | box             | 16 |
| `lane_seg/conv61` | `(40, 40, 5)`  | class scores    | 16 |
| `lane_seg/conv62` | `(40, 40, 32)` | mask coeffs     | 16 |
| `lane_seg/conv73` | `(20, 20, 64)` | box             | 32 |
| `lane_seg/conv74` | `(20, 20, 5)`  | class scores    | 32 |
| `lane_seg/conv75` | `(20, 20, 32)` | mask coeffs     | 32 |
| `lane_seg/conv48` | `(160, 160, 32)` | mask prototypes | — |

How the runtime sorts them (`deploy_lanes_headless.py`):
- `c == 32 and h == 160` → **proto**
- `c == 64` → **box** (3 of them)
- `c == 5`  → **class scores** (3)
- `c == 32 and h != 160` → **mask coeffs** (3)

## 6. Troubleshooting — common DFC / compile errors

**`PermissionError: ... /workspace/pyhailort.log` or `.../hailo_autocompletion`**
The container runs as root, but Docker `userns-remap` maps it to a high host UID
that can't write the mounted host folder (and running `-u <uid>` breaks the
Hailo CLI's own setup). Fix: keep the **default container user (root)** and make
the mount writable: `chmod 777 "$WORKDIR"`.

**`Compilation failed: More than one output is not supported for layer matmul1`
/ `Failed to reach required FPS`**
You are compiling a **YOLO11** (or other attention) model — `matmul1` is the
`C2PSA` attention. Hailo-8 can't compile it via the standard flow. Use
**YOLOv8n-seg** (pure conv).

**Outputs look like `[1, 4, 8400]` / `[1, 116, 8400]` (one big tensor), runtime
decode fails.** You parsed without `--end-node-names`, so the DFC kept the
post-processing concat. Re-parse cutting the **10 raw heads** as in step 4a.

**Masks come out tiny / boxes wrong at runtime.** Not a DFC error — a decode
bug: the DFL box distances are in grid-cell units, so multiply by the **stride**
(`ltrb * stride`) before offsetting the anchor. Already handled in
`deploy_lanes_headless.py`.

**Detections degrade badly / near-random after deploy.** Normalization mismatch.
The `.alls` divides by 255 on-chip, so **both** the calibration set **and** the
runtime input must be **[0,255]**. Feeding [0,1] double-normalizes (the network
then sees values 255× too small). Pick one convention end-to-end.

**Class confidences look squashed / thresholds behave oddly.** Double sigmoid:
the `.alls` has `change_output_activation(sigmoid)` AND the runtime also sigmoids
the class scores. Do it in **one** place only (here: software, so keep it out of
the `.alls`).

**`hailo optimize` rejects the calibration path.** `--calib-set-path` expects a
**single `.npy`** of shape `(N, H, W, C)`, not a directory of per-image files.
Stack them (step 2).

**`End nodes mapped ...` lists fewer than expected / parse error on a node name.**
The node names are ONNX-specific (`model.22` for v8, `model.23` for v11). Inspect
your ONNX (e.g. with Netron — an ONNX graph viewer — or `onnx.load`) and use the actual names of the final
conv of each `cv2/cv3/cv4` branch + the proto's `act/Mul`.

## Acceptance checklist
- [ ] `lane_seg.hef` produced and loads in HailoRT.
- [ ] Input `(640,640,3)` + 10 outputs with the shapes in Section 5 (HEF I/O layers).
- [ ] Runs on the Pi via `deploy_lanes_headless.py` (see deploy README).
