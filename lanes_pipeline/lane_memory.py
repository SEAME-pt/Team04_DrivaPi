
TEMPORAL_MAX_AGE = 5
NUM_CLASSES = 5

class LaneMemory:
    def __init__(self, max_age=TEMPORAL_MAX_AGE):
        self.max_age = max_age; self.store = {}

    def update(self, class_masks):
        out = {}
        for c in range(NUM_CLASSES):
            if c in class_masks:
                self.store[c] = [class_masks[c], 0]; out[c] = class_masks[c]
            elif c in self.store:
                mask, age = self.store[c]
                if age < self.max_age:
                    self.store[c][1] = age + 1; out[c] = mask
                else:
                    del self.store[c]
        return out