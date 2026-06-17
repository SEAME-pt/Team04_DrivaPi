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
    pub cross_track_error_m: f64,   // camera-derived lateral offset
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
}

/// Normalizes an angle to the range [-PI, PI]
fn normalize_angle(angle: f64) -> f64 {
    let mut a = angle;
    while a > std::f64::consts::PI {
        a -= 2.0 * std::f64::consts::PI;
    }
    while a < -std::f64::consts::PI {
        a += 2.0 * std::f64::consts::PI;
    }
    a
}

/// Computes steering angle using Stanley Controller
pub fn compute_steering(
    observation: &CameraLaneObservation,
    speed_mps: f64,
    prev_delta: f64,
    dt: f64,
    cfg: &StanleyConfig,
) -> f64 {
    // Stanley control law:
    // delta = heading_error + atan2(k * cross_track_error, speed_mps + k_soft)
    
    let steering_raw = observation.heading_error_rad 
        + (cfg.k * observation.cross_track_error_m).atan2(speed_mps + cfg.k_soft);

    // Clamp steering
    let mut delta = steering_raw.clamp(-cfg.max_steer_rad, cfg.max_steer_rad);

    // Rate-limit
    let max_step = cfg.max_steer_rate * dt;
    delta = delta.clamp(prev_delta - max_step, prev_delta + max_step);

    delta
}

/// Converts steering radians to servo degrees
pub fn steering_to_servo_deg(delta_rad: f64, gain: f64, center_deg: f64) -> f64 {
    (center_deg + gain * delta_rad).clamp(0.0, 180.0)
}
