
import numpy as np

class StanleyController:
    def __init__(self):
        self.prev_center_x = None

    def compute_stanley_errors(self, lane_lines, w, h):
        # lookahead = 0.15 * h

        near_row = 0.90 * h
        far_row = 0.50 * h

        lane_candidates = []

        for lines in lane_lines.values():
            for pts in lines:
                ys = pts[:, 1]
                xs = pts[:, 0]
                order = np.argsort(ys)

                y_sorted = ys[order]
                x_sorted = xs[order]

                lane_candidates.append({
                    "near": float(np.interp(near_row, y_sorted,x_sorted)),
                    "far": float(np.interp(far_row, y_sorted,x_sorted))
                })

        if not lane_candidates:
            print("None from lane_candidates")
            return None


        filtered = []
        y_diff = far_row - near_row
        for c in lane_candidates:
            dx = c["far"] - c["near"]
            slope = dx / y_diff

            if abs(slope) < 0.001:
                continue

            print(
                    f'near={c["near"]:.1f} '
                    f'far={c["far"]:.1f} '
                    f'dx={dx:.1f}'
                )
            filtered.append(c)

            # reject flat/broken/noisy detections
            # reject extremely wide jumps (often opposite lane)
            # if 2 < dx < 1000:
            #     filtered.append(c)

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

            def score(c):
                return abs(c["near"] - image_center)


            left = min(left_candidates, key=score)
            right = min(right_candidates, key=score)

            lane_center_near_x = (left["near"] + right["near"]) / 2
            lane_center_far_x  = (left["far"] + right["far"]) / 2

        elif left_candidates:
            lane = min(left_candidates, key=lambda c: c["near"])

            if self.prev_center_x is not None:
                alpha = 0.7
                lane_center_near_x = alpha * lane["near"] + (1 -alpha) * self.prev_center_x
                lane_center_far_x  = alpha * lane["far"] + (1 -alpha) * self.prev_center_x
            else:
                lane_center_near_x = lane["near"] + (w - lane["near"]) * 0.5
                lane_center_far_x  = lane["far"] + (w - lane["far"]) * 0.5

        elif right_candidates:
            lane = min(right_candidates, key=lambda c: c["near"])

            if self.prev_center_x is not None:
                alpha = 0.7
                lane_center_near_x = alpha * lane["near"] + (1 -alpha) * self.prev_center_x
                lane_center_far_x  = alpha * lane["far"] + (1 -alpha) * self.prev_center_x
            else:
                lane_center_near_x = lane["near"] * 0.5
                lane_center_far_x  = lane["far"] * 0.5

        else:
            print("None from lanes")
            return None


        cte = (lane_center_near_x - image_center) / image_center

        lane_dx = lane_center_far_x - lane_center_near_x
        lane_dy = far_row - near_row

        heading_error = np.arctan2(lane_dx, -lane_dy)

        self.prev_center_x = lane_center_near_x
        return cte, float(heading_error)
