import threading
import time
import subprocess
import numpy as np
import cv2

class CameraStream:
    def __init__(self, source=None, cam_w=1280, cam_h=720):
        self.source = source
        self.cam_w = cam_w
        self.cam_h = cam_h
        
        self.front_buffer = None
        self.back_buffer = None
        
        self.running = True
        self.lock = threading.Lock()
        self.proc = None
        self.cap = None
        if self.source:
            self.cap = cv2.VideoCapture(self.source)
        else:
            self.proc = subprocess.Popen(
                ["rpicam-vid", "-t", "0", "--codec", "yuv420", "--width", str(self.cam_w),
                 "--height", str(self.cam_h), "--framerate", "30", "-o", "-", "--nopreview", "--rotation", "180"],
                stdout=subprocess.PIPE, stderr=subprocess.DEVNULL
            )
            time.sleep(0.5)
            self.nbytes = self.cam_w * self.cam_h * 3 // 2

        self.thread = threading.Thread(target=self._capture_loop, daemon=True)
        self.thread.start()

    def _read_exact(self, n):
        buf = b""
        while len(buf) < n:
            chunk = self.proc.stdout.read(n - len(buf))
            if not chunk:
                return None
            buf += chunk
        return buf

    def _capture_loop(self):
        while self.running:
            if self.source:
                ok, f = self.cap.read()
                if ok:
                    self.back_buffer = f
            else:
                raw = self._read_exact(self.nbytes)
                if raw is None:
                    self.running = False
                    return
                if len(raw) == self.nbytes:
                    yuv = np.frombuffer(raw, dtype=np.uint8).reshape((self.cam_h * 3 // 2, self.cam_w))
                    self.back_buffer = cv2.cvtColor(yuv, cv2.COLOR_YUV2BGR_I420)
                else:
                    self.running = False

            if self.back_buffer is not None:
                with self.lock:
                    self.front_buffer = self.back_buffer
            
            time.sleep(0.001)

    def get_frame(self):
        with self.lock:
            if self.front_buffer is not None:
                return self.front_buffer.copy()
            return None

    def close(self):
        self.running = False
        if self.thread.is_alive():
            self.thread.join(timeout=1.0)
        if self.cap:
            self.cap.release()
        if self.proc:
            self.proc.terminate()
