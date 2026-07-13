"""
Headless lane detection for driving on the RPi5 + Hailo-8.

    python3 deploy_lanes_headless.py                          # driving (headless, fast)
    python3 deploy_lanes_headless.py --debug --record dbg.avi # save annotated debug video
    python3 deploy_lanes_headless.py --source clip.mp4        # test on a video file
    # headless: no window is shown; --debug's overlay is only useful with --record
"""

import argparse
import time
from pathlib import Path

import cv2
import numpy as np

# ── Config ────────────────────────────────────────────────────────────────────
HEF_PATH    = Path(__file__).parent / "models/lane_seg.hef"
CAM_W, CAM_H = 1280, 720
MODEL_SIZE  = 640
WORK_SIZE   = MODEL_SIZE // 4
ROI_RATIO   = 0.35
ROTATE_180  = True
IOU_THRESH  = 0.45
NUM_CLASSES = 5
REG_MAX     = 16
CONF_THRESH_PER_CLASS = np.array([0.45, 0.45, 0.45, 0.30, 0.45], dtype=np.float32)
TEMPORAL_MAX_AGE = 5
FIT_DEGREE, MIN_MASK_PX, MIN_SPAN, DASH_BRIDGE = 2, 6, 10, 13
LINE_CLASSES = {0, 1, 3, 4}     # lane classes (crosswalk excluded)
CLASS_NAMES  = ["center_continuous_lane", "center_dashed_lane", "crosswalk",
                "left_lane", "right_lane"]

# Steering: sample the lane lines at this height (fraction of frame, near the car)
LOOKAHEAD_FRAC = 0.85
REPORT_EVERY   = 30

# Debug drawing only
DRAW_MASKS = True
LINE_THICK = 4
CLASS_COLORS = [(0, 165, 255), (0, 255, 255), (255, 255, 0), (0, 255, 0), (0, 0, 255)]
# ──────────────────────────────────────────────────────────────────────────────


def preprocess(frame_bgr):
    proc = frame_bgr.copy()
    proc[: int(proc.shape[0] * ROI_RATIO)] = 0
    img = cv2.resize(proc, (MODEL_SIZE, MODEL_SIZE))
    # Keep input in [0, 255]. The HEF performs /255 normalization on-chip.
    return cv2.cvtColor(img, cv2.COLOR_BGR2RGB).astype(np.float32)[np.newaxis]


def sort_outputs(outputs):
    cv2_list, cv3_list, cv4_list, proto = [], [], [], None
    for tensor in outputs.values():
        t = np.squeeze(tensor).transpose(2, 0, 1)
        c, h, w = t.shape
        if h == MODEL_SIZE // 4 and c == 32:
            proto = t
        elif c == 4 * REG_MAX:
            cv2_list.append(t)
        elif c == NUM_CLASSES:
            cv3_list.append(t)
        elif c == 32:
            cv4_list.append(t)
    for lst in (cv2_list, cv3_list, cv4_list):
        lst.sort(key=lambda x: -x.shape[1])
    return cv2_list, cv3_list, cv4_list, proto


def _sigmoid(x):
    return 1.0 / (1.0 + np.exp(-np.clip(x, -88, 88)))


def _dfl_decode(box_raw):
    x = box_raw.reshape(box_raw.shape[0], 4, REG_MAX)
    x = x - x.max(axis=2, keepdims=True)
    e = np.exp(x)
    return ((e / e.sum(axis=2, keepdims=True)) * np.arange(REG_MAX, dtype=np.float32)).sum(axis=2)


def _make_anchors(stride):
    n = MODEL_SIZE // stride
    xs, ys = np.meshgrid(np.arange(n), np.arange(n))
    return (np.stack([xs.ravel(), ys.ravel()], axis=1).astype(np.float32) + 0.5) * stride


def _nms(boxes, scores):
    if not len(boxes):
        return []
    x1, y1, x2, y2 = boxes.T
    areas = (x2 - x1) * (y2 - y1)
    order = scores.argsort()[::-1]
    keep = []
    while order.size:
        i = order[0]; keep.append(i)
        ix1 = np.maximum(x1[i], x1[order[1:]]); iy1 = np.maximum(y1[i], y1[order[1:]])
        ix2 = np.minimum(x2[i], x2[order[1:]]); iy2 = np.minimum(y2[i], y2[order[1:]])
        inter = np.maximum(0, ix2 - ix1) * np.maximum(0, iy2 - iy1)
        iou = inter / (areas[i] + areas[order[1:]] - inter + 1e-6)
        order = order[1:][iou < IOU_THRESH]
    return keep


def decode(outputs):
    cv2_list, cv3_list, cv4_list, proto = sort_outputs(outputs)
    # All three head groups are indexed [i] in the loop below, so require the
    # full expected output structure before decoding (guards against an
    # incomplete inference result or a changed HEF layout → no IndexError).
    if proto is None or len(cv2_list) != 3 or len(cv3_list) != 3 or len(cv4_list) != 3:
        return [], proto
    all_boxes, all_scores, all_classes, all_coeffs = [], [], [], []
    for i, stride in enumerate([8, 16, 32]):
        cls_raw = _sigmoid(cv3_list[i].transpose(1, 2, 0).reshape(-1, NUM_CLASSES))
        conf = cls_raw.max(axis=1); cls_id = cls_raw.argmax(axis=1)
        keep = conf >= CONF_THRESH_PER_CLASS[cls_id]
        if not keep.any():
            continue
        box_raw = cv2_list[i].transpose(1, 2, 0).reshape(-1, 4 * REG_MAX)[keep]
        coeff = cv4_list[i].transpose(1, 2, 0).reshape(-1, 32)[keep]
        anchors = _make_anchors(stride)[keep]
        ltrb = _dfl_decode(box_raw) * stride
        boxes = np.stack([anchors[:, 0] - ltrb[:, 0], anchors[:, 1] - ltrb[:, 1],
                          anchors[:, 0] + ltrb[:, 2], anchors[:, 1] + ltrb[:, 3]],
                         axis=1).clip(0, MODEL_SIZE)
        all_boxes.append(boxes); all_scores.append(conf[keep])
        all_classes.append(cls_id[keep]); all_coeffs.append(coeff)
    if not all_boxes:
        return [], proto
    boxes = np.concatenate(all_boxes); scores = np.concatenate(all_scores)
    classes = np.concatenate(all_classes); coeffs = np.concatenate(all_coeffs)
    detections = []
    for c in range(NUM_CLASSES):
        idx = np.where(classes == c)[0]
        if not len(idx):
            continue
        for k in _nms(boxes[idx], scores[idx]):
            detections.append((boxes[idx[k]], c, scores[idx[k]], coeffs[idx[k]]))
    return detections, proto


def build_class_masks(detections, proto):
    class_masks = {}
    if proto is None or not detections:
        return class_masks
    P = WORK_SIZE
    coeffs = np.stack([d[3] for d in detections])
    masks = _sigmoid(coeffs @ proto.reshape(32, -1)).reshape(-1, P, P)
    boxes = (np.stack([d[0] for d in detections]) * (P / MODEL_SIZE)).clip(0, P).astype(int)
    for i, det in enumerate(detections):
        x1, y1, x2, y2 = boxes[i]
        crop = np.zeros((P, P), np.uint8)
        crop[y1:y2, x1:x2] = masks[i, y1:y2, x1:x2] > 0.5
        c = det[1]
        if c in class_masks:
            np.maximum(class_masks[c], crop, out=class_masks[c])
        else:
            class_masks[c] = crop
    return class_masks


class LaneMemory:
    def __init__(self, max_age=TEMPORAL_MAX_AGE):
        self.max_age = max_age; self.store = {}

    def update(self, class_masks):
        out = {}
        for c in range(NUM_CLASSES):
            if c in class_masks:
                self.store[c] = [class_masks[c], 0]; out[c] = class_masks[c]
            elif c in self.store:
                mask, age = self.store[c]
                if age < self.max_age:
                    self.store[c][1] = age + 1; out[c] = mask
                else:
                    del self.store[c]
        return out


def _fit_single(mask, degree=FIT_DEGREE, n_pts=40):
    ys, xs = np.nonzero(mask)
    if len(ys) < MIN_MASK_PX:
        return None
    y_span, x_span = ys.max() - ys.min(), xs.max() - xs.min()
    if y_span >= x_span:
        deg = degree if y_span > MIN_SPAN else 1
        coeffs = np.polyfit(ys, xs, deg)
        yy = np.linspace(ys.min(), ys.max(), n_pts); xx = np.polyval(coeffs, yy)
    else:
        deg = degree if x_span > MIN_SPAN else 1
        coeffs = np.polyfit(xs, ys, deg)
        xx = np.linspace(xs.min(), xs.max(), n_pts); yy = np.polyval(coeffs, xx)
    return np.stack([xx, yy], axis=1)          # float, WORK_SIZE coords


def fit_lane_lines(mask):
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, DASH_BRIDGE))
    closed = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    n, labels = cv2.connectedComponents(closed)
    lines = []
    for lab in range(1, n):
        pts = _fit_single((labels == lab).astype(np.uint8))
        if pts is not None:
            lines.append(pts)
    return lines


def extract_lane_lines(class_masks, w, h):
    """Fitted lane lines per class, in FRAME coordinates.
    Returns {class_name: [ (n,2) float array, ... ]}. This is the geometry the
    controller consumes — computed on the temporally-persisted masks."""
    mx, my = w / WORK_SIZE, h / WORK_SIZE
    out = {}
    for cls_id, mask in class_masks.items():
        if cls_id not in LINE_CLASSES:
            continue
        scaled = [pts * (mx, my) for pts in fit_lane_lines(mask)]
        if scaled:
            out[CLASS_NAMES[cls_id]] = scaled
    return out


def compute_steering(lane_lines, w, h):
    """Starter steering signal: at a lookahead row, take the mean x of the lane
    lines and return the normalized lateral error in [-1 (go left), +1 (go
    right)]. Returns None if no line reaches the lookahead row.

    >>> ADAPT THIS to control strategy (which lines define lane, PID,
        lookahead, etc.). The important output is `lane_lines` above. <<<
    """
    y_look = LOOKAHEAD_FRAC * h
    xs = []
    for lines in lane_lines.values():
        for pts in lines:
            ys = pts[:, 1]
            if y_look < ys.min() or y_look > ys.max():
                continue
            order = np.argsort(ys)
            xs.append(float(np.interp(y_look, ys[order], pts[order, 0])))
    if not xs:
        return None
    target_x = float(np.mean(xs))
    err = (target_x - w / 2) / (w / 2)
    return target_x, err


def draw_debug(frame, class_masks, lane_lines, steering):
    h, w = frame.shape[:2]
    if DRAW_MASKS and class_masks:
        overlay = frame.copy()
        for cls_id, mask in class_masks.items():
            big = cv2.resize(mask, (w, h), interpolation=cv2.INTER_NEAREST)
            overlay[big == 1] = CLASS_COLORS[cls_id]
        cv2.addWeighted(overlay, 0.45, frame, 0.55, 0, frame)
    for name, lines in lane_lines.items():
        c = CLASS_COLORS[CLASS_NAMES.index(name)]
        for pts in lines:
            cv2.polylines(frame, [pts.astype(np.int32)], False, c, LINE_THICK, cv2.LINE_AA)
    if steering is not None:
        target_x, err = steering
        y = int(LOOKAHEAD_FRAC * h)
        cv2.line(frame, (w // 2, y), (int(target_x), y), (255, 255, 255), 2)
        cv2.circle(frame, (int(target_x), y), 7, (255, 255, 255), -1)
        cv2.putText(frame, f"err={err:+.2f}", (10, 56),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
    return frame


def main(source, debug, record_path):
    if source:
        cap = cv2.VideoCapture(source)
        if not cap.isOpened():
            raise RuntimeError(f"Could not open video source: {source}")
        def get_frame():
            ok, f = cap.read()
            if not ok:
                return None
            return cv2.rotate(f, cv2.ROTATE_180) if ROTATE_180 else f
        release = cap.release
    else:
        import subprocess
        # hflip+vflip (= 180°) is applied by the sensor during readout, so frames
        # arrive already rotated and the CPU never copies them.
        cmd = ["rpicam-vid", "-t", "0", "--codec", "yuv420", "--width", str(CAM_W),
               "--height", str(CAM_H), "--framerate", "30", "-o", "-", "--nopreview"]
        if ROTATE_180:
            cmd += ["--hflip", "--vflip"]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        time.sleep(0.5)
        nbytes = CAM_W * CAM_H * 3 // 2

        def get_frame():
            raw = proc.stdout.read(nbytes)
            if len(raw) < nbytes:
                return None
            yuv = np.frombuffer(raw, dtype=np.uint8).reshape((CAM_H * 3 // 2, CAM_W))
            return cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
        release = proc.terminate

    from hailo_platform import (VDevice, HEF, ConfigureParams, HailoStreamInterface,
                                InputVStreamParams, OutputVStreamParams, FormatType, InferVStreams)
    hef = HEF(str(HEF_PATH))
    in_name = hef.get_input_vstream_infos()[0].name
    print(f"Hailo ready | model: {HEF_PATH.name} | mode: {'DEBUG' if debug else 'HEADLESS'}")

    memory = LaneMemory()
    writer = None
    n, t0 = 0, None

    try:
        with VDevice() as target:
            cfg = ConfigureParams.create_from_hef(hef, interface=HailoStreamInterface.PCIe)
            ng = target.configure(hef, cfg)[0]
            in_p = InputVStreamParams.make(ng, format_type=FormatType.FLOAT32)
            out_p = OutputVStreamParams.make(ng, format_type=FormatType.FLOAT32)
            with ng.activate(ng.create_params()):
                with InferVStreams(ng, in_p, out_p) as pipeline:
                    while True:
                        frame = get_frame()
                        if frame is None:
                            break
                        h, w = frame.shape[:2]

                        raw = pipeline.infer({in_name: preprocess(frame)})

                        if debug and t0 is None:
                            print("HEF outputs (name: shape):")
                            for name, tensor in raw.items():
                                print(f"  {name}: {tensor.shape}")

                        detections, proto = decode(raw)
                        class_masks = build_class_masks(detections, proto)
                        class_masks = memory.update(class_masks)          # temporal
                        lane_lines = extract_lane_lines(class_masks, w, h)  # geometry (stable output)
                        # EXPERIMENTAL starter signal, NOT final control — see
                        # compute_steering() docstring. Build the real controller
                        # on `lane_lines`, not on this helper.
                        steering = compute_steering(lane_lines, w, h)

                        # ───────────────────────────────────────────────────────
                        # TODO: real control plugs in here. `steering` is only a
                        # starter; the controller still has to decide the corridor,
                        # single-lane behavior, stale-detection handling, etc.
                        #   if steering is not None:
                        #       target_x, err = steering
                        #       set_servo(err)            # motor/servo here
                        # ───────────────────────────────────────────────────────

                        if debug:
                            vis = draw_debug(frame.copy(), class_masks, lane_lines, steering)
                            if record_path:
                                if writer is None:
                                    writer = cv2.VideoWriter(record_path,
                                        cv2.VideoWriter_fourcc(*"XVID"), 30, (w, h))
                                writer.write(vis)

                        if t0 is None:
                            t0, n = time.perf_counter(), 0
                            continue
                        n += 1
                        if n % REPORT_EVERY == 0:
                            fps = n / (time.perf_counter() - t0)
                            err = f"{steering[1]:+.2f}" if steering else "  --"
                            print(f"[{n:5d}] {fps:5.1f} FPS | lanes={len(lane_lines)} | steer_err={err}")
    except KeyboardInterrupt:
        print("\nStopping...")
    finally:
        if writer:
            writer.release(); print(f"Saved: {record_path}")
        release()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", default=None, help="video file (omit for CSI camera)")
    ap.add_argument("--debug", action="store_true", help="draw masks/lines + show overlay")
    ap.add_argument("--record", default=None, help="(requires --debug) save annotated .avi")
    args = ap.parse_args()
    if args.record and not args.debug:
        ap.error("--record requires --debug")
    main(args.source, args.debug, args.record)
