# Sensor Trade-off Analysis: Emergency Braking System (AEB)

## 1. Project Context
**Platform:** PiRacer Autonomous Vehicle Kit
* **Central Computer:** Raspberry Pi 5 (Navigation, Planning, User Interface)
* **Safety Critical Microcontroller:** STM32U585AI (Real-Time Control, Actuation, Sensor Fusion)
* **AI Accelerator:** Hailo AI Hat (Object Detection Inference)

**Objective:** Implement a robust **Emergency Braking** system. The system must detect obstacles with low latency and high reliability to override pilot commands and halt the vehicle to prevent collision.

## 2. The Contenders

### Option A: SRF08 Ultrasonic Ranger
A classic ultrasonic transducer that calculates distance based on the Time-of-Flight of sound waves (chirp echo).

* **Technology:** 40kHz Ultrasonic (Sound)
* **Interface:** I2C
* **Range:** 3cm – 600cm
* **Output:** Single scalar value (distance to nearest object in cone)

### Option B: VL53L5CX Time-of-Flight (ToF) 8x8 Multizone Sensor
A state-of-the-art laser ranging sensor that measures the Time-of-Flight of photons. **Note:** This sensor is physically integrated into the project's STM32 B-U585I-IOT02A development board.

* **Technology:** 940nm VCSEL Laser (Light)
* **Interface:** I2C / SPI
* **Range:** Up to 400cm
* **Output:** 8x8 (64 zone) Depth Map / Histogram

---

## 3. Technical Comparison

| Feature           | SRF08 (Ultrasonic)                                                                                    | VL53L5CX (ToF Lidar)                                                                             | Winner for AEB        |
|:------------------|:------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------|:----------------------|
| **Physics**       | Speed of Sound (~343 m/s)                                                                             | Speed of Light (~300 000 000 m/s)                                                                | **VL53L5CX**          |
| **Max Range**     | 600cm                                                                                                 | 400cm                                                                                            | **SRF08**             |
| **Update Rate**   | Variable (depends on range). Max ~40Hz, typically slower to avoid echo ghosting.                      | Fixed **60Hz** capability.                                                                       | **VL53L5CX**          |
| **Resolution**    | **1 Zone.** Cannot distinguish if an object is left, right, or center, only "in front."               | **64 Zones (8x8).** Can function as a low-res depth camera (Lidar).                              | **VL53L5CX**          |
| **Target Mode**   | Only returns the distance to the single nearest target in the whole detection zone.                   | Multi-target, up to 64 points with independent measurements.                                     | **VL53L5CX**          |
| **Field of View** | Narrow Cone (hard to define exact edges).                                                             | **65°** (diagonal square).                                                                       | **VL53L5CX**          |
| **Blind Zone**    | 0cm - 3cm (approx).                                                                                   | Very near field capable.                                                                         | **Tie**               |
| **Interference**  | Susceptible to soft materials (cloth/foam) absorbing sound. Radar-deflecting angles could confuse it. | Susceptible to transparent surfaces (glass/acrylic) and intense sunlight (IR sensor saturation). | **Context Dependent** |
| **Integration**   | Requires mounting, wiring, and 5V logic conversion (if STM32 is 3.3V strict). Adds 35g of weight.     | **Zero hardware cost.** Already embedded on the B-U585I-IOT02A. Needs correct board placement.   | **VL53L5CX**          |

---

## 4. Deep Dive: Suitability for Emergency Braking

### The Latency Problem
In an emergency braking scenario at high speeds, latency is the enemy.
* **SRF08:** To measure an object at 3 meters, the sound wave must travel 6 meters total. $t = \frac{6}{343} \approx 17.5ms$. This is purely physical time of flight, excluding processing (which isn't on board).
* **VL53L5CX:** Light travel time is negligible. The sensor provides data at a steady 60Hz ($16.6ms$ per frame).
* **Verdict:** The ToF offers deterministic timing, which is critical for RTOS (Real-Time Operating System) tasks on the STM32.

### Spatial Awareness (The "Ghost" Problem)
* **SRF08:** If the car is driving through a narrow corridor or near a wall, the ultrasonic cone might hit the side wall and trigger a "FALSE POSITIVE" brake event. The sensor implies an obstacle is *ahead*, even if it is slightly to the side.
* **VL53L5CX:** With an 8x8 matrix, we can implement **Region of Interest (ROI)** logic. We can program the AEB to only trigger if the *center zones* detect an obstacle, ignoring walls detected in the peripheral zones.

### Integration & Reliability
* **SRF08:** Adding this sensor introduces mechanical failure points: wires can disconnect, and the sensor must be glued/screwed to the chassis.
* **VL53L5CX:** Being onboard the STM32 dev board reduces mechanical complexity. However, the board's placement on the chassis becomes dictated by the sensor's need for a clear line of sight. Other components/wires that need access to the STM32 will need to be adjusted.

---

## 5. Conclusion & Recommendation

**Primary Sensor Recommendation: VL53L5CX**

For the PiRacer application running on the STM32U585AI, the **VL53L5CX** is superior in almost every metric relevant to safety-critical braking:
1.  **Availability:** It is already present on the safety controller (STM32).
2.  **Data Quality:** Multizone output allows for smarter filtering of false positives (walls vs. obstacles).
3.  **Speed:** 60Hz update rate aligns perfectly with high-speed control loops.

**Role of SRF08:**
The SRF08 should only be considered as a **redundant secondary sensor** if the vehicle is expected to operate in environments with significant amounts of glass or transparent barriers where Lidar/ToF typically fails.

Primary (Fast): VL53L5CX for high-speed precision braking and steering logic.
Secondary (Watchdog): SRF08 checks once every 100ms. If SRF08 < 50cm AND VL53 > 200cm, you flag a "Transparent Obstacle" or "Sensor Blinded" error and trigger a safety stop.