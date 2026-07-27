import mmap
import struct
import os
import time

# f: float (4 bytes)
# B: unsigned char (1 byte)
# Q: unsigned long long (8 bytes)
# Padding might be needed to match C struct alignment
# PerceptionOutput {
#    float cte;            // 0
#    float heading_error;  // 4
#    float confidence;     // 8
#    uint8_t valid;        // 12
#    // 7 bytes padding here?
#    uint64_t timestamp;   // 24 (if 8-byte aligned)
# }
# However, standard Python struct "fffBQ" might not match C alignment exactly without '=' or '@'
# Let's use "@" for native alignment or "=" for no alignment. 
# C struct usually aligns uint64_t to 8 bytes.
# fffB (4+4+4+1 = 13). 
# Next is uint64_t (8). It will likely be at offset 16 or 24.
# If we use "fffBQ", the size is 4+4+4+1+8 = 21 (without padding).
# If we want it to match a standard C struct on 64-bit:
# offset 0: cte
# offset 4: heading_error
# offset 8: confidence
# offset 12: valid
# offset 13-15: padding (3 bytes) if uint64_t is 4-byte aligned? No, uint64_t is 8-byte aligned usually.
# So offset 16: timestamp. Total size 24.
# Let's use "fffBxxxQ" to be explicit about 24 bytes and alignment.

FMT = "fffBxxxQ" 
SIZE = struct.calcsize(FMT)

class SharedMemoryPublisher:
    def __init__(self, path="/dev/shm/perception.buf"):
        self.fd = os.open(path, os.O_CREAT | os.O_RDWR)
        os.ftruncate(self.fd, SIZE)
        self.mm = mmap.mmap(self.fd, SIZE)
        self.preview_shm = None  # or existing shm system

    def publish(self, cte, heading_error, confidence, valid):
        payload = struct.pack(
            FMT,
            float(cte),
            float(heading_error),
            float(confidence),
            int(valid),
            time.time_ns()
        )

        self.mm.seek(0)
        self.mm.write(payload)
        self.mm.flush()

if __name__ == "__main__":
    # Test
    pub = SharedMemoryPublisher()
    while True:
        pub.publish(1.0, 0.5, 0.9, 1)
        print("Published test data")
        time.sleep(1)
