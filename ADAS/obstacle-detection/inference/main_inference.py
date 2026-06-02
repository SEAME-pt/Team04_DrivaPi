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

from hailo_config import HailoConfig as cfg
from drivapi_brain import DrivaPiBrain, Detection

output_frame = None
lock = threading.Lock()

class StreamHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'multipart/x-mixed-replace; boundary=frame')
            self.end_headers()
            while True:
                time.sleep(0.01)
                with lock:
                    if output_frame is None: continue
                    ok, img = cv2.imencode(".jpg", output_frame)
                if ok:
                    self.wfile.write(b'--frame\r\nContent-type: image/jpeg\r\n\r\n' + bytearray(img) + b'\r\n')

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer): pass

def sigmoid(x): return 1 / (1 + np.exp(-np.clip(x, -20, 20)))

def build_yolo_grid():
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
    def __init__(self):
        self.brain = DrivaPiBrain()
        self.vdevice = VDevice()
        self.hef = HEF(str(cfg.HEF_PATH))
        params = ConfigureParams.create_from_hef(self.hef, interface=HailoStreamInterface.PCIe)
        self.network_group = self.vdevice.configure(self.hef, params)[0]
        self.network_group_params = self.network_group.create_params()
        self.centers, self.strides = build_yolo_grid()

    def start(self):
        global output_frame
        cam_w, cam_h = 640, 480
        cmd = ["rpicam-vid", "-t", "0", "--codec", "yuv420", "--width", str(cam_w), "--height", str(cam_h), "-o", "-", "--nopreview", "--vflip", "--hflip"]
        camera = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
        
        input_params = InputVStreamParams.make(self.network_group, format_type=FormatType.FLOAT32)
        output_params = OutputVStreamParams.make(self.network_group, format_type=FormatType.FLOAT32)

        with InferVStreams(self.network_group, input_params, output_params) as pipeline:
            with self.network_group.activate(self.network_group_params):
                input_name = list(input_params.keys())[0]
                print(f"[*] Sistema ADAS em Pista Ativo. Proteções NMS Ativadas.")
                
                while True:
                    data = camera.stdout.read(cam_w * cam_h * 3 // 2)
                    if not data: break
                    yuv = np.frombuffer(data, dtype=np.uint8).reshape((cam_h * 3 // 2, cam_w))
                    frame = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
                    
                    resized = cv2.resize(frame, (640, 640))
                    results = pipeline.infer({input_name: np.expand_dims(resized.astype(np.float32)/255.0, axis=0)})
                    
                    # Mantido o mapeamento original estável v9 solicitado
                    slice1 = results['yolo26_v9/slice1'][0, 0]
                    slice2 = results['yolo26_v9/slice2'][0, 0]
                    raw_scores = results['yolo26_v9/activation3'][0, 0]

                    probs = raw_scores if (np.max(raw_scores) <= 1.0) else sigmoid(raw_scores)
                    max_scores = np.max(probs, axis=1)
                    class_ids = np.argmax(probs, axis=1)

                    valid_indices = np.where(max_scores > 0.20)[0]

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

                    # FIX CRÍTICO: Threshold do NMS baixado para 0.20 para evitar perda de frames válidos
                    indices = cv2.dnn.NMSBoxes(boxes_for_nms, scores_for_nms, 0.20, 0.40)

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

                    with lock: output_frame = frame.copy()
                    self.brain.process_detections(detections)

if __name__ == "__main__":
    try:
        detector = DrivaPiInference()
        server_thread = threading.Thread(
            target=ThreadedHTTPServer(('0.0.0.0', 8080), StreamHandler).serve_forever, 
            daemon=True
        )
        server_thread.start()
        detector.start()
    except KeyboardInterrupt:
        print("\n\n[*] Encerramento limpo solicitado pelo utilizador.")
