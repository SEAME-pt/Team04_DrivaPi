
import cv2
import numpy as np
import math

MODEL_SIZE   = 640
WORK_SIZE    = MODEL_SIZE // 4
# Combined line classes into one universal checking pool (excluding index 2: crosswalk)
LINE_CLASSES = {0, 1, 3, 4}     
FIT_DEGREE, MIN_MASK_PX, MIN_SPAN, DASH_BRIDGE = 2, 6, 10, 13
REG_MAX      = 16
CLASS_NAMES  = ["center_continuous_lane", "center_dashed_lane", "crosswalk",
                "left_lane", "right_lane"]
NUM_CLASSES = 5
CONF_THRESH_PER_CLASS = np.array([0.35, 0.35, 0.45, 0.35, 0.35], dtype=np.float32)
IOU_THRESH  = 0.45
DRAW_MASKS = True
LINE_THICK = 4
CLASS_COLORS = [(0, 165, 255), (0, 255, 255), (255, 255, 0), (0, 255, 0), (0, 0, 255)]


def extract_lane_lines(class_masks, w, h):
    """
    Combines all distinct lane classes into a unified map, then isolates
    ONLY the closest left line and closest right line bounding the current lane.
    """
    mx, my = w / WORK_SIZE, h / WORK_SIZE
    image_center_x = WORK_SIZE / 2  # Center line in processing space (160)

    # 1. Combine all valid lane masks into a single global lane canvas
    unified_lane_mask = np.zeros((WORK_SIZE, WORK_SIZE), dtype=np.uint8)
    for cls_id, mask in class_masks.items():
        if cls_id in LINE_CLASSES:
            np.maximum(unified_lane_mask, mask, out=unified_lane_mask)

    # 2. Slice the unified mask into individual distinct structural lines
    # Using OpenCV connected components to distinguish lines from each other
    num_labels, labels, stats, centroids = cv2.connectedComponentsWithStats(unified_lane_mask)

    left_candidates = []
    right_candidates = []

    for label in range(1, num_labels):
        # Ignore tiny stray noise artifacts
        if stats[label, cv2.CC_STAT_AREA] < MIN_MASK_PX:
            continue

        # Extract the mask specific to this single isolated line entity
        single_line_mask = (labels == label).astype(np.uint8)
        pts = fit_lane_lines(single_line_mask)
        if not pts:
            continue
        
        line_pts = pts[0]
        # Measure where the baseline of this line hits near the bottom of the image
        near_x = line_pts[-1, 0] if line_pts.shape[0] > 0 else centroids[label][0]

        # Categorize line relative to vehicle center axis
        if near_x < image_center_x:
            left_candidates.append((near_x, line_pts))
        else:
            right_candidates.append((near_x, line_pts))

    out = {}
    
    # 3. Lock onto the single closest line on the Left and Right (Ignoring outer lanes)
    if left_candidates:
        # Closest left line has the maximum X value (closest to center line from the left)
        best_left = max(left_candidates, key=lambda item: item[0])[1]
        out["left_lane"] = [best_left * (mx, my)]
        
    if right_candidates:
        # Closest right line has the minimum X value (closest to center line from the right)
        best_right = min(right_candidates, key=lambda item: item[0])[1]
        out["right_lane"] = [best_right * (mx, my)]

    return out
def draw_debug(frame, class_masks, lane_lines, steering):
    h, w = frame.shape[:2]
    # Draw unified tracked lane boundaries
    for name, lines in lane_lines.items():
        c = (0, 255, 0) if "left" in name else (0, 0, 255) # Green for Left, Red for Right
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

def fit_lane_lines(mask):
    ys = []
    xs = []

    for y in range(mask.shape[0]):
        cols = np.where(mask[y] > 0)[0]
        if len(cols) < 2:
            continue
        xs.append(cols.mean())
        ys.append(y)

    if len(xs) < MIN_MASK_PX:
        return []

    xs = np.asarray(xs, dtype=np.float32)
    ys = np.asarray(ys, dtype=np.float32)

    if len(xs) > 8:
        coeffs = np.polyfit(ys, xs, 2)
        yy = np.linspace(ys.min(), mask.shape[0] - 1, 50)
        xx = np.polyval(coeffs, yy)
        pts = np.stack((xx, yy), axis=1)
    else:
        pts = np.stack((xs, ys), axis=1)

    return [pts]

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
    if proto is None or len(cv2_list) != 3:
        return [], None
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


