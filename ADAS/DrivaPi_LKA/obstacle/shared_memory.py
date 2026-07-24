import mmap
import struct
import os
import time

# ObstacleOutput {
#    uint8_t sign_detected;  // offset 0
#    // 3 bytes padding (float needs 4-byte alignment)
#    float   confidence;     // offset 4
# }  -> total size 8 bytes

FMT = "Bxxxf"
SIZE = struct.calcsize(FMT)


class ObstaclePublisher:
    def __init__(self, path="/dev/shm/obstacle.buf"):
        self.fd = os.open(path, os.O_CREAT | os.O_RDWR)
        os.ftruncate(self.fd, SIZE)
        self.mm = mmap.mmap(self.fd, SIZE)

    def publish(self, sign_detected, confidence):
        payload = struct.pack(
            FMT,
            int(sign_detected),
            float(confidence),
        )
        self.mm.seek(0)
        self.mm.write(payload)
        self.mm.flush()


if __name__ == "__main__":
    # Test
    pub = ObstaclePublisher()
    while True:
        pub.publish(1, 0.92)
        print("Published test data")
        time.sleep(1)