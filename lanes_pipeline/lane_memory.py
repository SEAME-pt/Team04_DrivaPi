import numpy as np

TEMPORAL_MAX_AGE = 8
NUM_CLASSES = 5

class LaneMemory:
    def __init__(self, max_age=TEMPORAL_MAX_AGE):
        self.max_age = max_age
        self.store = {}
        self.learned_lane_width_px = None

    def mask_to_poly(self, mask):
        y_indices, x_indices = np.where(mask > 0)
        if len(y_indices) < 30:
            return None
        return np.polyfit(y_indices, x_indices, 2)

    def poly_to_mask(self, poly, shape):
        mask = np.zeros(shape, dtype=np.uint8)
        if poly is None:
            return mask

        h, w = shape
        # Extrapolate completely from top (0) to bottom (h - 1) of the image frame
        y_vals = np.linspace(0, h - 1, h)
        x_vals = np.polyval(poly, y_vals)

        valid_idx = (x_vals >= 0) & (x_vals < w)
        y_pts = y_vals[valid_idx].astype(np.int32)
        x_pts = x_vals[valid_idx].astype(np.int32)

        mask[y_pts, x_pts] = 255
        return mask

    def update(self, class_masks, image_shape=None):
        out_masks = {}

        if image_shape is None:
            for mask in class_masks.values():
                if mask is not None and hasattr(mask, 'shape'):
                    image_shape = mask.shape[:2]
                    break
        
        if image_shape is None:
            image_shape = (160, 160)

        # 1. Update memory store with new detections
        for c in range(NUM_CLASSES):
            if c in class_masks and np.any(class_masks[c]):
                poly = self.mask_to_poly(class_masks[c])
                if poly is not None:
                    self.store[c] = {"poly": poly, "age": 0, "conf": 1.0}
                    out_masks[c] = class_masks[c]
                    continue

            # Fallback to temporal memory (renders extended line down frame)
            if c in self.store:
                data = self.store[c]
                data["age"] += 1
                data["conf"] *= 0.85

                if data["age"] < self.max_age:
                    out_masks[c] = self.poly_to_mask(data["poly"], image_shape)
                else:
                    del self.store[c]

        # 2. Dynamically learn lane width when BOTH lines are fresh
        LEFT_CLASS, RIGHT_CLASS = 1, 2
        if LEFT_CLASS in self.store and RIGHT_CLASS in self.store:
            if self.store[LEFT_CLASS]["age"] == 0 and self.store[RIGHT_CLASS]["age"] == 0:
                # Measure width near bottom of frame
                eval_y = image_shape[0] * 0.95
                left_x = np.polyval(self.store[LEFT_CLASS]["poly"], eval_y)
                right_x = np.polyval(self.store[RIGHT_CLASS]["poly"], eval_y)
                self.learned_lane_width_px = abs(right_x - left_x)

        # 3. Synthesize missing lane using learned width
        if self.learned_lane_width_px is not None:
            if LEFT_CLASS in self.store and RIGHT_CLASS not in self.store:
                synth_poly = self.store[LEFT_CLASS]["poly"].copy()
                synth_poly[2] += self.learned_lane_width_px
                out_masks[RIGHT_CLASS] = self.poly_to_mask(synth_poly, image_shape)

            elif RIGHT_CLASS in self.store and LEFT_CLASS not in self.store:
                synth_poly = self.store[RIGHT_CLASS]["poly"].copy()
                synth_poly[2] -= self.learned_lane_width_px
                out_masks[LEFT_CLASS] = self.poly_to_mask(synth_poly, image_shape)

        return out_masks
