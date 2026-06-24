
TEMPORAL_MAX_AGE = 5
NUM_CLASSES = 5

class LaneMemory:
    def __init__(self, max_age=TEMPORAL_MAX_AGE):
        self.max_age = max_age
        self.store = {}

    def update(self, class_masks):
        out = {}
        
        for c in range(NUM_CLASSES):
            if c in class_masks:
                # fresh detection = high confidence
                self.store[c] = [class_masks[c], 0, 1.0]
                out[c] = class_masks[c]
            elif c in self.store:
                mask, age, conf = self.store[c]
                age += 1
                conf *= 0.85 # decay
                
                if age < self.max_age:
                    self.store[c] = [mask, age, conf]
                    out[c] = mask
                else:
                    del self.store[c]
        return out
