import numpy as np

TEMPORAL_MAX_AGE = 8
NUM_CLASSES = 5

class LaneMemory:
    """
    Stores 2D binary masks across frames to bridge dashed line gaps
    while remaining fully compatible with extract_lane_lines().
    """
    def __init__(self, max_age=TEMPORAL_MAX_AGE):
        self.max_age = max_age
        self.store = {}  # {class_id: [mask, age]}

    def update(self, class_masks):
        """
        Input: dict of {class_id: binary_mask_array}
        Output: dict of {class_id: binary_mask_array (uint8)}
        """
        out = {}

        for c in range(NUM_CLASSES):
            curr_mask = class_masks.get(c)

            # 1. Fresh detection present in current frame
            if curr_mask is not None and np.any(curr_mask > 0):
                mask_uint8 = curr_mask.astype(np.uint8)
                self.store[c] = [mask_uint8, 0]
                out[c] = mask_uint8

            # 2. Dashed line gap (missed detection): Hold previous mask temporarily
            elif c in self.store:
                mask_uint8, age = self.store[c]
                age += 1

                if age <= self.max_age:
                    self.store[c] = [mask_uint8, age]
                    out[c] = mask_uint8  # Bridge the gap
                else:
                    del self.store[c]    # Expire stale lane

        return out