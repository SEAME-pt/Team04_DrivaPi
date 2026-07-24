"""Runs Hailo inference and streams annotated frames with PWM control output."""

from __future__ import annotations

from typing import Tuple

import logging
import cv2
import numpy as np
import subprocess
import time
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer
from socketserver import ThreadingMixIn
from hailo_platform import (VDevice, HEF, ConfigureParams, InferVStreams,
                            InputVStreamParams, OutputVStreamParams,
                            FormatType, HailoStreamInterface)

from obstacle.hailo_config import HailoConfig as cfg
from obstacle.drivapi_brain import DrivaPiBrain, Detection
from globals import npu_lock, REPORT_EVERY


output_frame = None
lock = threading.Lock()
shutdown_event = threading.Event()
logger = logging.getLogger(__name__)

def sigmoid(x: np.ndarray) -> np.ndarray:
    """Numerically stable sigmoid for tensor values."""

    return 1 / (1 + np.exp(-np.clip(x, -20, 20)))


def build_yolo_grid() -> Tuple[np.ndarray, np.ndarray]:
    """Build YOLOv8 grid centers and stride array."""

    strides = [8, 16, 32]
    grid_sizes = [(80, 80), (40, 40), (20, 20)]
    grid_centers, stride_array = [], []
    for (h, w), stride in zip(grid_sizes, strides):
        for i in range(h):
            for j in range(w):
                grid_centers.append([(j + 0.5) * stride, (i + 0.5) * stride])
                stride_array.append(stride)
    return np.array(grid_centers), np.array(stride_array)


class DrivaPiInference:
    """Runs Hailo inference on frames provided by a shared pipeline and forwards detections."""

    def __init__(self) -> None:
        self.brain = DrivaPiBrain()
        self.centers, self.strides = build_yolo_grid()

    def start(self, source, debug, record_path, in_name, get_frame, network_group, in_p, out_p, thread_nbr):
        """Serves as the main loop for the obstacle thread pipeline."""
        print(f"Obstacle Thread {thread_nbr} started | mode: {'DEBUG' if debug else 'HEADLESS'}")
        global output_frame

        frame_budget = 1.0 / 5.0  # ~33.3ms budget per frame
        last_metrics_time = time.time()
        frames_since_metrics = 0
        last_detection_count = 0
        batch_start_time = time.time()

        time.sleep(1)
        n = 0
        try:
            with InferVStreams(network_group, in_p, out_p) as pipeline:
                while not shutdown_event.is_set():
                    t0 = time.time()
                    frame = get_frame()
                    if frame is None:
                        break
                    t1 = time.time()

                    cam_h, cam_w = frame.shape[:2]

                    # Preprocess frame matching your model requirement (640x640)
                    resized = cv2.resize(frame, (640, 640))
                    input_data = np.expand_dims(resized.astype(np.float32) / 255.0, axis=0)

                    # Protect the physical hardware transit loop
                    with npu_lock:
                        with network_group.activate():
                            t2  = time.time()
                            results = pipeline.infer({in_name: input_data})

                    # Process the raw results inside the class context
                    slice1 = results['yolo26_v9/slice1'][0, 0]
                    slice2 = results['yolo26_v9/slice2'][0, 0]
                    raw_scores = results['yolo26_v9/activation3'][0, 0]

                    probs = raw_scores if (np.max(raw_scores) <= 1.0) else sigmoid(raw_scores)
                    max_scores = np.max(probs, axis=1)
                    class_ids = np.argmax(probs, axis=1)

                    valid_indices = np.where(max_scores > cfg.CONFIDENCE_THRESHOLD)[0]

                    boxes_for_nms, scores_for_nms, classes_for_nms = [], [], []
                    normalized_y_bounds = []

                    for idx in valid_indices:
                        d_left, d_top = slice1[idx]
                        d_right, d_bottom = slice2[idx]
                        cx, cy = self.centers[idx]
                        stride = self.strides[idx]

                        x_min_640 = cx - (d_left * stride)
                        y_min_640 = cy - (d_top * stride)
                        x_max_640 = cx + (d_right * stride)
                        y_max_640 = cy + (d_bottom * stride)

                        x_f = int((x_min_640 / 640.0) * cam_w)
                        y_f = int((y_min_640 / 640.0) * cam_h)
                        w_f = int(((x_max_640 - x_min_640) / 640.0) * cam_w)
                        h_f = int(((y_max_640 - y_min_640) / 640.0) * cam_h)

                        if w_f <= 0 or h_f <= 0:
                            continue

                        boxes_for_nms.append([x_f, y_f, w_f, h_f])
                        scores_for_nms.append(float(max_scores[idx]))
                        classes_for_nms.append(class_ids[idx])
                        normalized_y_bounds.append((float(y_min_640 / 640.0), float(y_max_640 / 640.0)))

                    indices = cv2.dnn.NMSBoxes(
                        boxes_for_nms,
                        scores_for_nms,
                        cfg.NMS_SCORE_THRESHOLD,
                        cfg.NMS_IOU_THRESHOLD,
                    )

                    detections = []
                    if len(indices) > 0:
                        for i in indices.flatten():
                            x, y, w, h = boxes_for_nms[i]
                            cid = classes_for_nms[i]
                            label = cfg.CLASSES[cid]
                            conf = scores_for_nms[i]

                            y_min_norm, y_max_norm = normalized_y_bounds[i]
                            detections.append(Detection(label, y_min_norm, y_max_norm, conf))

                            cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
                            cv2.putText(frame, f"{label} {conf:.2f}", (x, y - 10), 1, 1, (0, 255, 0), 2)
                    with lock:
                        output_frame = frame.copy()

                    self.brain.process_detections(detections)

                    last_detection_count = len(detections)
                    frames_since_metrics += 1

                    # Performance metric evaluation
                    now = time.time()
                    elapsed_metrics = now - last_metrics_time
                    if elapsed_metrics >= cfg.METRICS_INTERVAL_SEC:
                        fps = frames_since_metrics / elapsed_metrics
                        logger.info(
                            "metrics thread=%d state=inference fps=%.1f detections=%d",
                            thread_nbr, fps, last_detection_count,
                        )
                        last_metrics_time = now
                        frames_since_metrics = 0

                    t_last = time.time()
                    n += 1
                    if n % REPORT_EVERY == 0:
                        total_batch_time = t_last - batch_start_time 

                        fps = REPORT_EVERY / total_batch_time if total_batch_time > 0 else 0.0

                        t_frame  = (t1 - t0) * 1000
                        t_pre = (t2 - t1) * 1000
                        #t_npu = (t3 - t2) * 1000
                        #t_post = (t4 - t3) * 1000
                        #t_stanley = (t5 - t4) * 1000
                        t_total = (t_last - t0) * 1000

                        #print(f"Thread {thread_nbr} | {fps:5.1f} AVG FPS | total current time {t_total:.1f}ms "
                        #    f"| Frame {t_frame:.1f} | Pre {t_pre:.1f}")
                            #| Infer {t_npu:.1f} | Post {t_post:.1f} | Stanley {t_stanley:.1f}")

                        batch_start_time = time.time()

                    elapsed_time = time.time() - t0            
                    if elapsed_time < frame_budget:
                        time.sleep(frame_budget - elapsed_time)
                    else:
                        time.sleep(0.001)

        except KeyboardInterrupt:
            print("\nStopping Obstacle Thread...")
        finally:
            print("Cleaning up Obstacle Thread...")
