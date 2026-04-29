# Stanley Controller Implementation Guide (DrivaPi / Team04)

## Objective

Integrate the **Stanley lateral controller** into the existing architecture with:

- **High-level control** on Raspberry Pi (`rust/controller`)
- **Low-level actuation** on STM32 firmware (`firmware/Core`)
- Existing CAN IDs for speed (`CMD_SPEED=44`) and steering (`CMD_STEERING=45`)

This keeps firmware as actuator backend and places path tracking logic in the Rust controller.

**Scope rule:** In autonomous mode, Stanley is used for **steering only** (lateral control).  
Speed/throttle must be handled by a separate longitudinal policy/controller.

**Available sensors for this project:**
- **Camera vision** (primary/only lateral perception source)
- **Speed sensor** (vehicle speed \(v\))
- **Ultrasonic** (obstacle safety layer, not lane tracking)

---

## 1. Where Stanley Must Run

Stanley should run in:

- `rust/controller/src/main.rs` (new autonomous mode loop)
- `rust/controller/src/stanley.rs` (new controller module)

Firmware remains unchanged in responsibilities:

- `can_rx.c`: receives `CMD_SPEED` and `CMD_STEERING`
- `dc_motor.c`: applies speed command
- `servo_motor.c`: applies steering command

---

## 2. Required Rust Data Structures

Create `rust/controller/src/stanley.rs`:

```rust
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
```

---

## 3. Stanley Control Law (Exact)

For this project, compute Stanley using **camera-derived errors** (`cross_track_error_m`, `heading_error_rad`) plus speed sensor input.

At each control tick:

1. Compute **front axle position**:

```text
x_f = x + wheelbase_m * cos(yaw)
y_f = y + wheelbase_m * sin(yaw)
```

2. Find nearest path point to `(x_f, y_f)` (search from `last_idx` forward window, not full path every tick).  
   If operating lane-only (no global map), skip this step and use camera-provided errors directly.

3. Compute errors:

- Heading error:

```text
heading_error = normalize_angle(path[idx].yaw_rad - yaw)
```

- Signed cross-track error:

Use path tangent vector `t = [cos(path_yaw), sin(path_yaw)]` and vector from path point to front axle `e = [x_f - x_path, y_f - y_path]`.

```text
cross_track_error = sign(t_x * e_y - t_y * e_x) * ||e||
```

4. Compute steering:

```text
delta = heading_error + atan2(k * cross_track_error, speed_mps + k_soft)
```

5. Clamp:

```text
delta = clamp(delta, -max_steer_rad, +max_steer_rad)
```

6. Rate-limit:

```text
delta = clamp(delta, prev_delta - max_step, prev_delta + max_step)
max_step = max_steer_rate * dt
```

---

## 4. Integration in `main.rs` (Camera-Based Autonomous Steering)

Add an autonomous loop, e.g.:

- `run_autonomous_mode(...)`
- Tick period: **25 ms** (40 Hz) or **50 ms** (20 Hz)

Per loop iteration:

1. Read latest camera output:
   - lane center offset -> `cross_track_error_m`
   - lane direction -> `heading_error_rad`
   - confidence/valid flag
2. Read speed sensor value `v`.
3. Compute Stanley steering:
   - `delta = heading_error + atan2(k * cross_track_error, v + k_soft)`
4. Convert steering rad -> servo degrees.
5. Compute target speed from a separate longitudinal policy/controller.
6. Send CAN speed and steering commands.
7. If camera confidence is low/invalid: center steering + safe stop command.

Keep manual mode unchanged and add a mode switch (button or config flag).

---

## 5. Steering-to-Servo Mapping (PiRacer-Specific)

Current firmware servo center and range:

- Center: `90°`
- Limits: `75° .. 105°`

Use:

```text
servo_deg = 90.0 + STEER_TO_SERVO_GAIN * delta_rad
servo_deg = clamp(servo_deg, 75.0, 105.0)
```

Calibration procedure:

1. Start with small gain
2. Run low speed straight + mild curves
3. Increase gain until tracking is responsive without oscillation
4. Keep saturation rare during nominal turns

---

## 6. Longitudinal Speed Policy (Separate from Stanley)

Do not run fixed speed while tuning.

Stanley does **not** compute speed; it only outputs steering.

Use curvature/error-aware speed:

```text
v_target = v_max - k_curv * abs(curvature)
v_target = min(v_target, v_max)
v_target = max(v_target, v_min)
if abs(cross_track_error) > e_slowdown_threshold: reduce further
```

Practical starting bounds:

- `v_min = 0.4 m/s`
- `v_max = 1.2 m/s` (raise later)

---

## 7. Initial Parameters for First Track Tests

Start with:

- `k = 1.0`
- `k_soft = 1.0`
- `wheelbase_m = <measured PiRacer wheelbase>`
- `max_steer_rad = 0.30`
- `max_steer_rate = 1.5 rad/s`
- `dt = 0.025 s`

Tune in this order:

1. `STEER_TO_SERVO_GAIN`
2. `k`
3. `k_soft`
4. speed profile (`v_min/v_max/k_curv`)

---

## 8. Safety and Robustness Requirements

Implement the following fail-safes in autonomous mode:

- If localization is stale/invalid: send brake and center steering
- If camera lane detection is stale/invalid/low-confidence: send brake and center steering
- If path is empty or finished: send brake and center steering
- Keep target index monotonic (avoid jumping backwards due to noise)
- Add small steering deadband near center (reduce servo chatter)
- Timeout CAN publishing watchdog at control-loop level

---

## 9. Inputs Needed Before First Complete Run

You must define:

1. **Camera lane output definition** (how offset and heading are computed, units/sign)
2. **Path source strategy**:
   - lane-center from camera each frame (no fixed map), or
   - pre-defined path fused with camera corrections
3. **Measured wheelbase**
4. **Steer-to-servo calibration gain**
5. **Common steering payload type across Rust + firmware**

---

## 10. Minimal Rust API Shape

Suggested function signatures:

```rust
pub fn compute_steering(
    state: VehicleState,
    path: &[PathPoint],
    last_idx: usize,
    prev_delta: f64,
    dt: f64,
    cfg: StanleyConfig,
) -> Option<(f64, usize)>;
```

```rust
pub fn steering_to_servo_deg(delta_rad: f64, gain: f64) -> f64;
```

```rust
pub fn compute_target_speed(curvature: f64, cte: f64, v_min: f64, v_max: f64) -> f64;
```

---

## 11. Execution Plan (Concrete)

1. Add `stanley.rs` with math helpers and controller core.
2. Add path loader (`path_io.rs`) and parse waypoints at startup.
3. Add camera adapter interface (`camera_lane.rs`) returning cross-track/heading error + confidence.
4. Add `run_autonomous_mode()` to `main.rs` at fixed rate.
5. Reuse existing CAN sender with autonomous speed/steer outputs.
6. Add logging (idx, cte, heading_error, delta, speed_target).
7. Test low speed on simple oval/figure-8 path.
8. Tune gains and servo mapping.

---

## Notes

- The architecture already separates high-level and low-level concerns correctly for Stanley.
- The most critical practical effort is **steering calibration and localization quality**, not the Stanley formula itself.
