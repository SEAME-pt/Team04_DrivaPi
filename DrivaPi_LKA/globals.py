

import threading

npu_lock = threading.Lock()
REPORT_EVERY = 30
FRAME_BUDGET = 1.0 / 60.0
