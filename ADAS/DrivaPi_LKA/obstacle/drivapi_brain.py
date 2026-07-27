"""
ADAS decision layer: translates YOLO detections into deterministic control states.
Integrates an asymmetric filter, hazard decay, defensive clamping, and command priorities.
"""

from __future__ import annotations

import logging
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from kuksa_client.grpc import Datapoint
from kuksa_client.grpc import VSSClient

from .hailo_config import HailoConfig as cfg
from .shared_memory import ObstaclePublisher

logger = logging.getLogger(__name__)


@dataclass
class Detection:
    """Represents a normalized YOLO detection."""

    label: str
    xmin: float
    ymin: float
    xmax: float
    ymax: float
    confidence: float


class PersistenceTracker:
    """Reacts on the first frame and decays the hazard if the sensor drops."""

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
                height = self.active_det.ymax - self.active_det.ymin
                self.active_det = Detection(
                    label=self.active_det.label,
                    xmin=self.active_det.xmin,
                    ymin=self.active_det.ymin,
                    xmax=self.active_det.xmax,
                    ymax=(
                        self.active_det.ymin
                        + height * cfg.HAZARD_DECAY_HEIGHT_SCALE
                    ),
                    confidence=(
                        self.active_det.confidence
                        * cfg.HAZARD_DECAY_CONF_SCALE
                    ),
                )

            return True

        self.active_det = None
        return False


class DrivaPiBrain:
    """Translates detections into control states and publishes them to shared memory and KUKSA."""

    # Temporary normalized driving corridor used only for car/obstacle decisions.
    # These values should be calibrated on the real camera image.
    DRIVING_ROI_X_MIN = 0.25
    DRIVING_ROI_X_MAX = 0.75

    def __init__(self) -> None:
        self.current_pwm = 0.0
        self.speed_limit = cfg.PWM_CRUISE
        self.limit_expiry = 0.0

        # Smart STOP handling.
        self.stop_at = 0.0
        self.last_stop_time = 0.0

        # Tracker allocation.
        self.trackers: dict[str, PersistenceTracker] = {}
        for label in cfg.CLASSES:
            hold_frames = (
                cfg.TRACKER_HOLD_FRAMES_CRITICAL
                if label in cfg.CRITICAL_TRACKER_LABELS
                else cfg.TRACKER_HOLD_FRAMES_DEFAULT
            )
            self.trackers[label] = PersistenceTracker(hold_frames=hold_frames)

        # KUKSA Databroker initialization.
        self.last_published_class = -1
        try:
            self.vss_client = VSSClient(
                "127.0.0.1",
                55555,
                root_certificates=Path("/etc/kuksa/ca.crt"),
            )
            self.vss_client.connect()
            logger.info("Successfully connected to KUKSA Databroker via gRPC.")
        except Exception as exc:
            logger.error("Failed to connect to KUKSA Databroker: %s", exc)
            self.vss_client = None

        self.accel_rate = cfg.ACCEL_RATE
        self.decel_rate = cfg.DECEL_RATE
        self.publisher = ObstaclePublisher()

    @staticmethod
    def _detection_height(det: Detection) -> float:
        """Return the normalized detection height with defensive clamping."""
        ymin = max(0.0, min(det.ymin, 1.0))
        ymax = max(0.0, min(det.ymax, 1.0))
        return max(0.0, ymax - ymin)

    def _is_in_driving_path(self, det: Detection) -> bool:
        """Return whether the detection centre is inside the temporary driving corridor."""
        xmin = max(0.0, min(det.xmin, 1.0))
        xmax = max(0.0, min(det.xmax, 1.0))

        if xmax <= xmin:
            return False

        center_x = (xmin + xmax) * 0.5
        return self.DRIVING_ROI_X_MIN <= center_x <= self.DRIVING_ROI_X_MAX

    def process_detections(self, detections: Iterable[Detection]) -> None:
        """Update hazard state and publish the resulting control state."""
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

            # If several detections share a label, keep the closest/largest one.
            previous_height = self._detection_height(previous)
            current_height = self._detection_height(det)

            if current_height > previous_height:
                detected_by_label[det.label] = det

        confirmed_detections: list[Detection] = []

        for label in cfg.CLASSES:
            current_det = detected_by_label.get(label)

            if self.trackers[label].update(current_det is not None, current_det):
                valid_det = (
                    current_det
                    if current_det is not None
                    else self.trackers[label].active_det
                )
                if valid_det:
                    confirmed_detections.append(valid_det)

        temp_target = float(self.speed_limit)
        reason = "NORMAL"

        # Explicit priority hierarchy:
        # 0 = Normal
        # 1 = Caution
        # 2 = Following / STOP approach
        # 3 = Full stop / emergency
        current_priority = 0

        # 2. Apply active STOP sequence as a control state.
        stop_sequence_active = self.stop_at > 0.0
        stop_approach_active = False
        stop_timer_active = False

        if self.stop_at > 0.0:
            if now < self.stop_at:
                temp_target = min(temp_target, cfg.PWM_SLOW)
                reason = "APPROACHING_STOP_LINE"
                current_priority = 2
                stop_approach_active = True

            elif now < self.stop_at + cfg.STOP_DURATION_SEC:
                temp_target = 0
                reason = "STOP_TIMER_ACTIVE"
                current_priority = 3
                stop_timer_active = True

            else:
                logger.info("state=stop_completed")
                self.last_stop_time = now
                self.stop_at = 0.0
                stop_sequence_active = False

        # 3. Process confirmed detections.
        for det in confirmed_detections:
            height = round(self._detection_height(det), 3)
            is_vehicle_hazard = det.label in ("car", "obstacle")
            is_in_driving_path = (
                self._is_in_driving_path(det)
                if is_vehicle_hazard
                else True
            )

            # PRIORITY 3: Full stop / emergency.
            if det.label in ("gate", "traffic_light_red") and height > cfg.H_STOP:
                temp_target = 0
                reason = f"STOP({det.label})"
                current_priority = 3

            elif (
                is_vehicle_hazard
                and is_in_driving_path
                and height > cfg.H_EMERGENCY
            ):
                temp_target = 0
                reason = f"EMERGENCY({det.label})"
                current_priority = 3

            elif det.label == "stop_sign" and height > cfg.H_STOP:
                # Do not reschedule the same STOP while its sequence is active.
                if (
                    stop_sequence_active
                    or stop_approach_active
                    or stop_timer_active
                ):
                    continue

                if now - self.last_stop_time > cfg.STOP_COOLDOWN_SEC:
                    if current_priority < 3:
                        self.stop_at = now + cfg.STOP_DELAY_SEC
                        temp_target = min(temp_target, cfg.PWM_SLOW)
                        reason = "STOP_SIGN_DETECTED"
                        current_priority = 2
                else:
                    candidate_target = float(cfg.PWM_SLOW)
                    if (
                        current_priority < 1
                        or (
                            current_priority == 1
                            and candidate_target < temp_target
                        )
                    ):
                        temp_target = min(temp_target, candidate_target)
                        reason = "LEAVING_STOP_ZONE"
                        current_priority = 1

            # PRIORITY 2: Proportional following.
            elif (
                is_vehicle_hazard
                and is_in_driving_path
                and height > cfg.FOLLOWING_START_H
            ):
                denominator = cfg.H_EMERGENCY - cfg.FOLLOWING_START_H
                ratio = (
                    (height - cfg.FOLLOWING_START_H) / denominator
                    if denominator > 0
                    else 1.0
                )
                ratio = max(0.0, min(ratio, 1.0))

                following_pwm = (
                    cfg.PWM_CRUISE
                    - (cfg.PWM_CRUISE - cfg.PWM_SLOW) * ratio
                )

                if (
                    current_priority < 2
                    or (
                        current_priority == 2
                        and following_pwm < temp_target
                    )
                ):
                    temp_target = min(temp_target, following_pwm)
                    reason = f"FOLLOWING({det.label}_h={height})"
                    current_priority = 2

            # PRIORITY 1: Caution zones.
            elif det.label in (
                "crosswalk_sign",
                "yield_sign",
                "danger_sign",
                "traffic_light_yellow",
                "stop_sign",
            ):
                h_start = cfg.CAUTION_START_H
                h_end = (
                    cfg.H_STOP
                    if det.label == "stop_sign"
                    else cfg.CAUTION_END_H
                )

                if height >= h_start:
                    denominator = h_end - h_start
                    ratio = (
                        (height - h_start) / denominator
                        if denominator > 0
                        else 1.0
                    )
                    ratio = max(0.0, min(ratio, 1.0))

                    caution_pwm = (
                        cfg.PWM_CRUISE
                        - (cfg.PWM_CRUISE - cfg.PWM_SLOW) * ratio
                    )

                    if (
                        current_priority < 1
                        or (
                            current_priority == 1
                            and caution_pwm < temp_target
                        )
                    ):
                        temp_target = min(temp_target, caution_pwm)
                        reason = f"CAUTION({det.label}_h={height})"
                        current_priority = 1

            # PRIORITY 0: Baseline changes.
            elif det.label == "50_sign":
                self.speed_limit = cfg.PWM_50
                self.limit_expiry = now + cfg.SPEED_LIMIT_DURATION_SEC
                temp_target = min(temp_target, float(self.speed_limit))

            elif det.label == "80_sign":
                self.speed_limit = cfg.PWM_80
                self.limit_expiry = now + cfg.SPEED_LIMIT_DURATION_SEC
                temp_target = min(temp_target, float(self.speed_limit))

            elif det.label == "traffic_light_green":
                self.speed_limit = cfg.PWM_CRUISE

        # 4. Execute the adaptive PWM ramp.
        if self.current_pwm < temp_target:
            self.current_pwm = min(
                self.current_pwm + self.accel_rate,
                temp_target,
            )
        elif self.current_pwm > temp_target:
            if temp_target == 0:
                self.current_pwm = 0
            else:
                self.current_pwm = max(
                    self.current_pwm - self.decel_rate,
                    temp_target,
                )

        # Shared memory is the control communication mechanism.
        self.publish_control_state(reason)

        # 5. Publish UI state to KUKSA.
        self.publish_adas_to_kuksa(confirmed_detections)

    def publish_control_state(self, reason: str) -> None:
        """Publish the current ADAS state to shared memory."""
        # ObstacleOutput status codes:
        # 0 = none
        # 1 = caution
        # 2 = following
        # 3 = STOP approach
        # 4 = STOP timer
        # 5 = emergency / full stop
        if reason == "NORMAL":
            signal_type = 0
        elif reason.startswith("EMERGENCY") or reason.startswith("STOP("):
            signal_type = 5
        elif reason == "STOP_TIMER_ACTIVE":
            signal_type = 4
        elif reason in ("STOP_SIGN_DETECTED", "APPROACHING_STOP_LINE"):
            signal_type = 3
        elif reason.startswith("FOLLOWING"):
            signal_type = 2
        elif reason.startswith("CAUTION") or reason == "LEAVING_STOP_ZONE":
            signal_type = 1
        else:
            signal_type = 0

        self.publisher.publish(signal_type, 1.0)

    def publish_adas_to_kuksa(
        self,
        confirmed_detections: list[Detection],
    ) -> None:
        """Determine the most critical UI element and publish it to KUKSA."""
        if not self.vss_client:
            return

        target_class_id = 0  # 0 = Clear / No Hazard
        best_det: Detection | None = None

        if confirmed_detections:
            ui_priority = [
                "stop_sign",
                "car",
                "obstacle",
                "gate",
                "danger_sign",
                "traffic_light_red",
                "crosswalk_sign",
                "yield_sign",
                "traffic_light_yellow",
                "50_sign",
                "80_sign",
                "traffic_light_green",
                "traffic_light_off",
            ]

            sorted_detections = sorted(
                confirmed_detections,
                key=lambda det: (
                    ui_priority.index(det.label)
                    if det.label in ui_priority
                    else 99
                ),
            )
            best_det = sorted_detections[0]

            try:
                # Reserve zero for Clear / No Hazard.
                target_class_id = cfg.CLASSES.index(best_det.label) + 1
            except ValueError:
                target_class_id = 0
                best_det = None

        # Only publish if there is a change, to avoid gRPC flooding.
        if target_class_id == self.last_published_class:
            return

        try:
            self.vss_client.set_current_values(
                {
                    "Vehicle.ADAS.TrafficSignRecognition.CurrentSign":
                        Datapoint(target_class_id),
                }
            )
            self.last_published_class = target_class_id

            status_message = (
                best_det.label
                if best_det is not None
                else "Clear"
            )
            logger.info(
                "Published to KUKSA: ADAS Class ID %d (%s)",
                target_class_id,
                status_message,
            )
        except Exception as exc:
            logger.error("Failed to publish ADAS state to KUKSA: %s", exc)
