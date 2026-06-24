
import cv2
ROI_RATIO   = 0.35
MODEL_SIZE  = 640
WORK_SIZE   = MODEL_SIZE // 4
import numpy as np


def preprocess(frame_bgr, model_size, roi):
    # h = frame_bgr.shape[0]
    # frame_bgr = frame_bgr[int(h * roi):]
    # frame_bgr[: int(frame_bgr.shape[0] * roi)] = 0
    img = cv2.resize(frame_bgr, (model_size, model_size))
    return cv2.cvtColor(img, cv2.COLOR_BGR2RGB).astype(np.float32)[np.newaxis]
