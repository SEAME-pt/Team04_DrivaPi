
import numpy as np

def compute_stanley_errors(lane_lines, w, h):
    # 1. Measure CTE at the front axle (bottom of the image)
    y_axle = 0.95 * h  # Near the bottom where front wheels are
    
    # 2. Measure a secondary point slightly ahead to get the lane's direction
    y_ahead = 0.80 * h 
    
    xs_axle = []
    xs_ahead = []
    
    for lines in lane_lines.values():
        for pts in lines:
            ys = pts[:, 1]
            order = np.argsort(ys)
            
            # Interpolate lane X positions at both rows
            xs_axle.append(float(np.interp(y_axle, ys[order], pts[order, 0])))
            xs_ahead.append(float(np.interp(y_ahead, ys[order], pts[order, 0])))
            
    if not xs_axle or not xs_ahead:
        return None  # Lost the lanes
        
    # Target positions for lane center
    target_x_axle = np.mean(xs_axle)
    target_x_ahead = np.mean(xs_ahead)
    
    # --- CALCULATE STANLEY ERRORS ---
    
    # 1. Cross-Track Error (e) at the front axle
    # (Distance from center of image to center of lane)
    cte = (target_x_axle - (w * 0.5)) / (w * 0.5)
    
    # 2. Heading Error (ψ)
    # Vector of the lane path
    lane_vector_x = target_x_ahead - target_x_axle
    lane_vector_y = -(y_ahead - y_axle)  # Will be a negative value in image space
    
    # Heading error is the angle between the car vector and lane vector
    # atan2(y, x) -> angle of lane relative to image vertical
    heading_error = -np.arctan2(lane_vector_x, lane_vector_y)

    
    return cte, float(heading_error)
