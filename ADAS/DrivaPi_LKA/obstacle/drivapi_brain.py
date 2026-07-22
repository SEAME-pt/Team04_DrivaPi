"""
ADAS decision layer: translates YOLO detections into deterministic PWM controls.
Integrates an asymmetric filter, hazard decay, defensive clamping, and command priorities.
"""

from __future__ import annotations

import logging
import socket
import time
from dataclasses import dataclass
from typing import Iterable
from .hailo_config import HailoConfig as cfg

logger = logging.getLogger(__name__)


class PersistenceTracker:
    """Reacts on the first frame (zero latency) and decays hazard if the sensor drops."""

    def __init__(self, hold_frames: int) -> None:
        self.max_hold = hold_frames
        self.frames_left = 0
        self.active_det: Detection | None = None

    def update(self, detected: bool, det_obj: Detection | None = None) -> bool:
        if detected:
            self.frames_left = self.max_hold
            self.active_det = det_obj
            return True

        if self.frames_left > 0:
            self.frames_left -= 1

            # Progressive hazard decay to avoid ghost braking.
            if self.active_det:
                h_current = self.active_det.ymax - self.active_det.ymin
                self.active_det = Detection(
                    label=self.active_det.label,
                    ymin=self.active_det.ymin,
                    ymax=self.active_det.ymin + (h_current * cfg.HAZARD_DECAY_HEIGHT_SCALE),
                    confidence=self.active_det.confidence * cfg.HAZARD_DECAY_CONF_SCALE,
                )
            return True

        self.active_det = None
        return False


@dataclass
class Detection:
    """Represents a normalized YOLO detection."""

    label: str
    ymin: float
    ymax: float
    confidence: float


class DrivaPiBrain:
    """Translates detections into PWM commands for the vehicle controller."""

    def __init__(self) -> None:
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.target = (cfg.UDP_IP, cfg.UDP_PORT)

        self.current_pwm = 0.0
        self.speed_limit = cfg.PWM_CRUISE
        self.limit_expiry = 0.0

        # Smart STOP handling.
        self.stop_at = 0.0  # Timestamp for when the stop should begin.
        self.last_stop_time = 0.0  # Cooldown window to prevent re-locking STOP signals.

        self.last_udp_send_time = 0.0
        self.last_sent_msg = ""
        self.last_log = 0

        # Tracker allocation.
        self.trackers: dict[str, PersistenceTracker] = {}
        for label in cfg.CLASSES:
            hold_frames = (
                cfg.TRACKER_HOLD_FRAMES_CRITICAL
                if label in cfg.CRITICAL_TRACKER_LABELS
                else cfg.TRACKER_HOLD_FRAMES_DEFAULT
            )
            self.trackers[label] = PersistenceTracker(hold_frames=hold_frames)

        self.accel_rate = cfg.ACCEL_RATE
        self.decel_rate = cfg.DECEL_RATE

    def process_detections(self, detections: Iterable[Detection]) -> None:
        """Update hazard state and emit PWM commands based on detections."""
        now = time.time()
        detections = list(detections)

        # Speed-limit expiration from sign detections (50 / 80).
        if now > self.limit_expiry and self.speed_limit != cfg.PWM_CRUISE:
            logger.info("state=speed_limit_expired limit=%d", self.speed_limit)
            self.speed_limit = cfg.PWM_CRUISE

        # 1. Immediate capture and tracker update.
        # Trackers must always update, even while a STOP sequence is active.
        detected_by_label: dict[str, Detection] = {}
        for det in detections:
            if det.confidence <= cfg.CONFIDENCE_THRESHOLD:
                continue

            previous = detected_by_label.get(det.label)
            if previous is None:
                detected_by_label[det.label] = det
                continue

            # If several detections share a label, keep the closest/largest one because
            # normalized height is what drives emergency and following decisions.
            previous_h = previous.ymax - previous.ymin
            current_h = det.ymax - det.ymin
            if current_h > previous_h:
                detected_by_label[det.label] = det

        confirmed_detections = []
        for label in cfg.CLASSES:
            current_det = detected_by_label.get(label)

            if self.trackers[label].update(current_det is not None, current_det):
                valid_det = current_det if current_det else self.trackers[label].active_det
                if valid_det:
                    confirmed_detections.append(valid_det)

        temp_target = self.speed_limit
        reason = "NORMAL"

        # Explicit priority hierarchy to avoid control conflicts.
        # 0 = Normal, 1 = Caution, 2 = Following / STOP approach, 3 = Full stop / emergency
        current_priority = 0

        # 2. Apply active STOP sequence as a control state, not as an early return.
        # This keeps the brain alive and allows emergency detections to override the roll-up.
        stop_sequence_active = self.stop_at > 0.0
        stop_approach_active = False
        stop_timer_active = False

        if self.stop_at > 0.0:
            if now < self.stop_at:
                # PHASE 1: Car saw STOP but keeps rolling slowly to reach the line.
                temp_target = min(temp_target, cfg.PWM_SLOW)
                reason = "APPROACHING_STOP_LINE"
                current_priority = 2
                stop_approach_active = True

            elif now < self.stop_at + cfg.STOP_DURATION_SEC:
                # PHASE 2: Approach timer expired, enforce a full stop.
                temp_target = 0
                reason = "STOP_TIMER_ACTIVE"
                current_priority = 3
                stop_timer_active = True

            else:
                # PHASE 3: Stop complete. Reset state and enable STOP cooldown.
                logger.info("state=stop_completed")
                self.last_stop_time = now
                self.stop_at = 0.0
                stop_sequence_active = False

        # 3. Process confirmed detections.
        for det in confirmed_detections:
            h = round(det.ymax - det.ymin, 3)

            # --- PRIORITY 3: FULL STOP / EMERGENCY ---
            if det.label in ["gate", "traffic_light_red"] and h > cfg.H_STOP:
                if current_priority <= 3:
                    temp_target = 0
                    reason = f"STOP({det.label})"
                    current_priority = 3

            elif det.label in ["car", "obstacle"] and h > cfg.H_EMERGENCY:
                if current_priority <= 3:
                    temp_target = 0
                    reason = f"EMERGENCY({det.label})"
                    current_priority = 3

            elif det.label == "stop_sign" and h > cfg.H_STOP:
                # Do not re-schedule the same STOP while the approach/timer is already active.
                if stop_sequence_active or stop_approach_active or stop_timer_active:
                    continue

                # Only schedule a new stop if not in post-stop immunity.
                if now - self.last_stop_time > cfg.STOP_COOLDOWN_SEC:
                    if current_priority < 3:
                        # Schedule the real stop ahead to allow a short roll-up to the line.
                        self.stop_at = now + cfg.STOP_DELAY_SEC
                        temp_target = min(temp_target, cfg.PWM_SLOW)
                        reason = "STOP_SIGN_DETECTED"
                        current_priority = 2
                else:
                    # Post-stop immunity active: keep the car slow to clear the sign area.
                    if current_priority < 1:
                        temp_target = min(temp_target, cfg.PWM_SLOW)
                        reason = "LEAVING_STOP_ZONE"
                        current_priority = 1

            # --- PRIORITY 2: PROPORTIONAL FOLLOWING (Cars/Obstacles) ---
            elif det.label in ["car", "obstacle"] and h > cfg.FOLLOWING_START_H:
                if current_priority < 2:
                    ratio = (h - cfg.FOLLOWING_START_H) / (cfg.H_EMERGENCY - cfg.FOLLOWING_START_H)
                    ratio = max(0.0, min(ratio, 1.0))

                    temp_target = min(
                        temp_target,
                        cfg.PWM_CRUISE - (cfg.PWM_CRUISE - cfg.PWM_SLOW) * ratio,
                    )
                    reason = f"FOLLOWING({det.label}_h={h})"
                    current_priority = 2

            # --- PRIORITY 1: CAUTION ZONES (Real progressive slowing on track) ---
            elif det.label in ["crosswalk_sign", "yield_sign", "danger_sign", "traffic_light_yellow", "stop_sign"]:
                if current_priority < 1:
                    # Start braking smoothly at the configured height down to PWM_SLOW.
                    h_start = cfg.CAUTION_START_H
                    h_end = cfg.H_STOP if det.label == "stop_sign" else cfg.CAUTION_END_H

                    if h >= h_start:
                        ratio = (h - h_start) / (h_end - h_start)
                        ratio = max(0.0, min(ratio, 1.0))

                        # Widen braking dynamics using PWM_SLOW as the safety floor.
                        caution_pwm = cfg.PWM_CRUISE - ((cfg.PWM_CRUISE - cfg.PWM_SLOW) * ratio)
                        temp_target = min(temp_target, caution_pwm)
                        reason = f"CAUTION({det.label}_h={h})"
                        current_priority = 1

            # --- PRIORITY 0: BASELINE CHANGES (Speed signs) ---
            elif det.label == "50_sign":
                self.speed_limit = cfg.PWM_50
                self.limit_expiry = now + cfg.SPEED_LIMIT_DURATION_SEC
            elif det.label == "80_sign":
                self.speed_limit = cfg.PWM_80
                self.limit_expiry = now + cfg.SPEED_LIMIT_DURATION_SEC
            elif det.label == "traffic_light_green":
                self.speed_limit = cfg.PWM_CRUISE

        # 4. Execute the adaptive PWM ramp.
        if self.current_pwm < temp_target:
            self.current_pwm = min(self.current_pwm + self.accel_rate, temp_target)
        elif self.current_pwm > temp_target:
            if temp_target == 0:
                self.current_pwm = 0  # Immediate electrical cut for emergency braking.
            else:
                self.current_pwm = max(self.current_pwm - self.decel_rate, temp_target)

        final = int(self.current_pwm)
        self.send_command(final, cfg.FORWARD if final > 0 else cfg.BRAKE, temp_target, reason)

    def send_command(self, speed: float, direction: int, target_frame: float, reason: str) -> None:
        """Send a UDP command if required by rate, change, or emergency."""
        now = time.time()
        msg = f"{int(speed)},{int(direction)},{cfg.MID_SERVO}"

        is_emergency = "STOP" in reason or "EMERGENCY" in reason or speed == 0
        time_passed = (now - self.last_udp_send_time) >= cfg.UDP_INTERVAL
        msg_changed = msg != self.last_sent_msg

        # Send immediately on emergency or when the command changes.
        if is_emergency or msg_changed or time_passed:
            self.sock.sendto(msg.encode("utf-8"), self.target)
            self.last_udp_send_time = now
            self.last_sent_msg = msg

        # Telemetry throttle to avoid flooding the Pi 5 terminal.
        if now - self.last_log > cfg.TELEMETRY_INTERVAL_SEC:
            logger.info(
                "metrics state=control pwm=%d target=%d reason=%s",
                int(speed),
                int(target_frame),
                reason,
            )
            self.last_log = now