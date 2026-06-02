"""Hailo inference configuration for DrivaPi obstacle detection."""

from pathlib import Path


class HailoConfig:
    """Configuration constants for Hailo inference and control tuning."""

    CLASSES = [
        '50_sign', '80_sign', 'gate', 'crosswalk_sign', 'stop_sign', 
        'yield_sign', 'car', 'danger_sign', 'obstacle', 
        'traffic_light_green', 'traffic_light_off', 'traffic_light_red', 'traffic_light_yellow'
    ]
    
    UDP_IP = "127.0.0.1"
    UDP_PORT = 5555
    HEF_PATH = Path("yolo26_obstacle.hef")

    # VStream names for the current stable model.
    OUT_SLICE1 = "yolo26_v9/slice1"
    OUT_SLICE2 = "yolo26_v9/slice2"
    OUT_ACT3   = "yolo26_v9/activation3"

    # ========================================================
    # CALIBRATION ADAPTED FOR HIGH DYNAMICS
    # ========================================================
    PWM_MAX = 40        # Absolute ceiling.
    PWM_80 = 30         # Speed limit for the 80 sign.
    PWM_50 = 20         # Speed limit for the 50 sign.
    PWM_CRUISE = 15     # Default speed on clear track.
    PWM_SLOW = 10       # Base speed for stop approaches.
    PWM_CAUTION = 12    # Default speed limit in pedestrian zones.
    
    UDP_INTERVAL = 0.05 
    H_EMERGENCY = 0.35
    H_STOP = 0.12       # Optimal optical blackout point measured at 40cm.
    
    FORWARD = 1
    BRAKE = 3
    MID_SERVO = 90
