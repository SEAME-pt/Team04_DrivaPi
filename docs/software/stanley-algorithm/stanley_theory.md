# Stanley Algorithm: Theory and Theoretical Implementation

## 1. What the Stanley Algorithm Is

The **Stanley algorithm** is a **lateral path-tracking controller** for ground vehicles.  
Its goal is to compute steering so the car converges to a reference path and follows it with small heading and lateral errors.

It is called a lateral controller because it controls **steering** (left/right motion), not throttle/brake.

---

## 2. Core Idea

Stanley combines two corrections:

1. **Heading correction**: align vehicle orientation with the path tangent.
2. **Cross-track correction**: reduce lateral distance to the path.

These two terms are added to produce the steering command.

---

## 3. State and Path Quantities

Vehicle state (typical):

- \(x, y\): vehicle position in world frame
- \(\psi\): vehicle yaw (heading angle)
- \(v\): longitudinal speed

Reference path:

- sequence of points \((x_i, y_i)\)
- path heading at each point \(\psi_i^{path}\)

For Stanley, error is usually measured at the **front axle point**, not vehicle center:

\[
x_f = x + L \cos(\psi), \quad y_f = y + L \sin(\psi)
\]

where \(L\) is wheelbase.

### Camera-only interpretation for this project

Since your lateral perception is camera-based, the controller can be fed directly with:

- camera-estimated cross-track error \(e_y\)
- camera-estimated heading error \(e_{\psi}\)
- speed sensor value \(v\)

In this mode, global \((x,y,\psi)\) can be optional for Stanley computation.

---

## 4. Error Definitions

### 4.1 Heading Error

\[
e_{\psi} = \text{wrapToPi}\left(\psi_{ref} - \psi\right)
\]

- \(\psi_{ref}\): heading of closest/reference path point
- `wrapToPi`: normalizes angle to \((-\pi, \pi]\)

### 4.2 Cross-Track Error

Let \(e_y\) be signed lateral distance from front axle to path.  
Sign is determined by 2D cross product between path tangent and vector from path point to front axle.

For camera lane tracking, \(e_y\) is obtained from lane center offset (image-to-ground conversion), with sign convention:

- \(e_y > 0\): lane center is to one side of vehicle centerline
- \(e_y < 0\): lane center is to the opposite side

This sign must match steering command convention.

---

## 5. Stanley Steering Law

The classical form:

\[
\delta = e_{\psi} + \arctan\left(\frac{k \, e_y}{v + k_s}\right)
\]

where:

- \(\delta\): steering command (rad)
- \(k > 0\): cross-track gain
- \(k_s > 0\): softening term for low speed robustness

Interpretation:

- First term points car in path direction.
- Second term pulls car laterally toward the path.
- As speed increases, same lateral error yields smaller correction (stability at speed).

---

## 6. Why It Works (Intuition)

If heading is wrong, \(e_{\psi}\) rotates the vehicle toward path tangent.  
If vehicle is offset sideways, \(e_y\)-term steers inward to reduce offset.  
The arctangent saturates naturally, preventing unbounded commands for large errors.

Together, this creates practical, robust convergence in many real driving conditions.

---

## 7. Theoretical Implementation Procedure

At each control step \(t_k\):

1. Get state \((x, y, \psi, v)\).
2. Compute front axle \((x_f, y_f)\).
3. Find nearest/reference path index \(i^\*\) to \((x_f, y_f)\).
4. Compute \(e_{\psi}\) and signed \(e_y\).
5. Compute \(\delta\) using Stanley law.
6. Clamp \(\delta\) to steering limits.
7. (Optional but recommended) apply steering rate limit.
8. Send steering command to actuator.
9. Repeat at fixed frequency.

### Camera-based implementation sequence (no extra localization sensor)

At each tick:

1. Detect lane boundaries/centerline from camera frame.
2. Estimate:
   - \(e_y\): lateral offset to lane center (meters)
   - \(e_{\psi}\): angle between vehicle forward axis and lane tangent (rad)
3. Read speed \(v\) from speed sensor.
4. Compute Stanley steering \(\delta\).
5. Apply saturation/rate limit and send steering.
6. If lane confidence is low: safe fallback (center + slow/stop).

---

## 8. Pseudocode (Theory-Level)

```text
inputs: state(x, y, yaw, v), path[], config(k, ks, wheelbase, delta_max)
memory: last_target_idx, last_delta

front_x = x + wheelbase * cos(yaw)
front_y = y + wheelbase * sin(yaw)

idx = nearest_path_index(front_x, front_y, path, last_target_idx)
ref = path[idx]

heading_error = wrap_to_pi(ref.yaw - yaw)
cross_track_error = signed_lateral_error(front_x, front_y, ref)

delta = heading_error + atan2(k * cross_track_error, v + ks)
delta = clamp(delta, -delta_max, +delta_max)
delta = rate_limit(delta, last_delta)

output steering = delta
last_target_idx = max(last_target_idx, idx)
last_delta = delta
```

---

## 9. Practical Theory Constraints

For theoretical correctness in a real system:

- Use **consistent coordinate frames** everywhere.
- Use **continuous path heading** (no jumps near \(\pm\pi\)).
- Ensure **signed cross-track error** is consistent with steering sign convention.
- Run at fixed control period (deterministic \(dt\)).
- Keep target index monotonic to avoid oscillation due to nearest-point switching.
- Calibrate camera geometry (intrinsics/extrinsics) so pixel offset maps consistently to meters.
- Stabilize lane estimates (temporal filtering) to reduce steering jitter.

---

## 10. Parameter Roles (Theory)

- \(k\): larger -> more aggressive lateral convergence, but can oscillate.
- \(k_s\): larger -> less aggressive at low speed, improves smoothness.
- \(L\): affects front-axle geometry; must match physical vehicle.
- \(\delta_{max}\): physical steering saturation bound.

Typical tuning logic:

1. fix geometry/limits (\(L, \delta_{max}\))
2. tune \(k\)
3. tune \(k_s\) for low-speed behavior

---

## 11. Relationship to Longitudinal Control

Stanley is **only lateral control**.  
A complete autonomous stack also needs a longitudinal controller for speed:

- PID speed control
- curvature-based speed planner
- ACC-like policy

So theoretical architecture is:

- **Lateral:** Stanley \(\rightarrow\) steering
- **Longitudinal:** separate controller \(\rightarrow\) throttle/brake

---

## 12. Known Theoretical Limitations

- Can oscillate at very low speeds without softening term.
- Sensitive to localization and path heading noise.
- Not optimal like MPC for constraints/look-ahead behavior.
- Needs proper actuator saturation and rate limiting in practice.
- With camera-only perception, performance degrades under poor lighting, faded lanes, glare, or occlusions.

Even with these limitations, Stanley remains popular because it is simple, interpretable, and effective.
