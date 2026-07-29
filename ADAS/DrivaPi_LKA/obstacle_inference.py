"""Runs Hailo inference and forwards obstacle detections to the ADAS decision layer."""

from __future__ import annotations

import logging
import threading
import time
from typing import Tuple

import cv2
import numpy as np
from hailo_platform import InferVStreams

from globals import REPORT_EVERY, npu_lock
from obstacle.drivapi_brain import Detection, DrivaPiBrain
from obstacle.hailo_config import HailoConfig as cfg

output_frame = None
lock = threading.Lock()
shutdown_event = threading.Event()
logger = logging.getLogger(__name__)


def sigmoid(values: np.ndarray) -> np.ndarray:
    """Numerically stable sigmoid for tensor values."""
    return 1 / (1 + np.exp(-np.clip(values, -20, 20)))


def build_yolo_grid() -> Tuple[np.ndarray, np.ndarray]:
    """Build YOLO grid centres and stride array."""
    strides = [8, 16, 32]
    grid_sizes = [(80, 80), (40, 40), (20, 20)]
    grid_centres = []
    stride_array = []

    for (height, width), stride in zip(grid_sizes, strides):
        for row in range(height):
            for column in range(width):
                grid_centres.append(
                    [
                        (column + 0.5) * stride,
                        (row + 0.5) * stride,
                    ]
                )
                stride_array.append(stride)

    return np.array(grid_centres), np.array(stride_array)


class DrivaPiInference:
    """Run Hailo inference on frames and forward normalized detections."""

    def __init__(self) -> None:
        self.brain = DrivaPiBrain()
        self.centers, self.strides = build_yolo_grid()

    def start(
        self,
        source,
        debug,
        record_path,
        in_name,
        get_frame,
        network_group,
        in_p,
        out_p,
        thread_nbr,
    ):
        """Serve as the main loop for the obstacle inference thread."""
        print(
            f"Obstacle Thread {thread_nbr} started | "
            f"mode: {'DEBUG' if debug else 'HEADLESS'}"
        )

        global output_frame

        frame_budget = 1.0 / 5.0
        last_metrics_time = time.time()
        frames_since_metrics = 0
        last_detection_count = 0
        batch_start_time = time.time()

        time.sleep(1)
        frame_number = 0

        try:
            with InferVStreams(network_group, in_p, out_p) as pipeline:
                while not shutdown_event.is_set():
                    frame_start = time.time()
                    frame = get_frame()

                    if frame is None:
                        break

                    frame_read_time = time.time()
                    camera_height, camera_width = frame.shape[:2]

                    # Preprocess frame to match the model input size.
                    resized = cv2.resize(frame, (640, 640))
                    input_data = np.expand_dims(
                        resized.astype(np.float32) / 255.0,
                        axis=0,
                    )

                    # Protect access to the physical NPU.
                    with npu_lock:
                        with network_group.activate():
                            inference_start = time.time()
                            results = pipeline.infer(
                                {in_name: input_data}
                            )

                    slice1 = results[cfg.OUT_SLICE1][0, 0]
                    slice2 = results[cfg.OUT_SLICE2][0, 0]
                    raw_scores = results[cfg.OUT_ACT3][0, 0]

                    probs = (
                        raw_scores
                        if np.max(raw_scores) <= 1.0
                        else sigmoid(raw_scores)
                    )
                    max_scores = np.max(probs, axis=1)
                    class_ids = np.argmax(probs, axis=1)
                    valid_indices = np.where(
                        max_scores > cfg.CONFIDENCE_THRESHOLD
                    )[0]

                    boxes_for_nms = []
                    scores_for_nms = []
                    classes_for_nms = []
                    normalized_bounds = []

                    for index in valid_indices:
                        d_left, d_top = slice1[index]
                        d_right, d_bottom = slice2[index]

                        center_x, center_y = self.centers[index]
                        stride = self.strides[index]

                        xmin_640 = center_x - d_left * stride
                        ymin_640 = center_y - d_top * stride
                        xmax_640 = center_x + d_right * stride
                        ymax_640 = center_y + d_bottom * stride

                        # Clamp the normalized box before using it for
                        # NMS, drawing, or control decisions.
                        xmin_norm = max(
                            0.0,
                            min(float(xmin_640 / 640.0), 1.0),
                        )
                        ymin_norm = max(
                            0.0,
                            min(float(ymin_640 / 640.0), 1.0),
                        )
                        xmax_norm = max(
                            0.0,
                            min(float(xmax_640 / 640.0), 1.0),
                        )
                        ymax_norm = max(
                            0.0,
                            min(float(ymax_640 / 640.0), 1.0),
                        )

                        if xmax_norm <= xmin_norm or ymax_norm <= ymin_norm:
                            continue

                        x = int(xmin_norm * camera_width)
                        y = int(ymin_norm * camera_height)
                        width = int(
                            (xmax_norm - xmin_norm) * camera_width
                        )
                        height = int(
                            (ymax_norm - ymin_norm) * camera_height
                        )

                        if width <= 0 or height <= 0:
                            continue

                        boxes_for_nms.append([x, y, width, height])
                        scores_for_nms.append(
                            float(max_scores[index])
                        )
                        classes_for_nms.append(
                            int(class_ids[index])
                        )
                        normalized_bounds.append(
                            (
                                xmin_norm,
                                ymin_norm,
                                xmax_norm,
                                ymax_norm,
                            )
                        )

                    # Run NMS independently for each class so overlapping
                    # detections of different classes do not suppress each other.
                    kept_indices = []

                    for class_id in sorted(set(classes_for_nms)):
                        source_indices = [
                            index
                            for index, current_class_id
                            in enumerate(classes_for_nms)
                            if current_class_id == class_id
                        ]

                        class_boxes = [
                            boxes_for_nms[index]
                            for index in source_indices
                        ]
                        class_scores = [
                            scores_for_nms[index]
                            for index in source_indices
                        ]

                        class_nms_indices = cv2.dnn.NMSBoxes(
                            class_boxes,
                            class_scores,
                            cfg.NMS_SCORE_THRESHOLD,
                            cfg.NMS_IOU_THRESHOLD,
                        )

                        if len(class_nms_indices) > 0:
                            for local_index in np.asarray(
                                class_nms_indices
                            ).reshape(-1):
                                kept_indices.append(
                                    source_indices[int(local_index)]
                                )

                    detections = []

                    for index in kept_indices:
                        x, y, width, height = boxes_for_nms[index]
                        class_id = classes_for_nms[index]
                        label = cfg.CLASSES[class_id]
                        confidence = scores_for_nms[index]

                        (
                            xmin_norm,
                            ymin_norm,
                            xmax_norm,
                            ymax_norm,
                        ) = normalized_bounds[index]

                        detections.append(
                            Detection(
                                label=label,
                                xmin=xmin_norm,
                                ymin=ymin_norm,
                                xmax=xmax_norm,
                                ymax=ymax_norm,
                                confidence=confidence,
                            )
                        )

                        if debug:
                            cv2.rectangle(
                                frame,
                                (x, y),
                                (x + width, y + height),
                                (0, 255, 0),
                                2,
                            )
                            cv2.putText(
                                frame,
                                f"{label} {confidence:.2f}",
                                (x, max(0, y - 10)),
                                cv2.FONT_HERSHEY_SIMPLEX,
                                0.6,
                                (0, 255, 0),
                                2,
                            )

                    if debug:
                        with lock:
                            output_frame = frame.copy()

                    self.brain.process_detections(detections)

                    last_detection_count = len(detections)
                    frames_since_metrics += 1

                    now = time.time()
                    elapsed_metrics = now - last_metrics_time

                    if elapsed_metrics >= cfg.METRICS_INTERVAL_SEC:
                        fps = frames_since_metrics / elapsed_metrics
                        logger.info(
                            "metrics thread=%d state=inference "
                            "fps=%.1f detections=%d",
                            thread_nbr,
                            fps,
                            last_detection_count,
                        )
                        last_metrics_time = now
                        frames_since_metrics = 0

                    frame_end = time.time()
                    frame_number += 1

                    if frame_number % REPORT_EVERY == 0:
                        batch_time = frame_end - batch_start_time
                        fps = (
                            REPORT_EVERY / batch_time
                            if batch_time > 0
                            else 0.0
                        )
                        frame_time_ms = (
                            frame_read_time - frame_start
                        ) * 1000
                        preprocess_and_wait_ms = (
                            inference_start - frame_read_time
                        ) * 1000
                        total_time_ms = (
                            frame_end - frame_start
                        ) * 1000

                        print(
                            f"Thread {thread_nbr} | "
                            f"{fps:5.1f} AVG FPS | "
                            f"total {total_time_ms:.1f}ms | "
                            f"Frame {frame_time_ms:.1f} | "
                            f"Pre/Wait {preprocess_and_wait_ms:.1f}",
                            flush=True,
                        )
                        batch_start_time = time.time()

                    elapsed_time = time.time() - frame_start

                    if elapsed_time < frame_budget:
                        time.sleep(frame_budget - elapsed_time)
                    else:
                        time.sleep(0.001)

        except KeyboardInterrupt:
            print("\nStopping Obstacle Thread...")
        finally:
            print("Cleaning up Obstacle Thread...")
