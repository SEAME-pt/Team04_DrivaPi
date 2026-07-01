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
        yy = np.linspace(ys.min(), ys.max(), 40)
        xx = np.polyval(coeffs, yy)
        pts = np.stack((xx, yy), axis=1)
    else:
        pts = np.stack((xs, ys), axis=1)

    return [pts]


def draw_debug(frame, class_masks, lane_lines, steering):
    h, w = frame.shape[:2]
    # Draw unified tracked lane boundaries
    for name, lines in lane_lines.items():
        c = (0, 255, 0) if "left" in name else (0, 0, 255) # Green for Left, Red for Right
        for pts in lines:
            cv2.polylines(frame, [pts.astype(np.int32)], False, c, LINE_THICK, cv2.LINE_AA)
            
    if steering is not None:
        target_x, err = steering
        y = int(0.85 * h)
        cv2.line(frame, (w // 2, y), (int(target_x), y), (255, 255, 255), 2)
        cv2.circle(frame, (int(target_x), y), 7, (255, 255, 255), -1)
        cv2.putText(frame, f"err={err:+.2f}", (10, 56),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
    return frame

# --- The rest of your decode, sort_outputs, and build_class_masks functions remain unchanged ---
