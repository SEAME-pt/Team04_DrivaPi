
import numpy as np

class StanleyController:
    def __init__(self):
        self.prev_center_x = None

    def compute_stanley_errors(self, lane_lines, w, h):
        # lookahead = 0.15 * h

        all_y = []

        for lines in lane_lines.values():
            for pts in lines:
                all_y.extend(pts[:, 1])

        if not all_y:
            print("No lane points")
            return None

        max_lane_y = max(all_y)
        min_lane_y = min(all_y)

        print("max_lane_y =", max_lane_y)
        print("min_lane_y =", min_lane_y)

        near_row = max_lane_y
        far_row = min_lane_y + 0.5 * (max_lane_y - min_lane_y)
        
        lane_candidates = []

        for lines in lane_lines.values():
            for pts in lines:
                ys = pts[:, 1]
                xs = pts[:, 0]
                order = np.argsort(ys)

                y_sorted = ys[order]
                x_sorted = xs[order]

                print(
                    f"lane y range = {y_sorted.min():.1f} -> {y_sorted.max():.1f}"
                )
                
                near_x = float(np.interp(near_row, y_sorted,x_sorted))
                far_x = float(np.interp(far_row, y_sorted,x_sorted))

                lane_candidates.append((near_x, far_x))

        if not lane_candidates:
            print("None from lane_candidates")
            return None

        print("frame h =", h)
        print("lane y max =", max_lane_y)

        filtered = []
        y_diff = far_row - near_row
        for near_x, far_x in lane_candidates:
            dx = far_x - near_x
            slope = dx / y_diff

            print(
                f'near={near_x:.6f} '
                f'far={far_x:.6f} '
                f'dx={dx:.6f} '
                f'slope={slope:.6f}'
            )
            if abs(dx) < 2.0 and abs(slope) < 0.01:
                continue

            filtered.append((near_x, far_x))


        if not filtered:
            print("None from filtered")
            return None


        image_center = w / 2

        left_candidates = []
        right_candidates = []



        for near_x, far_x in filtered:
            if near_x < image_center:
                left_candidates.append((near_x, far_x))
            else:
                right_candidates.append((near_x, far_x))

        def score(x):
            return abs(x - image_center)


        if left_candidates and right_candidates:

            left  = min(left_candidates, key=lambda x: score(x[0]))
            right = min(right_candidates, key=lambda x: score(x[0]))

            lane_center_near_x = (left[0] + right[0]) * 0.5
            lane_center_far_x  = (left[1] + right[1]) * 0.5

        elif left_candidates:
            lane = min(left_candidates, key=lambda x: x[0])

            if self.prev_center_x is not None:
                alpha = 0.8
                lane_center_near_x = alpha * lane[0] + (1 - alpha) * self.prev_center_x
                lane_center_far_x  = alpha * lane[1] + (1 - alpha) * self.prev_center_x
            else:
                lane_center_near_x = lane[0] + (w - lane[0]) * 0.5
                lane_center_far_x  = lane[1] + (w - lane[1]) * 0.5

        elif right_candidates:
            lane = min(right_candidates, key=lambda x: x[0])

            if self.prev_center_x is not None:
                alpha = 0.8
                lane_center_near_x = alpha * lane[0] + (1 - alpha) * self.prev_center_x
                lane_center_far_x  = alpha * lane[1] + (1 - alpha) * self.prev_center_x
            else:
                lane_center_near_x = lane[0] * 0.5
                lane_center_far_x  = lane[1] * 0.5

        else:
            print("None from lanes")
            return None


        cte = (lane_center_near_x - image_center) / image_center

        lane_dx = lane_center_far_x - lane_center_near_x
        lane_dy = far_row - near_row

        heading_error = np.arctan2(lane_dx, -lane_dy)

        self.prev_center_x = lane_center_near_x
        return cte, float(heading_error)
