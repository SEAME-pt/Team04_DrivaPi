
import numpy as np

class StanleyController:
    def __init__(self):
        self.prev_center_x = None

    def compute_stanley_errors(self, lane_lines, w, h):
        lookahead = 0.15 * h

        near_row = 0.95 * h
        far_row = near_row - lookahead

        lane_candidates = []

        for lines in lane_lines.values():
            for pts in lines:
                ys = pts[:, 1]
                order = np.argsort(ys)

                lane_candidates.append({
                    "near": float(np.interp(near_row, ys[order], pts[order, 0])),
                    "far": float(np.interp(far_row, ys[order], pts[order, 0]))
                })

        if not lane_candidates:
            print("None from lane_candidates")
            return None

        filtered = []
        for c in lane_candidates:
            dx = abs(c["far"] - c["near"])

            # reject flat/broken/noisy detections
            # reject extremely wide jumps (often opposite lane)
            if 2 < dx < 1000:
                filtered.append(c)

        if not filtered:
            print("None from filtered")
            return None

        image_center = w / 2

        left_candidates = []
        right_candidates = []

        for c in filtered:
            if c["near"] < image_center:
                left_candidates.append(c)
            else:
                right_candidates.append(c)

        if left_candidates and right_candidates:
            left = min(left_candidates, key=lambda c: abs(c["near"] - image_center))
            right = min(right_candidates, key=lambda c: abs(c["near"] - image_center))

            lane_center_near_x = (left["near"] + right["near"]) / 2
            lane_center_far_x  = (left["far"] + right["far"]) / 2

        elif left_candidates:
            lane = min(left_candidates, key=lambda c: c["near"])

            if self.prev_center_x is not None:
                lane_center_near_x = (lane["near"] + self.prev_center_x) / 2
                lane_center_far_x  = (lane["far"] + self.prev_center_x) / 2
            else:
                lane_center_near_x = lane["near"] + (w - lane["near"]) * 0.5
                lane_center_far_x  = lane["far"] + (w - lane["far"]) * 0.5

        elif right_candidates:
            lane = min(right_candidates, key=lambda c: c["near"])

            if self.prev_center_x is not None:
                lane_center_near_x = (lane["near"] + self.prev_center_x) / 2
                lane_center_far_x  = (lane["far"] + self.prev_center_x) / 2
            else:
                lane_center_near_x = lane["near"] * 0.5
                lane_center_far_x  = lane["far"] * 0.5

        else:
            print("None from lanes")
            return None


        cte = (lane_center_near_x - (w / 2)) / (w / 2)

        lane_dx = lane_center_far_x - lane_center_near_x
        lane_dy = far_row - near_row

        heading_error = np.arctan2(lane_dx, lane_dy)

        self.prev_center_x = lane_center_near_x
        return cte, float(heading_error)
