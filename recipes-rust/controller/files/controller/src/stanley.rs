#[derive(Debug, Clone, Copy)]
pub struct VehicleState {
    pub x: f64,          // optional global x (if available)
    pub y: f64,          // optional global y (if available)
    pub yaw_rad: f64,    // optional global yaw (if available)
    pub speed_mps: f64,  // signed or forward speed
}

#[derive(Debug, Clone, Copy)]
pub struct PathPoint {
    pub x: f64,          // meters
    pub y: f64,          // meters
    pub yaw_rad: f64,    // tangent heading at this waypoint
    pub curvature: f64,  // optional, for speed profiling
}

#[derive(Debug, Clone, Copy)]
pub struct CameraLaneObservation {
    pub closest_front_point_m: f64,   // camera-derived lateral offset
    pub heading_error_rad: f64,     // camera-derived lane heading error
    pub confidence: f64,            // 0.0..1.0 detection confidence
}

#[derive(Debug, Clone, Copy)]
pub struct StanleyConfig {
    pub k: f64,               // cross-track gain
    pub k_soft: f64,          // softening gain for low speed
    pub wheelbase_m: f64,     // real wheelbase
    pub max_steer_rad: f64,   // steering clamp
    pub max_steer_rate: f64,  // rad/s
    pub steer_to_servo_gain: f64,
}

impl Default for StanleyConfig {
    fn default() -> Self {
        Self {
            k: 0.002,
            k_soft: 0.4,
            wheelbase_m: 0.15,
            max_steer_rad: 0.8,
            max_steer_rate: 2.0,
            steer_to_servo_gain: 60.0,
        }
    }
}

/// Normalizes an angle to the range [-PI, PI]
pub fn normalize_heading(heading: f64) -> f64 {
    let mut h = (heading + std::f64::consts::PI) % (2.0 * std::f64::consts::PI);
    if h < 0.0 {
        h += 2.0 * std::f64::consts::PI;
    }
    h - std::f64::consts::PI
}

/// Computes steering angle using Stanley Controller
pub fn compute_steering(
    observation: &CameraLaneObservation,
    speed_mps: f64,
    prev_delta: f64,
    dt: f64,
    cfg: &StanleyConfig,
) -> f64 {
    let crosstrack_error = (cfg.k * observation.closest_front_point_m).atan2(speed_mps);

    let angle_raw = observation.heading_error_rad + crosstrack_error;

    let angle = angle_raw.clamp(-cfg.max_steer_rad, cfg.max_steer_rad);

    println!(
        "[STANLEY] cte={:.4} heading={:.6} angle={:.4}",
        crosstrack_error,
        observation.heading_error_rad,
        angle
    );
    angle
}

/// Converts steering radians to servo degrees
pub fn steering_to_servo_deg(angle: f64, cfg: &StanleyConfig) -> f64 {
     (90.0 - cfg.steer_to_servo_gain * angle).clamp(0.0, 180.0)
}
