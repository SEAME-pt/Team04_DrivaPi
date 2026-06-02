"""
ADAS decision layer: translates YOLO detections into deterministic PWM controls.
Integrates an asymmetric filter, hazard decay, defensive clamping, and command priorities.
"""

from __future__ import annotations

import socket
import time
from dataclasses import dataclass
from typing import Iterable
from hailo_config import HailoConfig as cfg

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
        else:
            if self.frames_left > 0:
                self.frames_left -= 1

                # Progressive hazard decay to avoid ghost braking.
                if self.active_det:
                    h_current = self.active_det.ymax - self.active_det.ymin
                    self.active_det = Detection(
                        label=self.active_det.label,
                        ymin=self.active_det.ymin,
                        ymax=self.active_det.ymin + (h_current * 0.88),  # Shrink height 12% per frame.
                        confidence=self.active_det.confidence * 0.90,  # Reduce confidence 10% per frame.
                    )
                return True
            else:
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
            if label in ["car", "obstacle", "gate"]:
                self.trackers[label] = PersistenceTracker(hold_frames=6)
            else:
                self.trackers[label] = PersistenceTracker(hold_frames=4)

        self.accel_rate = 0.5
        self.decel_rate = 9.0

    def process_detections(self, detections: Iterable[Detection]) -> None:
        """Update hazard state and emit PWM commands based on detections."""
        now = time.time()

        # Speed-limit expiration from sign detections (50 / 80).
        if now > self.limit_expiry and self.speed_limit != cfg.PWM_CRUISE:
            print("[BRAIN] Speed limit expired. Returning to cruise.")
            self.speed_limit = cfg.PWM_CRUISE

        # --- SEQUENTIAL STOP CONTROL (software delay trick) ---
        if self.stop_at > 0.0:
            if now < self.stop_at:
                # PHASE 1: Car saw STOP but keeps rolling to reach the line.
                self.current_pwm = cfg.PWM_SLOW
                self.send_command(int(self.current_pwm), cfg.FORWARD, cfg.PWM_SLOW, "APPROACHING_STOP_LINE")
                return
            elif now < self.stop_at + 3.0:
                # PHASE 2: Approach timer expired, enforce a 3-second stop.
                self.current_pwm = 0.0
                self.send_command(0, cfg.BRAKE, 0, "STOP_TIMER_ACTIVE")
                return
            else:
                # PHASE 3: Stop complete. Reset state and enable STOP cooldown.
                print("[BRAIN] 3-second stop completed. Resuming drive.")
                self.last_stop_time = now
                self.stop_at = 0.0

        # 1. Immediate capture and tracker update (aligned to 0.20 in main_inference).
        detected_this_frame = {d.label for d in detections if d.confidence > 0.20}
        confirmed_detections = []

        for label in cfg.CLASSES:
            is_present = label in detected_this_frame
            current_det = next((d for d in detections if d.label == label), None)

            if self.trackers[label].update(is_present, current_det):
                valid_det = current_det if current_det else self.trackers[label].active_det
                if valid_det:
                    confirmed_detections.append(valid_det)

        temp_target = self.speed_limit
        reason = "NORMAL"

        # Explicit priority hierarchy to avoid control conflicts.
        # 0 = Normal, 1 = Caution, 2 = Following (Proportional), 3 = Emergency/STOP
        current_priority = 0

        # 2. Process confirmed detections.
        for det in confirmed_detections:
            h = round(det.ymax - det.ymin, 3)

            # --- PRIORITY 3: FULL STOP / EMERGENCY ---
            if det.label in ["gate", "traffic_light_red"] and h > cfg.H_STOP:
                if current_priority <= 3:
                    temp_target = 0
                    reason = f"STOP({det.label})"
                    current_priority = 3

            elif det.label == "stop_sign" and h > cfg.H_STOP:
                # Only schedule a new stop if not in post-stop immunity.
                if now - self.last_stop_time > 6.0:
                    if current_priority <= 3:
                        # Schedule the real stop 0.3s ahead to allow a short roll.
                        self.stop_at = now + 0.3
                        temp_target = cfg.PWM_SLOW
                        reason = "STOP_SIGN_DETECTED"
                        current_priority = 3
                else:
                    # Post-stop immunity active: keep the car slow to clear the sign area.
                    if current_priority < 1:
                        temp_target = min(temp_target, cfg.PWM_SLOW)
                        reason = "LEAVING_STOP_ZONE"
                        current_priority = 1

            elif det.label in ["car", "obstacle"] and h > cfg.H_EMERGENCY:
                if current_priority <= 3:
                    temp_target = 0
                    reason = f"EMERGENCY({det.label})"
                    current_priority = 3

            # --- PRIORITY 2: PROPORTIONAL FOLLOWING (Cars/Obstacles) ---
            elif det.label in ["car", "obstacle"] and h > 0.15:
                if current_priority < 2:
                    ratio = (h - 0.15) / (cfg.H_EMERGENCY - 0.15)
                    ratio = max(0.0, min(ratio, 1.0))

                    temp_target = min(temp_target, cfg.PWM_CRUISE - (cfg.PWM_CRUISE - cfg.PWM_SLOW) * ratio)
                    reason = f"FOLLOWING({det.label}_h={h})"
                    current_priority = 2

            # --- PRIORITY 1: CAUTION ZONES (Real progressive slowing on track) ---
            elif det.label in ["crosswalk_sign", "yield_sign", "danger_sign", "traffic_light_yellow", "stop_sign"]:
                if current_priority < 1:
                    # Start braking smoothly at h=0.07 down to PWM_SLOW (6).
                    h_start = 0.07
                    h_end = cfg.H_STOP if det.label == "stop_sign" else 0.25

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
                self.speed_limit = cfg.PWM_50  # FIX: Updated from PWM_CRUISE to PWM_50.
                self.limit_expiry = now + 10.0
            elif det.label == "80_sign":
                self.speed_limit = cfg.PWM_80  # FIX: Updated from PWM_HIGH to PWM_80.
                self.limit_expiry = now + 10.0
            elif det.label == "traffic_light_green":
                self.speed_limit = cfg.PWM_CRUISE

        # 3. Execute the adaptive PWM ramp.
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
        if now - self.last_log > 0.2:
            print(f"[FSM] PWM: {int(speed):02d} -> Target: {int(target_frame):02d} | Reason: {reason}")
            self.last_log = now
