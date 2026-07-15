use std::collections::VecDeque;

use eframe::egui;
use egui_plot::{Line, Plot, PlotPoints};
use rand::rngs::StdRng;
use rand::{Rng, SeedableRng};

const SIM_DT: f32 = 1.0 / 240.0;
const HISTORY_SECONDS: f32 = 60.0;
const HISTORY_WINDOW_SECONDS: f32 = 10.0;

#[derive(Clone, Copy)]
struct Params {
    kp: f32,
    ki: f32,
    kd: f32,
    kff: f32,
    mass: f32,
    drag: f32,
    loop_delay_ms: f32,
    gyro_noise: f32,
    disturbance: f32,
    integral_limit: f32,
    target_smoothing: f32,
    ff_alpha: f32,
}

impl Default for Params {
    fn default() -> Self {
        Self {
            kp: 7.9,
            ki: 1.75,
            kd: 3.8,
            kff: 1.0,
            mass: 1.0,
            drag: 0.10,
            loop_delay_ms: 15.0,
            gyro_noise: 0.005,
            disturbance: 0.0,
            integral_limit: 200.0,
            target_smoothing: 0.15,
            ff_alpha: 0.15,
        }
    }
}

#[derive(Clone, Copy, PartialEq)]
struct StepParams {
    kp: f32,
    ki: f32,
    kd: f32,
    mass: f32,
    drag: f32,
    loop_delay_ms: f32,
    gyro_noise: f32,
    disturbance: f32,
}

impl From<Params> for StepParams {
    fn from(p: Params) -> Self {
        Self {
            kp: p.kp,
            ki: p.ki,
            kd: p.kd,
            mass: p.mass,
            drag: p.drag,
            loop_delay_ms: p.loop_delay_ms,
            gyro_noise: p.gyro_noise,
            disturbance: p.disturbance,
        }
    }
}

#[derive(Clone, Copy)]
struct Sample {
    t: f32,
    target: f32,
    follower: f32,
    error: f32,
    p_term: f32,
    i_term: f32,
    d_term: f32,
    ff_term: f32,
    noise: f32,
}

struct SimState {
    time: f32,
    target: f32,
    follower: f32,
    velocity: f32,
    integral: f32,
    prev_target: f32,
    prev_follower_noisy: f32,
    prev_clean_follower: f32,
    ff_smooth: f32,
    force_buffer: VecDeque<f32>,
    noise_sum: f32,
    noise_count: u64,
    motor_heat: f32,
}

impl SimState {
    fn new() -> Self {
        Self {
            time: 0.0,
            target: 0.0,
            follower: 0.0,
            velocity: 0.0,
            integral: 0.0,
            prev_target: 0.0,
            prev_follower_noisy: 0.0,
            prev_clean_follower: 0.0,
            ff_smooth: 0.0,
            force_buffer: VecDeque::new(),
            noise_sum: 0.0,
            noise_count: 0,
            motor_heat: 0.0,
        }
    }

    fn reset(&mut self, target: f32) {
        self.time = 0.0;
        self.target = target;
        self.follower = target;
        self.velocity = 0.0;
        self.integral = 0.0;
        self.prev_target = target;
        self.prev_follower_noisy = target;
        self.prev_clean_follower = target;
        self.ff_smooth = 0.0;
        self.force_buffer.clear();
        self.noise_sum = 0.0;
        self.noise_count = 0;
        self.motor_heat = 0.0;
    }

    fn step(&mut self, params: Params, target_raw: f32, dt: f32, rng: &mut StdRng) -> Sample {
        self.target += (target_raw - self.target) * params.target_smoothing;
        let target = self.target;
        let error = target - self.follower;

        self.integral += error * dt;
        if params.integral_limit > 0.0 {
            self.integral = self
                .integral
                .clamp(-params.integral_limit, params.integral_limit);
        }

        let noise_raw = params.gyro_noise * (rng.r#gen::<f32>() * 2.0 - 1.0);
        self.noise_sum += noise_raw;
        self.noise_count += 1;
        let noise_mean = self.noise_sum / self.noise_count as f32;
        let noise = noise_raw - noise_mean;
        let noisy_pos = self.follower + noise;
        let gyro_d = if dt > 0.0 {
            (noisy_pos - self.prev_follower_noisy) / dt
        } else {
            0.0
        };

        let feedforward_raw = if dt > 0.0 {
            (target - self.prev_target) / dt
        } else {
            0.0
        };
        self.ff_smooth = self.ff_smooth * (1.0 - params.ff_alpha) + feedforward_raw * params.ff_alpha;

        let p_term = params.kp * error;
        let i_term = params.ki * self.integral;
        let d_term = -params.kd * gyro_d;
        let ff_term = params.kff * self.ff_smooth;
        let current_force = p_term + i_term + d_term + ff_term;

        let delay_samples = ((params.loop_delay_ms / 1000.0) / dt).round() as usize;
        self.force_buffer.push_back(current_force);
        let delayed_force = if self.force_buffer.len() > delay_samples {
            *self
                .force_buffer
                .get(self.force_buffer.len() - 1 - delay_samples)
                .unwrap()
        } else {
            0.0
        };
        let max_keep = delay_samples + 4;
        while self.force_buffer.len() > max_keep {
            self.force_buffer.pop_front();
        }

        let accel = (delayed_force / params.mass) - (params.drag * self.velocity / params.mass)
            + params.disturbance;
        self.velocity += accel * dt;
        self.follower += self.velocity * dt;

        let clean_gyro_d = if dt > 0.0 {
            (self.follower - self.prev_clean_follower) / dt
        } else {
            0.0
        };
        self.prev_clean_follower = self.follower;
        let d_noise_only = (d_term - (-params.kd * clean_gyro_d)).abs();
        let heat_alpha = if d_noise_only > self.motor_heat { 0.2 } else { 0.02 };
        self.motor_heat = self.motor_heat * (1.0 - heat_alpha) + d_noise_only * heat_alpha;

        self.prev_target = target;
        self.prev_follower_noisy = noisy_pos;
        self.time += dt;

        Sample {
            t: self.time,
            target,
            follower: self.follower,
            error: target - self.follower,
            p_term,
            i_term,
            d_term,
            ff_term,
            noise,
        }
    }
}

struct StepMetrics {
    rise_ms: Option<f32>,
    overshoot_pct: f32,
    settle_s: Option<f32>,
    ss_error: f32,
    unstable: bool,
}

struct StepResponseData {
    points: Vec<[f64; 2]>,
    metrics: StepMetrics,
    y_min: f32,
    y_max: f32,
    target: f32,
    band: f32,
}

fn compute_step_response(params: StepParams) -> StepResponseData {
    const SDT: f32 = 1.0 / 240.0;
    const SDUR: f32 = 10.0;
    const SSTEP: f32 = 50.0;

    let steps = (SDUR / SDT).ceil() as usize;
    let mut unstable = false;
    let kp = if params.kp.is_finite() {
        params.kp
    } else {
        unstable = true;
        0.0
    };
    let ki = if params.ki.is_finite() {
        params.ki
    } else {
        unstable = true;
        0.0
    };
    let kd = if params.kd.is_finite() {
        params.kd
    } else {
        unstable = true;
        0.0
    };
    let mass = if params.mass.is_finite() && params.mass > 0.0 {
        params.mass
    } else {
        unstable = true;
        1.0
    };
    let drag = if params.drag.is_finite() {
        params.drag
    } else {
        unstable = true;
        0.0
    };
    let loop_delay_ms = if params.loop_delay_ms.is_finite() && params.loop_delay_ms >= 0.0 {
        params.loop_delay_ms
    } else {
        unstable = true;
        0.0
    };
    let gyro_noise = if params.gyro_noise.is_finite() {
        params.gyro_noise
    } else {
        unstable = true;
        0.0
    };
    let disturbance = if params.disturbance.is_finite() {
        params.disturbance
    } else {
        unstable = true;
        0.0
    };

    let delay_samples = ((loop_delay_ms / 1000.0) / SDT).round() as usize;

    const RNG_MOD: i64 = 2_147_483_647;
    const RNG_MULT: i64 = 16_807;
    let mut seed: i64 = 12_345;
    let mut rng = || {
        seed = (seed * RNG_MULT) % RNG_MOD;
        (seed as f32 / RNG_MOD as f32) * 2.0 - 1.0
    };

    let mut noise_sum = 0.0;
    let mut noise_count = 0.0;
    let mut zero_mean_noise = || {
        let raw = gyro_noise * rng();
        noise_sum += raw;
        noise_count += 1.0;
        raw - noise_sum / noise_count
    };

    let mut response = Vec::with_capacity(steps);
    let mut fb: Vec<f32> = Vec::with_capacity(steps);
    let mut s_i = 0.0;
    let mut s_v = 0.0;
    let mut s_p = 0.0;
    let mut s_pnp = 0.0;
    let mut rise_start: Option<f32> = None;
    let mut rise_end: Option<f32> = None;
    let mut peak_val = 0.0;
    for i in 0..steps {
        let target = if i == 0 { 0.0 } else { SSTEP };
        let err = target - s_p;
        s_i = (s_i + err * SDT).clamp(-200.0, 200.0);

        let n = zero_mean_noise();
        let n_p = s_p + n;
        let gyro_d = if i > 0 { (n_p - s_pnp) / SDT } else { 0.0 };
        let cf = kp * err + ki * s_i - kd * gyro_d;
        fb.push(cf);

        let df = if i >= delay_samples { fb[i - delay_samples] } else { 0.0 };
        let accel = (df / mass) - (drag * s_v / mass) + disturbance;
        s_v += accel * SDT;
        s_pnp = n_p;
        s_p += s_v * SDT;

        if !s_p.is_finite() || !s_v.is_finite() || !s_i.is_finite() {
            unstable = true;
            let last = *response.last().unwrap_or(&0.0);
            for _ in i..steps {
                response.push(last);
            }
            break;
        }

        if s_p.abs() > 200.0 {
            unstable = true;
        }

        response.push(s_p);
        let t = i as f32 * SDT;
        if rise_start.is_none() && s_p >= SSTEP * 0.1 {
            rise_start = Some(t);
        }
        if rise_end.is_none() && s_p >= SSTEP * 0.9 {
            rise_end = Some(t);
        }
        if s_p > peak_val {
            peak_val = s_p;
        }
    }

    if !unstable {
        let q = steps / 4;
        let mut a2: f32 = 0.0;
        let mut a4: f32 = 0.0;
        for i in q..2 * q {
            a2 = a2.max((response[i] - SSTEP).abs());
        }
        for i in 3 * q..steps {
            a4 = a4.max((response[i] - SSTEP).abs());
        }
        if a4 > a2 * 1.5 && a4 > 2.0 {
            unstable = true;
        }
    }

    let band = SSTEP * 0.02;
    let mut settle = SDUR;
    for i in (0..steps).rev() {
        if (response[i] - SSTEP).abs() > band {
            settle = ((i + 1) as f32) * SDT;
            break;
        }
    }
    if (response[steps - 1] - SSTEP).abs() > band {
        settle = SDUR;
    }

    let rise_ms = match (rise_start, rise_end) {
        (Some(s), Some(e)) if e >= s => Some((e - s) * 1000.0),
        _ => None,
    };
    let overshoot_pct = ((peak_val - SSTEP) / SSTEP * 100.0).max(0.0);
    let settle_s = if settle >= SDUR { None } else { Some(settle) };
    let ss_error = (response[steps - 1] - SSTEP).abs();

    let mut y_min: f32 = 0.0;
    let mut y_max: f32 = SSTEP;
    for v in &response {
        y_min = y_min.min(*v);
        y_max = y_max.max(*v);
    }
    let pad = ((y_max - y_min) * 0.15).max(SSTEP * 0.1);
    y_min -= pad;
    y_max += pad;

    let points: Vec<[f64; 2]> = response
        .iter()
        .enumerate()
        .map(|(i, v)| [(i as f32 * SDT) as f64, *v as f64])
        .collect();

    StepResponseData {
        points,
        metrics: StepMetrics {
            rise_ms,
            overshoot_pct,
            settle_s,
            ss_error,
            unstable,
        },
        y_min,
        y_max,
        target: SSTEP,
        band,
    }
}

struct PidApp {
    params: Params,
    target_raw: f32,
    paused: bool,
    rng: StdRng,
    sim: SimState,
    history: VecDeque<Sample>,
    accumulator: f32,
    show_target: bool,
    show_follower: bool,
    show_error: bool,
    show_p: bool,
    show_i: bool,
    show_d: bool,
    show_ff: bool,
    show_noise: bool,
    step_data: StepResponseData,
    last_step_params: StepParams,
    theme_set: bool,
}

impl PidApp {
    fn new() -> Self {
        let params = Params::default();
        let step_params = StepParams::from(params);
        Self {
            params,
            target_raw: 0.0,
            paused: false,
            rng: StdRng::seed_from_u64(0xC0FFEE),
            sim: SimState::new(),
            history: VecDeque::new(),
            accumulator: 0.0,
            show_target: true,
            show_follower: true,
            show_error: true,
            show_p: false,
            show_i: false,
            show_d: false,
            show_ff: false,
            show_noise: false,
            step_data: compute_step_response(step_params),
            last_step_params: step_params,
            theme_set: false,
        }
    }

    fn reset_sim(&mut self) {
        self.sim.reset(self.target_raw);
        self.history.clear();
        self.accumulator = 0.0;
    }

    fn reset_all(&mut self) {
        self.params = Params::default();
        self.target_raw = 0.0;
        self.paused = false;
        self.rng = StdRng::seed_from_u64(0xC0FFEE);
        self.sim = SimState::new();
        self.history.clear();
        self.accumulator = 0.0;
        let step_params = StepParams::from(self.params);
        self.step_data = compute_step_response(step_params);
        self.last_step_params = step_params;
    }

    fn update_step_response_if_needed(&mut self) {
        let params = StepParams::from(self.params);
        if params != self.last_step_params {
            self.step_data = compute_step_response(params);
            self.last_step_params = params;
        }
    }

    fn push_sample(&mut self, sample: Sample) {
        let max_len = (HISTORY_SECONDS / SIM_DT) as usize;
        self.history.push_back(sample);
        while self.history.len() > max_len {
            self.history.pop_front();
        }
    }

    fn section_frame(ui: &mut egui::Ui, title: &str, add_contents: impl FnOnce(&mut egui::Ui)) {
        let frame = egui::Frame::group(ui.style())
            .fill(egui::Color32::from_rgb(18, 21, 28))
            .stroke(egui::Stroke::new(1.0, egui::Color32::from_rgb(45, 52, 64)))
            .rounding(egui::Rounding::same(6.0))
            .inner_margin(egui::Margin::same(8.0));
        frame.show(ui, |ui| {
            ui.label(
                egui::RichText::new(title)
                    .color(egui::Color32::from_rgb(140, 155, 170))
                    .strong(),
            );
            ui.add_space(6.0);
            add_contents(ui);
        });
    }
}

fn draw_car_view(
    ui: &mut egui::Ui,
    target: f32,
    follower: f32,
    target_color: egui::Color32,
    follower_color: egui::Color32,
    error_color: egui::Color32,
    muted: egui::Color32,
) {
    let desired = egui::vec2(ui.available_width(), 140.0);
    let (rect, _) = ui.allocate_exact_size(desired, egui::Sense::hover());
    let painter = ui.painter_at(rect);

    painter.rect_filled(rect, 6.0, egui::Color32::from_rgb(10, 12, 16));
    painter.rect_stroke(
        rect,
        6.0,
        egui::Stroke::new(1.0, egui::Color32::from_rgb(40, 46, 58)),
    );

    let pad_x = 24.0;
    let road_h = 14.0;
    let road_y = rect.top() + rect.height() * 0.62;
    let road_rect = egui::Rect::from_min_max(
        egui::pos2(rect.left() + pad_x, road_y),
        egui::pos2(rect.right() - pad_x, road_y + road_h),
    );

    painter.rect_filled(road_rect, 4.0, egui::Color32::from_rgb(20, 24, 32));
    painter.rect_stroke(
        road_rect,
        4.0,
        egui::Stroke::new(1.0, egui::Color32::from_rgb(45, 52, 64)),
    );

    for i in 0..=10 {
        let t = i as f32 / 10.0;
        let x = road_rect.left() + t * road_rect.width();
        let tick_h = if i % 5 == 0 { 10.0 } else { 6.0 };
        painter.line_segment(
            [
                egui::pos2(x, road_rect.top() - tick_h),
                egui::pos2(x, road_rect.top()),
            ],
            egui::Stroke::new(1.0, egui::Color32::from_rgb(40, 46, 58)),
        );
    }

    let max_val = target.abs().max(follower.abs()).max(100.0);
    let range = (max_val * 1.15).max(100.0);
    let map_x = |v: f32| -> f32 {
        let clamped = v.clamp(-range, range);
        road_rect.left() + (clamped + range) / (2.0 * range) * road_rect.width()
    };

    let target_x = map_x(target);
    let follower_x = map_x(follower);

    let pole_top = egui::pos2(target_x, road_rect.top() - 30.0);
    let pole_bot = egui::pos2(target_x, road_rect.top() - 2.0);
    painter.line_segment([pole_top, pole_bot], egui::Stroke::new(2.0, target_color));
    let flag = [
        pole_top,
        egui::pos2(target_x + 12.0, road_rect.top() - 24.0),
        egui::pos2(target_x, road_rect.top() - 18.0),
    ];
    painter.add(egui::Shape::convex_polygon(flag.to_vec(), target_color, egui::Stroke::NONE));
    painter.text(
        egui::pos2(target_x + 14.0, road_rect.top() - 28.0),
        egui::Align2::LEFT_CENTER,
        "Setpoint",
        egui::FontId::proportional(12.0),
        target_color,
    );

    painter.text(
        egui::pos2(rect.right() - 8.0, rect.top() + 10.0),
        egui::Align2::RIGHT_CENTER,
        format!("Scale ±{:.0}", range),
        egui::FontId::proportional(11.0),
        muted,
    );

    let car_center = egui::pos2(follower_x, road_rect.top() - 10.0);
    let car_body = egui::Rect::from_center_size(car_center, egui::vec2(42.0, 16.0));
    painter.rect_filled(car_body, 4.0, follower_color);
    painter.rect_stroke(
        car_body,
        4.0,
        egui::Stroke::new(1.0, egui::Color32::from_rgb(20, 24, 32)),
    );
    let roof = egui::Rect::from_center_size(
        egui::pos2(car_center.x - 4.0, car_center.y - 9.0),
        egui::vec2(20.0, 8.0),
    );
    painter.rect_filled(roof, 3.0, egui::Color32::from_rgb(28, 34, 44));

    let wheel_color = egui::Color32::from_rgb(8, 10, 12);
    let wheel_y = car_body.bottom() + 3.0;
    painter.circle_filled(egui::pos2(car_body.left() + 9.0, wheel_y), 4.0, wheel_color);
    painter.circle_filled(egui::pos2(car_body.right() - 9.0, wheel_y), 4.0, wheel_color);
    painter.text(
        egui::pos2(car_body.right() + 6.0, car_body.center().y),
        egui::Align2::LEFT_CENTER,
        "Follower",
        egui::FontId::proportional(12.0),
        follower_color,
    );

    let arrow_y = rect.top() + 22.0;
    if (target_x - follower_x).abs() > 4.0 {
        let start = egui::pos2(follower_x, arrow_y);
        let end = egui::pos2(target_x, arrow_y);
        painter.line_segment([start, end], egui::Stroke::new(1.5, error_color));
        let dir = if target_x > follower_x { 1.0 } else { -1.0 };
        let head = egui::pos2(end.x, end.y);
        let wing1 = egui::pos2(end.x - dir * 8.0, end.y - 4.0);
        let wing2 = egui::pos2(end.x - dir * 8.0, end.y + 4.0);
        painter.line_segment([head, wing1], egui::Stroke::new(1.5, error_color));
        painter.line_segment([head, wing2], egui::Stroke::new(1.5, error_color));
        painter.text(
            egui::pos2(rect.left() + 8.0, arrow_y),
            egui::Align2::LEFT_CENTER,
            "Error",
            egui::FontId::proportional(12.0),
            muted,
        );
    }
}

impl eframe::App for PidApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        if !self.theme_set {
            let mut visuals = egui::Visuals::dark();
            visuals.panel_fill = egui::Color32::from_rgb(12, 14, 18);
            visuals.window_fill = egui::Color32::from_rgb(18, 21, 28);
            visuals.faint_bg_color = egui::Color32::from_rgb(20, 24, 32);
            visuals.extreme_bg_color = egui::Color32::from_rgb(8, 10, 14);
            visuals.override_text_color = Some(egui::Color32::from_rgb(220, 230, 240));
            visuals.widgets.noninteractive.bg_fill = egui::Color32::from_rgb(18, 21, 28);
            visuals.widgets.inactive.bg_fill = egui::Color32::from_rgb(24, 28, 36);
            visuals.widgets.hovered.bg_fill = egui::Color32::from_rgb(30, 36, 46);
            visuals.widgets.active.bg_fill = egui::Color32::from_rgb(36, 44, 58);
            visuals.selection.bg_fill = egui::Color32::from_rgb(34, 211, 238);
            visuals.selection.stroke.color = egui::Color32::from_rgb(5, 6, 8);

            let mut style = (*ctx.style()).clone();
            style.spacing.item_spacing = egui::vec2(8.0, 8.0);
            style.spacing.button_padding = egui::vec2(10.0, 6.0);
            style.visuals = visuals;
            ctx.set_style(style);
            self.theme_set = true;
        }

        let mut step_once = false;
        let target_color = egui::Color32::from_rgb(245, 158, 11);
        let follower_color = egui::Color32::from_rgb(34, 211, 238);
        let error_color = egui::Color32::from_rgb(244, 63, 94);
        let muted = egui::Color32::from_rgb(130, 140, 155);

        egui::TopBottomPanel::top("top")
            .frame(
                egui::Frame::none()
                    .fill(egui::Color32::from_rgb(12, 14, 18))
                    .inner_margin(egui::Margin::symmetric(12.0, 8.0)),
            )
            .show(ctx, |ui| {
                ui.horizontal(|ui| {
                    ui.heading(
                        egui::RichText::new("PID Controller Simulator")
                            .size(20.0)
                            .strong(),
                    );
                    ui.add_space(10.0);
                    let status_color = if self.paused {
                        egui::Color32::from_rgb(245, 158, 11)
                    } else {
                        egui::Color32::from_rgb(52, 211, 153)
                    };
                    let status_text = if self.paused { "PAUSED" } else { "RUNNING" };
                    ui.label(egui::RichText::new(status_text).color(status_color).strong());
                    ui.add_space(10.0);
                    ui.label(egui::RichText::new(format!("t = {:.2}s", self.sim.time)).color(muted));
                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        if ui.button("Reset All").clicked() {
                            self.reset_all();
                        }
                        if ui.button("Reset Sim").clicked() {
                            self.reset_sim();
                        }
                        if ui.button("Step").clicked() {
                            step_once = true;
                            self.paused = true;
                        }
                        let pause_label = if self.paused { "Resume" } else { "Pause" };
                        if ui.button(pause_label).clicked() {
                            self.paused = !self.paused;
                        }
                    });
                });
            });

        egui::TopBottomPanel::bottom("status")
            .frame(
                egui::Frame::none()
                    .fill(egui::Color32::from_rgb(12, 14, 18))
                    .inner_margin(egui::Margin::symmetric(12.0, 6.0)),
            )
            .show(ctx, |ui| {
                let heat_norm = (self.sim.motor_heat / 6.0).clamp(0.0, 1.0);
                let heat_color = if heat_norm < 0.3 {
                    egui::Color32::from_rgb(52, 211, 153)
                } else if heat_norm < 0.6 {
                    egui::Color32::from_rgb(245, 158, 11)
                } else {
                    egui::Color32::from_rgb(244, 63, 94)
                };
                ui.horizontal_wrapped(|ui| {
                    ui.label(
                        egui::RichText::new(format!("Target: {:.1}", self.target_raw))
                            .color(target_color),
                    );
                    ui.label(egui::RichText::new("|").color(muted));
                    ui.label(
                        egui::RichText::new(format!("Follower: {:.1}", self.sim.follower))
                            .color(follower_color),
                    );
                    ui.label(egui::RichText::new("|").color(muted));
                    ui.label(
                        egui::RichText::new(format!(
                            "Error: {:.1}",
                            self.sim.target - self.sim.follower
                        ))
                        .color(error_color),
                    );
                    ui.label(egui::RichText::new("|").color(muted));
                    ui.label(
                        egui::RichText::new(format!("Motor Heat: {:.2}", self.sim.motor_heat))
                            .color(heat_color),
                    );
                });
            });

        egui::SidePanel::left("controls")
            .resizable(false)
            .default_width(320.0)
            .frame(
                egui::Frame::none()
                    .fill(egui::Color32::from_rgb(12, 14, 18))
                    .inner_margin(egui::Margin::symmetric(12.0, 10.0)),
            )
            .show(ctx, |ui| {
                egui::ScrollArea::vertical()
                    .auto_shrink([false; 2])
                    .show(ui, |ui| {
                        Self::section_frame(ui, "PID Gains", |ui| {
                            egui::Grid::new("pid_grid")
                                .spacing([8.0, 6.0])
                                .show(ui, |ui| {
                                    ui.label("Kp");
                                    ui.add(egui::Slider::new(&mut self.params.kp, 0.0..=30.0));
                                    ui.end_row();
                                    ui.label("Ki");
                                    ui.add(egui::Slider::new(&mut self.params.ki, 0.0..=5.0));
                                    ui.end_row();
                                    ui.label("Kd");
                                    ui.add(egui::Slider::new(&mut self.params.kd, 0.0..=15.0));
                                    ui.end_row();
                                    ui.label("Kff");
                                    ui.add(egui::Slider::new(&mut self.params.kff, 0.0..=2.0));
                                    ui.end_row();
                                });
                        });
                        ui.add_space(10.0);

                        Self::section_frame(ui, "Filters & Limits", |ui| {
                            egui::Grid::new("filter_grid")
                                .spacing([8.0, 6.0])
                                .show(ui, |ui| {
                                    ui.label("I Clamp");
                                    ui.add(egui::Slider::new(
                                        &mut self.params.integral_limit,
                                        10.0..=400.0,
                                    ));
                                    ui.end_row();
                                    ui.label("Target Smoothing");
                                    ui.add(egui::Slider::new(
                                        &mut self.params.target_smoothing,
                                        0.01..=0.4,
                                    ));
                                    ui.end_row();
                                    ui.label("FF Filter");
                                    ui.add(egui::Slider::new(
                                        &mut self.params.ff_alpha,
                                        0.02..=0.5,
                                    ));
                                    ui.end_row();
                                });
                        });
                        ui.add_space(10.0);

                        Self::section_frame(ui, "Physics", |ui| {
                            egui::Grid::new("physics_grid")
                                .spacing([8.0, 6.0])
                                .show(ui, |ui| {
                                    ui.label("Mass");
                                    ui.add(egui::Slider::new(&mut self.params.mass, 0.1..=5.0));
                                    ui.end_row();
                                    ui.label("Drag");
                                    ui.add(egui::Slider::new(&mut self.params.drag, 0.05..=1.5));
                                    ui.end_row();
                                    ui.label("Loop Delay ms");
                                    ui.add(egui::Slider::new(
                                        &mut self.params.loop_delay_ms,
                                        0.0..=50.0,
                                    ));
                                    ui.end_row();
                                    ui.label("Gyro Noise");
                                    ui.add(egui::Slider::new(
                                        &mut self.params.gyro_noise,
                                        0.0..=0.02,
                                    ));
                                    ui.end_row();
                                    ui.label("Disturbance");
                                    ui.add(egui::Slider::new(
                                        &mut self.params.disturbance,
                                        -50.0..=50.0,
                                    ));
                                    ui.end_row();
                                });
                        });
                        ui.add_space(10.0);

                        Self::section_frame(ui, "Setpoint", |ui| {
                            ui.add(
                                egui::Slider::new(&mut self.target_raw, -100.0..=100.0)
                                    .text("Target"),
                            );
                            ui.add(
                                egui::ProgressBar::new((self.sim.motor_heat / 6.0).clamp(0.0, 1.0))
                                    .text(format!("Motor Heat {:.2}", self.sim.motor_heat)),
                            );
                            if ui.button("Reseed Noise").clicked() {
                                self.rng = StdRng::seed_from_u64(0xC0FFEE);
                            }
                        });
                        ui.add_space(10.0);

                        Self::section_frame(ui, "Scope Traces", |ui| {
                            ui.horizontal_wrapped(|ui| {
                                ui.checkbox(&mut self.show_target, "Target");
                                ui.checkbox(&mut self.show_follower, "Follower");
                                ui.checkbox(&mut self.show_error, "Error");
                            });
                            ui.separator();
                            ui.horizontal_wrapped(|ui| {
                                ui.checkbox(&mut self.show_p, "P");
                                ui.checkbox(&mut self.show_i, "I");
                                ui.checkbox(&mut self.show_d, "D");
                                ui.checkbox(&mut self.show_ff, "FF");
                                ui.checkbox(&mut self.show_noise, "Noise x1000");
                            });
                        });
                    });
            });

        egui::CentralPanel::default()
            .frame(
                egui::Frame::none()
                    .fill(egui::Color32::from_rgb(14, 16, 21))
                    .inner_margin(egui::Margin::symmetric(12.0, 10.0)),
            )
            .show(ctx, |ui| {
                Self::section_frame(ui, "Vehicle View", |ui| {
                    draw_car_view(
                        ui,
                        self.target_raw,
                        self.sim.follower,
                        target_color,
                        follower_color,
                        error_color,
                        muted,
                    );
                });

                ui.add_space(12.0);

                Self::section_frame(ui, "Step Response (0 → 50, 10s)", |ui| {
                    if self.step_data.metrics.unstable {
                        ui.colored_label(egui::Color32::LIGHT_RED, "Unstable");
                    }
                    ui.horizontal_wrapped(|ui| {
                        let rise = self
                            .step_data
                            .metrics
                            .rise_ms
                            .map(|v| format!("{v:.0} ms"))
                            .unwrap_or_else(|| "—".to_string());
                        let settle = self
                            .step_data
                            .metrics
                            .settle_s
                            .map(|v| format!("{v:.2} s"))
                            .unwrap_or_else(|| format!("> {:.0} s", 10.0));
                        ui.label(egui::RichText::new(format!("Rise: {rise}")).color(muted));
                        ui.label(
                            egui::RichText::new(format!(
                                "Overshoot: {:.1}%",
                                self.step_data.metrics.overshoot_pct
                            ))
                            .color(muted),
                        );
                        ui.label(egui::RichText::new(format!("Settle: {settle}")).color(muted));
                        ui.label(
                            egui::RichText::new(format!(
                                "SS Err: {:.2}",
                                self.step_data.metrics.ss_error
                            ))
                            .color(muted),
                        );
                    });

                    let plot = Plot::new("step_response")
                        .height(220.0)
                        .include_x(0.0)
                        .include_x(10.0)
                        .include_y(self.step_data.y_min as f64)
                        .include_y(self.step_data.y_max as f64);

                    plot.show(ui, |plot_ui| {
                        plot_ui.line(
                            Line::new(PlotPoints::from(self.step_data.points.clone()))
                                .color(follower_color)
                                .width(1.6),
                        );
                        let target = self.step_data.target as f64;
                        let band = self.step_data.band as f64;
                        let top =
                            PlotPoints::from(vec![[0.0, target + band], [10.0, target + band]]);
                        let bot =
                            PlotPoints::from(vec![[0.0, target - band], [10.0, target - band]]);
                        plot_ui.line(Line::new(top).color(egui::Color32::from_rgb(80, 120, 140)));
                        plot_ui.line(Line::new(bot).color(egui::Color32::from_rgb(80, 120, 140)));
                    });
                });

                ui.add_space(12.0);

                Self::section_frame(ui, "Scope (last 10s)", |ui| {
                    let plot = Plot::new("scope").height(280.0);

                    let end_t = self.history.back().map(|s| s.t).unwrap_or(0.0);
                    let start_t = (end_t - HISTORY_WINDOW_SECONDS).max(0.0);
                    let decimate = ((HISTORY_WINDOW_SECONDS / SIM_DT) as usize / 1200).max(1);

                    let line_points = |f: fn(&Sample) -> f32| -> PlotPoints {
                        let pts: Vec<[f64; 2]> = self
                            .history
                            .iter()
                            .filter(|s| s.t >= start_t)
                            .step_by(decimate)
                            .map(|s| [(s.t - start_t) as f64, f(s) as f64])
                            .collect();
                        PlotPoints::from(pts)
                    };

                    plot.show(ui, |plot_ui| {
                        if self.show_target {
                            plot_ui.line(
                                Line::new(line_points(|s| s.target))
                                    .color(target_color)
                                    .width(1.4),
                            );
                        }
                        if self.show_follower {
                            plot_ui.line(
                                Line::new(line_points(|s| s.follower))
                                    .color(follower_color)
                                    .width(1.6),
                            );
                        }
                        if self.show_error {
                            plot_ui.line(
                                Line::new(line_points(|s| s.error))
                                    .color(error_color)
                                    .width(1.2),
                            );
                        }
                        if self.show_p {
                            plot_ui.line(
                                Line::new(line_points(|s| s.p_term))
                                    .color(egui::Color32::from_rgb(34, 211, 238))
                                    .width(1.0),
                            );
                        }
                        if self.show_i {
                            plot_ui.line(
                                Line::new(line_points(|s| s.i_term))
                                    .color(egui::Color32::from_rgb(167, 139, 250))
                                    .width(1.0),
                            );
                        }
                        if self.show_d {
                            plot_ui.line(
                                Line::new(line_points(|s| s.d_term))
                                    .color(egui::Color32::from_rgb(52, 211, 153))
                                    .width(1.0),
                            );
                        }
                        if self.show_ff {
                            plot_ui.line(
                                Line::new(line_points(|s| s.ff_term))
                                    .color(egui::Color32::from_rgb(251, 113, 133))
                                    .width(1.0),
                            );
                        }
                        if self.show_noise {
                            plot_ui.line(
                                Line::new(line_points(|s| s.noise * 1000.0))
                                    .color(egui::Color32::from_rgb(136, 136, 136))
                                    .width(1.0),
                            );
                        }
                    });
                });
            });

        if !self.paused || step_once {
            let dt = ctx.input(|i| i.unstable_dt) as f32;
            self.accumulator += dt.min(0.1);
            let mut steps = 0;
            while (self.accumulator >= SIM_DT && steps < 8) || (step_once && steps == 0) {
                let sample = self.sim.step(self.params, self.target_raw, SIM_DT, &mut self.rng);
                self.push_sample(sample);
                self.accumulator -= SIM_DT;
                steps += 1;
                if step_once {
                    break;
                }
            }
        }

        self.update_step_response_if_needed();

        if !self.paused {
            ctx.request_repaint();
        }
    }
}

fn main() -> eframe::Result<()> {
    let native_options = eframe::NativeOptions::default();
    eframe::run_native(
        "PID Controller Simulator",
        native_options,
        Box::new(|_cc| Box::new(PidApp::new())),
    )
}
