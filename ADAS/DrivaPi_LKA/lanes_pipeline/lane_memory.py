import numpy as np

TEMPORAL_MAX_AGE = 6
NUM_CLASSES = 5

class LaneMemory:
    def __init__(self, max_age=TEMPORAL_MAX_AGE, alpha=0.35):
        self.max_age = max_age
        self.alpha = alpha  # Smoothing factor for Exponential Moving Average
        self.store = {}     # Stores: {class_id: [poly_coeffs, age, confidence]}

    def fit_poly(self, mask):
        """Extracts points from mask and fits a quadratic polynomial: x = a*y^2 + b*y + c"""
        y_indices, x_indices = np.where(mask > 0)
        if len(x_indices) < 30:  # Noise threshold
            return None
        return np.polyfit(y_indices, x_indices, deg=2)

    def update(self, class_masks):
        """
        Input: dict of {class_id: binary_mask}
        Output: dict of {class_id: poly_coefficients}
        """
        out_polys = {}

        for c in range(NUM_CLASSES):
            curr_mask = class_masks.get(c)
            curr_poly = self.fit_poly(curr_mask) if curr_mask is not None else None

            if curr_poly is not None:
                # Fresh detection in current frame
                if c in self.store:
                    # Smooth polynomial coefficients with previous state (EMA)
                    prev_poly, _, _ = self.store[c]
                    smoothed_poly = self.alpha * curr_poly + (1 - self.alpha) * prev_poly
                else:
                    smoothed_poly = curr_poly

                self.store[c] = [smoothed_poly, 0, 1.0]
                out_polys[c] = smoothed_poly

            elif c in self.store:
                # Dashed line gap: decay confidence & hold polynomial
                poly, age, conf = self.store[c]
                age += 1
                conf *= 0.85

                if age < self.max_age:
                    self.store[c] = [poly, age, conf]
                    out_polys[c] = poly  # Reuse previous fit
                else:
                    del self.store[c]  # Expire stale lane

        return out_polys