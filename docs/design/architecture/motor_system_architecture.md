# Motor System Architecture

**Date:** 2025-11-03  
**Project:** DrivaPi  
**Subsystem:** Motor Speed Monitoring  
**Document ID:** motor_system_architecture.md  

---

## 1. System Overview

The motor speed monitoring subsystem provides real-time RPM measurement and logging for extended motor performance testing on the DrivaPi platform.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│           DrivaPi Motor Testing Platform                 │
├──────────────────┬──────────────────┬──────────────────┤
│  Motor Control   │ Speed Monitoring │ Data Logging     │
│  (PWM, Safety)   │ (This Subsystem) │ (CSV Export)     │
├──────────────────┴──────────────────┴──────────────────┤
│                Raspberry Pi (Main)                      │
├───────────────────────────────────────────────────────┤
│  GPIO 17 Driver │ MotorSpeedSensor │ HMI Display     │
│  (Linux Kernel) │ (C++ Class)      │ (Qt/Web)        │
└───────────────────────────────────────────────────────┘
        ↑                ↑                ↑
        │                │                │
     GPIO Pin 17     Speed Data      Display Data
        ↑                │                │
   ┌────┴────┐           │                │
   │ Sensor  │←──────────┴────────────────┘
   │ (Motor) │
   └────┬────┘
        │
     Motor
```

---

## 2. Component Architecture

### 2.1 Hardware Components

#### Motor Tachometer Sensor

```
┌──────────────────────────────┐
│   Hall-Effect Tachometer     │
├──────────────────────────────┤
│ Input:  Motor rotation       │
│ Output: Pulse train (TTL)    │
│ Freq:   0-200 Hz (≤10k RPM)  │
│ Power:  +3.3V from RPi GPIO  │
│ Pins:   3 (GND, +3.3V, TACH) │
└──────────────────────────────┘
         │
         │ Shielded cable (5m max)
         ↓
   GPIO Pin 17 (Raspberry Pi)
```

#### Raspberry Pi GPIO Subsystem

```
┌──────────────────────────────┐
│  Raspberry Pi GPIO Bank      │
├──────────────────────────────┤
│ Pin 17 (BCM):   Input        │
│ Voltage:        0-3.3V TTL   │
│ Pull-up:        Internal 30k │
│ Driver:         Linux kernel │
│ Interface:      /sys/gpio/17 │
└──────────────────────────────┘
```

---

### 2.2 Software Architecture Layers

```
┌──────────────────────────────────────────────────┐
│         Application Layer                         │
│  (HMI Display, Data Logging, Test Control)        │
├──────────────────────────────────────────────────┤
│         MotorSpeedSensor API Layer                │
│  ├─ int read_rpm()                               │
│  ├─ int get_last_rpm()                           │
│  ├─ bool has_error()                             │
│  └─ void clear_error()                           │
├──────────────────────────────────────────────────┤
│         GPIO Driver Layer (C++)                   │
│  ├─ GPIO initialization                          │
│  ├─ Pulse counting (1-sec window)                │
│  └─ RPM conversion (×60)                         │
├──────────────────────────────────────────────────┤
│     Linux GPIO Driver (Kernel)                    │
│  ├─ /sys/class/gpio interface                    │
│  ├─ Pin 17 edge detection                        │
│  └─ Hardware abstraction                         │
├──────────────────────────────────────────────────┤
│         Hardware (GPIO Pin 17)                    │
└──────────────────────────────────────────────────┘
```

---

## 3. Data Flow

### Normal Operation

```
Motor Rotation (0-10000 RPM)
         │
         ↓
   Tachometer Sensor
   (1 pulse/revolution)
         │
         ↓
   GPIO Pin 17 Pulse Train
   (0-166 pulses/second)
         │
         ↓
   MotorSpeedSensor::read_rpm()
   ├─ Count pulses (1000ms window)
   ├─ Multiply by 60
   └─ Validate range (0-10000)
         │
         ↓
   RPM Value (integer)
         │
         ├─ Update last_rpm
         ├─ Return to caller
         ├─ Log to file
         └─ Send to HMI
         │
         ↓
   Application Display (HMI)
   - Shows current RPM
   - Updates ≥1 Hz
   - Logs with timestamp
```

### Error Handling

```
GPIO Read Error (timeout/failure)
         │
         ↓
   read_rpm() returns -1
         │
         ├─ Set error_flag
         ├─ Preserve last_rpm
         └─ Alert application
         │
         ↓
   Application Handler
   ├─ Display error icon
   ├─ Log error event
   ├─ Trigger alert sound
   └─ Optionally shut down
```

---

## 4. Interface Definitions

### 4.1 Hardware Interface

**Motor Sensor ↔ GPIO Pin 17:**

| Direction | Signal | Voltage | Frequency |
|-----------|--------|---------|-----------|
| Input | TACH | 0-3.3V | 0-166 Hz |
| Output | +3.3V | 3.3V | Continuous |
| Ground | GND | 0V | - |

### 4.2 Software API

```cpp
class MotorSpeedSensor {
public:
    // Constructor - Initialize GPIO 17
    explicit MotorSpeedSensor(int gpio_pin = 17);
    
    // Destructor - Cleanup GPIO
    ~MotorSpeedSensor();
    
    // Read motor speed in RPM
    // Returns: RPM (0-10000) or -1 on error
    int read_rpm(void);
    
    // Get last valid reading
    // Returns: Last successful read_rpm() result
    int get_last_rpm(void) const;
    
    // Check if error occurred
    // Returns: true if error, false if OK
    bool has_error(void) const;
    
    // Clear error flag
    void clear_error(void);
};
```

### 4.3 Data Format

**RPM Value:**
- **Type:** Signed 32-bit integer
- **Range:** 0 to 10000 RPM
- **Resolution:** 1 RPM
- **Error Code:** -1

**Timestamp (optional logging):**
- **Format:** ISO 8601 (2025-11-03T10:37:00Z)
- **Resolution:** Millisecond
- **Source:** System clock

---

## 5. Component Interactions

### Interaction Sequence: Reading Motor Speed

```
Application
    │
    ├─ Create MotorSpeedSensor(17)
    │  └─ MotorSpeedSensor::MotorSpeedSensor()
    │     └─ GPIODriver::setup_gpio(17)
    │        └─ Export GPIO 17 to /sys/class/gpio
    │
    ├─ Call read_rpm()
    │  └─ MotorSpeedSensor::read_rpm()
    │     ├─ GPIODriver::read_pulse_count(1000ms)
    │     │  └─ Count rising edges on GPIO 17
    │     │     ├─ Wait 1000ms
    │     │     └─ Return pulse count
    │     ├─ Calculate RPM = pulses × 60
    │     ├─ Validate range (0-10000)
    │     ├─ Update last_rpm
    │     └─ Return RPM to application
    │
    └─ Handle return value
       ├─ If RPM >= 0: Display speed
       ├─ If RPM == -1: Display error
       └─ Continue monitoring loop
```

---

## 6. System States

### State Machine

```
┌────────┐
│  INIT  │  (Power on)
└────┬───┘
     │
     ├─ GPIO setup OK
     ↓
┌────────────┐
│   READY    │  (Waiting for read)
└────┬───────┘
     │
     ├─ read_rpm() called
     ↓
┌────────────┐     ┌─────────────┐
│  MEASURING │────→│   IDLE      │ (Between reads)
└────┬───────┘     └─────────────┘
     │
     ├─ 1 sec elapsed
     ├─ Count valid
     ↓
┌────────────┐
│   VALID    │  (RPM available)
└────┬───────┘
     │
     ├─ Range OK
     ├─ Update last_rpm
     ↓
┌────────────┐
│   READY    │  (Return to waiting)
└────────────┘

Error Paths:
├─ GPIO error → ERROR state → Return -1
├─ Timeout → ERROR state → Return -1
├─ Out of range → ERROR state → Return -1
└─ Recover → READY state (on next read)
```

---

## 7. Performance Characteristics

### Timing

| Operation | Duration | Notes |
|-----------|----------|-------|
| Initialization | <100ms | GPIO setup |
| Single read | 1000ms | 1-second measurement window |
| Error detection | <10ms | Timeout detection |
| Result return | <1ms | No blocking after measurement |

### Accuracy

| Parameter | Value | Spec |
|-----------|-------|------|
| RPM accuracy | ±1% | Within ±50 RPM @5000 RPM |
| Resolution | 1 RPM | Minimum measurable unit |
| Measurement window | 1000ms | ±10ms tolerance |
| Frequency response | 0-200 Hz | Up to 12000 RPM |

### Resource Usage

| Resource | Usage | Notes |
|----------|-------|-------|
| Memory | ~2 KB | Class instance |
| CPU | <1% | During read operation |
| GPIO pins | 1 | GPIO 17 only |
| Power | +3.3V @ 50mA | Sensor supply |

---

## 8. Integration Points

### With HMI (Display)

```
MotorSpeedSensor
    │
    └─ read_rpm() → RPM value
                     │
                     └─ HMI Display
                        ├─ Update gauge
                        ├─ Show numeric value
                        ├─ Color coding (green/yellow/red)
                        └─ Refresh at ≥1 Hz
```

### With Data Logger

```
MotorSpeedSensor
    │
    └─ read_rpm() → RPM value
                     │
                     └─ Data Logger
                        ├─ Add timestamp
                        ├─ Buffer readings
                        └─ Write to CSV file
                           (async, non-blocking)
```

### With Test Controller

```
MotorSpeedSensor
    │
    ├─ read_rpm() → RPM value
    │                 │
    │                 └─ Test Controller
    │                    ├─ Validate test conditions
    │                    ├─ Check speed limits
    │                    ├─ Trigger alerts if needed
    │                    └─ Log abnormalities
    │
    └─ has_error() → Boolean
                      │
                      └─ Safety Handler
                         ├─ Emergency stop?
                         ├─ Alert operator
                         └─ Log fault
```

---

## 9. Deployment Architecture

### Single Test Stand

```
┌──────────────────────────┐
│   Raspberry Pi           │
│  ┌────────────────────┐  │
│  │  MotorSpeedSensor  │  │
│  │  (SWD-010)         │  │
│  └────┬───────────────┘  │
│       │ GPIO 17          │
└───────┼──────────────────┘
        │
        ├─ 3 wires (GND, +3.3V, TACH)
        │
        ↓
┌──────────────────────────┐
│  Tachometer Sensor       │
│  (on motor shaft)        │
└──────────────────────────┘
```

### Multi-Test Stand (Future)

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Stand 1  │  │ Stand 2  │  │ Stand 3  │
│ (GPIO 17)│  │ (GPIO 27)│  │ (GPIO 22)│
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │             │             │
     └─────────────┬─────────────┘
                   │
              Raspberry Pi
              (multiple GPIO)
```

---

## 10. Safety & Reliability

### Failure Modes

| Mode | Detection | Recovery |
|------|-----------|----------|
| Sensor disconnected | Timeout | Error return (-1) |
| GPIO corruption | Hardware error | Return -1 |
| Software crash | N/A | Restart process |
| Over-speed condition | Range check | Flag error |
| EMI interference | Noisy reads | Validation |

### ASIL A Compliance

- ✓ Single sensor (no redundancy needed for ASIL A)
- ✓ Error detection (timeout, range validation)
- ✓ Error reporting (return -1, error flag)
- ✓ Test coverage ≥80% (87% actual)
- ✓ Code analysis (0 errors)
- ✓ SME review (Carol Dev: 0.92)

---

## 11. Scalability & Future

### Current Capability (ASIL A)

- Single motor monitoring
- GPIO-based input only
- ±1% accuracy sufficient

### Future Expansion (ASIL B+)

- Multiple motors (multiple GPIO pins)
- Optical encoder (higher accuracy)
- CAN bus interface (vehicle integration)
- Data analytics and trending

---

**Document Status:** Released  
**Architecture Version:** 1.0  
**Traceability:** SRD-010  
**Last Updated:** 2025-11-03
