
import argparse
import time
from pathlib import Path
import socket
import threading

from flask import Flask, Response


import cv2
import numpy as np
from lanes_pipeline.stanley import StanleyController
from lanes_pipeline.post_process import build_class_masks, decode, extract_lane_lines, draw_debug
from lanes_pipeline.preprocess import preprocess
from lanes_pipeline.lane_memory import LaneMemory
from obstacle_inference import DrivaPiInference
from ipc import SharedMemoryPublisher
from hailo_platform import (
    VDevice, HEF, ConfigureParams, HailoStreamInterface,
    InputVStreamParams, OutputVStreamParams, FormatType,
    HailoSchedulingAlgorithm,
    InferVStreams  # <-- Add this import
)
from camera import CameraStream
from globals import npu_lock, REPORT_EVERY, FRAME_BUDGET

import os
import socket

latest_debug_frame = None
debug_lock = threading.Lock()

app = Flask(__name__)

def generate():
    global latest_debug_frame

    while True:
        with debug_lock:
            frame = latest_debug_frame
            #frame = cv2.rotate(frame, cv2.ROTATE_180)


        if frame is None:
            time.sleep(0.01)
            continue

        frame = frame.copy()

        encode_params = [int(cv2.IMWRITE_JPEG_QUALITY), 70]
        _, jpeg = cv2.imencode('.jpg', frame, encode_params)

        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' +
               jpeg.tobytes() +
               b'\r\n')

@app.route('/video')
def video():
    return Response(generate(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/')
def index():
    return """
    <html>
        <body>
            <h2>Lane Stream</h2>
            <img src="/video"/>
        </body>
    </html>
    """

def systemd_notify_ready():
    """
    Sends a native READY=1 signal to systemd via the Unix notification socket.
    Safe to call outside of systemd (will exit silently if NOTIFY_SOCKET isn't set).
    """
    notify_socket = os.environ.get('NOTIFY_SOCKET')
    if not notify_socket:
        return  # Not running under systemd with Type=notify; exit quietly

    # Handle systemd's abstract socket namespace format (starts with '@')
    if notify_socket.startswith('@'):
        notify_socket = '\0' + notify_socket[1:]

    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM) as sock:
            sock.connect(notify_socket)
            sock.sendall(b'READY=1')
            print("[+] Sent READY=1 signal to systemd via native socket.")
    except Exception as e:
        print(f"[-] Native notify failed: {e}")

# ── Config ────────────────────────────────────────────────────────────────────
CAM_W, CAM_H = 1280, 720

def lanes_thread(source, debug, record_path, in_name, get_frame, network_group, in_p, out_p, thread_nbr):
    print("LANE THREAD STARTED")
    print(f"Lane Thread{thread_nbr} started | mode: {'DEBUG' if debug else 'HEADLESS'}", flush=True)
    publisher = SharedMemoryPublisher()
    memory = LaneMemory()
    stanley = StanleyController()
    writer = None
    n = 0
    global latest_debug_frame
    batch_start_time = time.time()

    time.sleep(1)
    try:
        if True:
            with InferVStreams(network_group, in_p, out_p) as pipeline:
                while True:
                    t0 = time.time()
                    frame = get_frame()

                    if frame is None:
                        break
                    #frame = cv2.rotate(frame, cv2.ROTATE_180)
                    h, w = frame.shape[:2]

                    t1 = time.time()
                    preprocessed_frame = preprocess(frame, 640, 0.35)

                    with npu_lock:
                        with network_group.activate():
                            t2 = time.time()
                            raw = pipeline.infer({in_name: preprocessed_frame})

                    t3 = time.time()
                    detections, proto = decode(raw)
                    class_masks = build_class_masks(detections, proto)
                    class_masks = memory.update(class_masks)
                    lane_lines = extract_lane_lines(class_masks, w, h)

                    debug_frame = frame.copy()
                    draw_debug(debug_frame, class_masks, lane_lines, None)


 
                    # cv2.imshow("Car View", debug_frame)
                    # cv2.waitKey(1)

                    with debug_lock:
                        latest_debug_frame = debug_frame.copy()


                    t4 = time.time()

                    cte, heading_error = None, None
                    stanley_result = stanley.compute_stanley_errors(lane_lines, w, h)

                    if stanley_result is not None:
                        cte, heading_error = stanley_result
                        publisher.publish(cte, heading_error, confidence=1.0, valid=1)
                    else:
                        publisher.publish(0.0, 0.0, confidence=0.0, valid=0)
                    t5 = time.time()

                    n += 1

                    elapsed_time = time.time() - t0
                    if elapsed_time < FRAME_BUDGET:
                        time.sleep(FRAME_BUDGET - elapsed_time)

                    t_last = time.time()

                    if n % REPORT_EVERY == 0:
                        total_batch_time = t_last - batch_start_time

                        fps = REPORT_EVERY / total_batch_time if total_batch_time > 0 else 0.0

                        t_frame  = (t1 - t0) * 1000
                        t_pre = (t2 - t1) * 1000
                        t_npu = (t3 - t2) * 1000
                        t_post = (t4 - t3) * 1000
                        t_stanley = (t5 - t4) * 1000
                        t_total = (t_last - t0) * 1000

                        print(f"Thread {thread_nbr} | {fps:5.1f} AVG FPS | total current time {t_total:.1f}ms "
                              f"| Frame {t_frame:.1f} | Pre {t_pre:.1f} | Infer {t_npu:.1f} | Post {t_post:.1f} | Stanley {t_stanley:.1f}", flush=True)

                        batch_start_time = time.time()

    except KeyboardInterrupt:
        print("\nStopping...", flush=True)
    finally:
        print("Cleaning up...", flush=True)
        if writer:
            writer.release()

def arg_parser():
    ap = argparse.ArgumentParser()
    ap.add_argument("--source", default=None, help="video file (omit for CSI camera)")
    ap.add_argument("--debug", action="store_true", help="draw masks/lines + show overlay")
    ap.add_argument("--record", default=None, help="(debug only) save annotated .avi")
    ap.add_argument("--lane-hef", default="lane.hef", help="path to lane model hef, default is lane.hef")
    ap.add_argument("--obstacle-hef", default="obstacle.hef", help="path to lane model hef, default is obstacle.hef")
    return ap.parse_args()

def preview_thread(camera):
    global preview_frame

    try:
        print("preview thread started")
        cv2.namedWindow("Lane Preview", cv2.WINDOW_NORMAL)

        while True:
            with preview_lock:
                frame = None if preview_frame is None else preview_frame.copy()

            print("frame is None =", frame is None)

            if frame is not None:
                print("showing preview")
                cv2.imshow("Lane Preview", frame)

            cv2.waitKey(1)
            time.sleep(0.01)

    except Exception as e:
        print("PREVIEW CRASHED: ", e)


def main():
    import time
    import threading

    args = arg_parser()

    cv2.namedWindow("Lane", cv2.WINDOW_NORMAL)
    cv2.setWindowProperty("Lane", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)

    lane_hef = HEF(str(args.lane_hef))
    lane_in_name = lane_hef.get_input_vstream_infos()[0].name
    lane_cfg = ConfigureParams.create_from_hef(lane_hef, interface=HailoStreamInterface.PCIe)


    obstacle_hef = HEF(str(args.obstacle_hef))
    obstacle_in_name = obstacle_hef.get_input_vstream_infos()[0].name
    obstacle_cfg = ConfigureParams.create_from_hef(obstacle_hef, interface=HailoStreamInterface.PCIe)

    print("[*] Instantiating Clean VDevice (No Scheduler)...", flush=True)
    params = VDevice.create_params()

    with VDevice(params=params) as target:
        print("[*] Configuring lane network...", flush=True)
        lane_network_groups = target.configure(lane_hef, lane_cfg)
        lane_ng = lane_network_groups[0]

        print("[*] Configuring obstacle network...", flush=True)
        obstacle_network_groups = target.configure(obstacle_hef, obstacle_cfg)
        obstacle_ng = obstacle_network_groups[0]

        camera = CameraStream(source=args.source, cam_w=CAM_W, cam_h=CAM_H)
        
        print("[*] Generating stream maps...")
        lane_in_p = InputVStreamParams.make(lane_ng, format_type=FormatType.FLOAT32)
        lane_out_p = OutputVStreamParams.make(lane_ng, format_type=FormatType.FLOAT32)
        obstacle_in_p = InputVStreamParams.make(obstacle_ng, format_type=FormatType.FLOAT32)
        obstacle_out_p = OutputVStreamParams.make(obstacle_ng, format_type=FormatType.FLOAT32)
        print("🚀 Launching threads! (Move .activate() contexts inside your loop functions)", flush=True)
        systemd_notify_ready()
        detector = DrivaPiInference()
        lanes_pipeline_thread = threading.Thread(
           target=lanes_thread,
           args=(args.source, args.debug, args.record, lane_in_name, camera.get_frame, lane_ng, lane_in_p, lane_out_p, 1)
        )
        obstacle_pipeline_thread = threading.Thread(
           target=detector.start,
           args=(args.source, args.debug, args.record, obstacle_in_name, camera.get_frame, obstacle_ng, obstacle_in_p, obstacle_out_p, 2)
        )

        lanes_pipeline_thread.start()
        obstacle_pipeline_thread.start()


        cv2.namedWindow("Lane", cv2.WINDOW_NORMAL)
        cv2.setWindowProperty("Lane", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
        
        while True:
            with debug_lock:
                frame = latest_debug_frame.copy() if latest_debug_frame is not None else None
                #frame = cv2.rotate(frame, cv2.ROTATE_180)

        
            if frame is not None:
                cv2.imshow("Lane", frame)
        
            key = cv2.waitKey(1)
            if key == 27:  # ESC
                break

        lanes_pipeline_thread.join()
        obstacle_pipeline_thread.join()

    camera.close()
    while True:
        time.sleep(1)
    return 0

if __name__ == "__main__":
    threading.Thread(
        target=lambda: app.run(
            host="0.0.0.0",
            port=5000,
            threaded=True,
            use_reloader=False
        ),
        daemon=True
    ).start()
    main()
