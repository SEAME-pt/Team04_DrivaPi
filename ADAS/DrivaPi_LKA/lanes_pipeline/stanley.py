
import numpy as np
import math

class StanleyController:
    def __init__(self):
        self.prev_center_x = None

    def compute_stanley_errors(self, lane_lines, w, h):

        image_center = w / 2

        camera_heading = np.pi / 2
        near_row = 0.95 * h   # bottom of road (closest to car)
        far_row  = 0.70 * h   # mid-road (lookahead)
        #print(f"near_row = {near_row} far_row = {far_row} height = {h}")
        all_y = []

        for lines in lane_lines.values():
            for pts in lines:
                all_y.extend(pts[:, 1])

        if not all_y:
            print("No lane points")
            return None

        max_lane_y = max(all_y)
        min_lane_y = min(all_y)


        lane_candidates = []

        for lines in lane_lines.values():
            for pts in lines:
                ys = pts[:, 1]
                xs = pts[:, 0]

                order = np.argsort(ys)

                y_sorted = ys[order]
                x_sorted = xs[order]

                near_x = float(np.interp(near_row, y_sorted,x_sorted))
                far_x = float(np.interp(far_row, y_sorted,x_sorted))

                
                lane_candidates.append((near_x, far_x))

        if not lane_candidates:
            print("None from lane_candidates")
            return None


        filtered = []
        y_diff = far_row - near_row
        for near_x, far_x in lane_candidates:

            dx = far_x - near_x
            slope = dx / y_diff

            if abs(dx) < 1.5:
                continue

            filtered.append((near_x, far_x))


        if not filtered:
            print("None from filtered")
            return None



        left_candidates = []
        right_candidates = []

        for near_x, far_x in filtered:

            dx = far_x - near_x

            if near_x < (image_center - 40) or (near_x < image_center and dx > -5):
                left_candidates.append((near_x, far_x))
            elif near_x > (image_center + 40) or (near_x >= image_center and dx < 5):
                right_candidates.append((near_x, far_x))
            else:
                if near_x < image_center:
                    left_candidates.append((near_x, far_x))
                else:
                    right_candidates.append((near_x, far_x))




        global_dx = 0
        if filtered:
            global_dx = np.mean([far_x - near_x for near_x, far_x in filtered])


        

        def score(x):
            return abs(x - image_center)



        if left_candidates and right_candidates:

            left  = min(left_candidates, key=lambda x: score(x[0]))
            right = min(right_candidates, key=lambda x: score(x[0]))

            lane_center_near_x = (left[0] + right[0]) * 0.5
            lane_center_far_x  = (left[1] + right[1]) * 0.5


        elif len(filtered) == 1:
            near_x, far_x = filtered[0]
        
            lane_center_near_x = near_x
            lane_center_far_x = far_x


            left_bound_x = -9999.0
            right_bound_x = 9999.0

            for lines in lane_lines.values():
                for pts in lines:
                    for pt_x, pt_y in pts:
                        if pt_y > 0.60 * h:
                            if pt_x < image_center and pt_x > left_bound_x:
                                left_bound_x = pt_x  # Closest obstacle on the left
                            elif pt_x >= image_center and pt_x < right_bound_x:
                                right_bound_x = pt_x # Closest obstacle on the right

            is_right_line = near_x >= image_center or (filtered[0] in right_candidates and filtered[0] not in left_candidates)

            if is_right_line:
                if left_bound_x > -9999.0:
                    lane_center_near_x = (left_bound_x + near_x) * 0.5
                    shift_offset = near_x - lane_center_near_x
                    lane_center_far_x = far_x - shift_offset
                elif self.prev_center_x is not None:
                    # Dynamically reuse the last lane offset distance instead of a hardcoded 110px
                    dynamic_offset = max(60.0, min(160.0, abs(near_x - self.prev_center_x)))
                    lane_center_near_x = near_x - dynamic_offset
                    lane_center_far_x  = far_x - (dynamic_offset * 0.6)
                else:
                    lane_center_near_x = near_x - 120.0
                    lane_center_far_x  = far_x - 70.0
            else:
                if right_bound_x < 9999.0:
                    lane_center_near_x = (near_x + right_bound_x) * 0.5
                    shift_offset = lane_center_near_x - near_x
                    lane_center_far_x = far_x + shift_offset
                elif self.prev_center_x is not None:
                    dynamic_offset = max(60.0, min(160.0, abs(self.prev_center_x - near_x)))
                    lane_center_near_x = near_x + dynamic_offset
                    lane_center_far_x  = far_x + (dynamic_offset * 0.6)
                else:
                    lane_center_near_x = near_x + 120.0
                    lane_center_far_x  = far_x + 70.0


        else:
            print("None from lanes")
            return None

        closes_front_point_y = lane_center_near_x - image_center

        lane_dx = lane_center_far_x - lane_center_near_x
        lane_dy = near_row - far_row

        path_heading = math.atan2(-lane_dx, lane_dy)
        if math.isnan(path_heading) or math.isinf(path_heading):
            path_heading = 0.0

        self.prev_center_x = lane_center_near_x
        return closes_front_point_y, float(path_heading)
