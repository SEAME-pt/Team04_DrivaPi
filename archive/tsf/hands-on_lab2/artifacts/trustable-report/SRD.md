

---

### SRD-998 ### {: .item-element .item-section class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"}
The motor speed sensing subsystem shall provide real-time RPM measurements using a GPIO-connected tachometer sensor to support operator monitoring and test validation.
{: .expanded-item-element }

**Item Status:**

☑ Item Reviewed<br>☑ Children linked<br>

**Supported Requests:**

- [URD-998](URD.md#urd-998){.item-element class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"}

**Supporting Items:**

- [SWD-998](SWD.md#swd-998){.item-element class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"}

{% raw %}

**References:**

- `docs/design/architecture/motor_system_architecture.md`

	??? "Click to view reference"

		````md
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
		       ├─ If RPM &gt;= 0: Display speed
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
		| Initialization | &lt;100ms | GPIO setup |
		| Single read | 1000ms | 1-second measurement window |
		| Error detection | &lt;10ms | Timeout detection |
		| Result return | &lt;1ms | No blocking after measurement |
		
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
		| CPU | &lt;1% | During read operation |
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
		
		````


- `docs/design/interfaces/gpio_sensor_interface.md`

	??? "Click to view reference"

		````md
		# GPIO Sensor Interface Specification
		
		**Date:** 2025-11-03  
		**Project:** DrivaPi  
		**Subsystem:** Motor Speed Sensing  
		**Document ID:** gpio_sensor_interface.md  
		
		---
		
		## 1. Interface Overview
		
		The GPIO sensor interface defines the electrical and protocol specifications for connecting a motor speed tachometer sensor to the Raspberry Pi GPIO subsystem.
		
		### Hardware Architecture
		
		```
		Motor Rotation
		      ↓
		Tachometer Sensor (Hall-effect)
		      ↓
		Pulse Train (3.3V digital)
		      ↓
		GPIO Pin 17 (Raspberry Pi BCM)
		      ↓
		GPIO Driver (Linux kernel)
		      ↓
		MotorSpeedSensor C++ Driver
		      ↓
		Application Layer
		```
		
		---
		
		## 2. Electrical Interface
		
		### Connector Specification
		
		**Connector Type:** 3-pin header (0.1" pitch)
		
		| Pin | Signal | Voltage | Direction |
		|-----|--------|---------|-----------|
		| 1 | GND | 0V | - |
		| 2 | +3.3V | 3.3V | Power |
		| 3 | TACH | 0-3.3V | Input |
		
		### Pin Assignment (Raspberry Pi)
		
		**Physical Pin Location:** Header P1, Pin 11
		
		| Raspberry Pi | BCM # | GPIO Pin |
		|--------------|-------|----------|
		| Physical Pin 11 | GPIO 17 | Input |
		
		### Signal Characteristics
		
		**TACH Signal (Pulse Train):**
		- **Type:** TTL digital pulses (Hall-effect output)
		- **Voltage:** 0-3.3V logic levels
		- **Frequency:** 0 Hz (stopped) to ~166 Hz (10000 RPM)
		  - Calculation: 10000 RPM ÷ 60 sec/min = 166.7 pulses/sec
		- **Frequency Range:** 0-200 Hz (margin for over-speed)
		- **Pulse Width:** Typically 50% duty cycle (vendor-dependent)
		- **Rise Time:** &lt;1 µs (TTL standard)
		- **Fall Time:** &lt;1 µs (TTL standard)
		
		**Power Supply:**
		- **+3.3V Pin:** Supplies sensor power (100 mA max)
		- **GND Pin:** Common ground (must be connected)
		- **Current Draw:** ~50 mA (typical hall-effect sensor)
		
		---
		
		## 3. GPIO Configuration
		
		### Linux GPIO Setup
		
		**BCM Pin Number:** 17  
		**Direction:** Input  
		**Pull-up:** Internal pull-up enabled (30-50 kΩ)  
		**Debounce:** No hardware debounce (software-handled)  
		
		### Setup Methods
		
		**Method 1: Using gpiod (Recommended for Raspberry Pi OS 11+)**
		
		```bash
		# Find GPIO chip
		gpioinfo | grep 17
		
		# Export GPIO 17
		gpioset gpiochip0 17=0
		
		# Read GPIO 17
		gpioget gpiochip0 17
		```
		
		**Method 2: Using sysfs (Legacy)**
		
		```bash
		# Export GPIO
		echo 17 &gt; /sys/class/gpio/export
		
		# Set as input
		echo in &gt; /sys/class/gpio/gpio17/direction
		
		# Read GPIO
		cat /sys/class/gpio/gpio17/value
		```
		
		**Method 3: Using wiringPi Library**
		
		```cpp
		#include &lt;wiringPi.h&gt;
		
		wiringPiSetupGpio();
		pinMode(17, INPUT);
		int state = digitalRead(17);
		```
		
		---
		
		## 4. Protocol Specification
		
		### Pulse Counting Protocol
		
		**Measurement Window:** 1000 milliseconds (±10ms tolerance)
		
		**Algorithm:**
		```
		1. Start counting at T=0
		2. Monitor GPIO 17 for rising edges
		3. Increment pulse counter on each rising edge
		4. Stop counting at T=1000ms
		5. Calculate RPM = pulse_count × 60
		```
		
		**Example Calculation:**
		- Motor speed: 2400 RPM
		- Expected pulses in 1 sec: 2400 ÷ 60 = 40 pulses
		- Measurement window: 1000ms
		- Result: 40 pulses counted → 40 × 60 = 2400 RPM ✓
		
		### Timing Specifications
		
		| Parameter | Specification | Tolerance |
		|-----------|---------------|-----------|
		| Measurement Window | 1000 ms | ±10 ms |
		| Maximum Pulse Frequency | 200 Hz | - |
		| Minimum Pulse Duration | 2.5 µs | - |
		| Settling Time | &lt;1 ms | - |
		
		---
		
		## 5. Connector Pinout Details
		
		### DrivaPi Motor Sensor Header
		
		```
		Front View:
		┌─────────┐
		│ 1  2  3 │
		│ GND +3V TACH
		└─────────┘
		
		Pin 1: GND (Black wire)
		Pin 2: +3.3V (Red wire)
		Pin 3: TACH (Yellow wire)
		```
		
		### Wiring Guidelines
		
		**Cable Requirements:**
		- **Type:** Shielded twisted pair (recommended)
		- **Length:** Maximum 5 meters
		- **Gauge:** 22 AWG or better
		- **Shield:** Connected to GND at sensor end
		
		**Connector Assembly:**
		1. Strip 0.25" from wire ends
		2. Tin wires with solder (optional)
		3. Insert into crimp pins
		4. Crimp securely
		5. Insert into header housing
		6. Ensure pins are fully seated
		
		---
		
		## 6. Sensor Hardware Specification
		
		### Recommended Sensor: Standard Hall-Effect Tachometer
		
		**Sensor Type:** Hall-effect pulse generator
		
		| Specification | Value | Notes |
		|---------------|-------|-------|
		| Supply voltage | 5V or 3.3V | Use 3.3V for Raspberry Pi |
		| Current draw | 20-50 mA | Typical operation |
		| Output type | Open-collector or push-pull | Ensure 3.3V TTL compatible |
		| Frequency response | DC to 200 Hz | Supports up to 12000 RPM |
		| Temperature range | -40°C to +85°C | Standard automotive |
		| Mounting | Bolt-on or snap-on | Depends on motor type |
		
		**Sensor Features:**
		- ✓ 1 pulse per motor revolution
		- ✓ No batteries required (powered by DrivaPi)
		- ✓ Weatherproof connector (IP67 minimum)
		- ✓ EMI/RFI shielded
		
		---
		
		## 7. Electrical Safety
		
		### ESD Protection
		
		- GPIO 17 has internal protection diode
		- Additional external protection recommended:
		  - Series 100Ω resistor on TACH line
		  - 100nF capacitor to GND (low-pass filter)
		
		### Overvoltage Protection
		
		| Condition | Protection |
		|-----------|-----------|
		| 5V applied to 3.3V GPIO | Not supported - use voltage divider |
		| ESD spike | Internal diode clamps at Vdd + 0.3V |
		| Latchup | POR (Power-on Reset) recovery |
		
		### Circuit Diagram
		
		```
		Motor Tachometer Output
		         │
		         └─┬─ 100Ω ─┬─ GPIO 17 (BCM17)
		           │        │
		          ///      100nF
		           │        │
		           │        ├─ Pull-up (internal)
		           │        │
		         GND ──────GND (Raspberry Pi)
		```
		
		---
		
		## 8. Environmental Conditions
		
		### Operating Environment
		
		**Temperature:** -10°C to +40°C (lab environment)  
		**Humidity:** 20% to 80% RH (non-condensing)  
		**Vibration:** &lt;5G (typical test lab)  
		**EMI:** Standard industrial environment (&lt; 100 V/m at 1 GHz)  
		
		### Cable Routing
		
		- **Keep away from:** High-current power cables, motor leads
		- **Route with:** Other signal cables (twisted pair)
		- **Grounding:** Shield must be grounded at sensor end only
		- **Distance from power:** Minimum 10cm separation
		
		---
		
		## 9. Calibration & Testing
		
		### Pre-Installation Verification
		
		```bash
		# 1. Check GPIO availability
		gpioinfo | grep 17
		
		# 2. Test GPIO connectivity
		gpioset gpiochip0 17=0
		gpioget gpiochip0 17
		
		# 3. Verify 3.3V power supply
		# (Use multimeter on Pin 2 vs Pin 1)
		
		# 4. Check for short circuits
		# (Resistance between TACH and GND should be &gt;1MΩ)
		```
		
		### Sensor Calibration
		
		**Pulse Verification:**
		1. Manually rotate motor 10 times
		2. Count pulses (should be 10)
		3. Verify no spurious pulses
		
		**Frequency Test:**
		1. Run motor at known speed (e.g., 3000 RPM)
		2. Measure pulse frequency: 3000 ÷ 60 = 50 Hz
		3. Verify measured frequency matches
		
		---
		
		## 10. Troubleshooting Guide
		
		| Issue | Symptom | Cause | Solution |
		|-------|---------|-------|----------|
		| No pulses | read_rpm() returns -1 | GPIO not connected | Check pin 3 connection |
		| Sporadic pulses | Random RPM values | Loose connector | Reseat connector |
		| High frequency noise | Jittery readings | EMI from motor | Add shielding |
		| Constant low reading | RPM too low | Slow motor speed | Normal - verify in log |
		| Constant high reading | RPM too high | Sensor short | Check TACH to GND |
		
		---
		
		## 11. Compliance & Standards
		
		- **Electrical:** TTL logic levels (3.3V standard)
		- **Mechanical:** Standard 0.1" header spacing
		- **Environmental:** Industrial operating conditions
		- **Safety:** ASIL A (SWD-010 requirement)
		
		---
		
		**Document Status:** Released  
		**Next Review:** Post-integration test  
		**Traceability:** SRD-010
		
		````


- `docs/hardware/sensor_selection.md`

	??? "Click to view reference"

		````md
		# Sensor Selection Analysis
		
		**Date:** 2025-11-03  
		**Project:** DrivaPi  
		**Subsystem:** Motor Speed Sensing  
		**Document ID:** sensor_selection.md  
		
		---
		
		## Executive Summary
		
		This document evaluates motor speed sensor options for the DrivaPi motor testing platform and justifies the selection of a standard Hall-effect tachometer.
		
		---
		
		## 1. Sensor Selection Criteria
		
		### Primary Requirements
		
		| Criterion | Weight | Requirement |
		|-----------|--------|-------------|
		| Speed Range | Critical | 0-10000 RPM minimum |
		| Accuracy | Critical | ±1% of reading |
		| Output Type | Critical | TTL/CMOS logic compatible |
		| Interface | High | GPIO/digital input only |
		| Cost | High | &lt;$50 per unit |
		| Reliability | Critical | ASIL A compliant |
		| Availability | High | Standard parts, short lead time |
		
		### Secondary Criteria
		
		- Minimal power consumption
		- No calibration required
		- Wide temperature range
		- Environmental robustness (IP67+)
		- Mounting flexibility
		
		---
		
		## 2. Sensor Technology Options
		
		### Option 1: Hall-Effect Tachometer (SELECTED)
		
		**Description:** Magnetic switch that generates pulse on each motor revolution.
		
		**Advantages:**
		- ✓ Simple digital output (1 pulse per rev)
		- ✓ No external power for electronics (powered by DrivaPi)
		- ✓ Robust to temperature and humidity
		- ✓ Low cost ($20-40)
		- ✓ Widely available
		- ✓ No calibration needed
		- ✓ Proven reliability in automotive
		
		**Disadvantages:**
		- ✗ Requires magnet on motor shaft
		- ✗ Manual installation/adjustment
		- ✗ Limited to integer revolution counting
		
		**Application:** Motor speed (RPM), revolution counting  
		**Output Type:** Digital pulse train (0-3.3V TTL)  
		**Typical Range:** 0-10000+ RPM  
		**Accuracy:** ±0.5% (with proper installation)  
		
		**Recommended Model:** 
		- Industry: Standard automotive tachometer sensor
		- Supplier: Various (Phoenix Contact, Siemens, etc.)
		- Cost: $25-35
		
		---
		
		### Option 2: Optical Encoder
		
		**Description:** Reflective sensor that detects marks on motor shaft.
		
		**Advantages:**
		- ✓ High resolution possible (multiple marks per rev)
		- ✓ Non-contact measurement
		- ✓ Very accurate (±0.1%)
		
		**Disadvantages:**
		- ✗ Expensive ($200+)
		- ✗ Requires reflective marks on shaft
		- ✗ Sensitive to dirt/contamination
		- ✗ More complex setup
		- ✗ Power consumption higher
		- ✗ Overkill for ASIL A
		
		**Not Selected:** Too expensive, unnecessary complexity for requirement
		
		---
		
		### Option 3: Inductive Proximity Sensor
		
		**Description:** Detects metallic target passing sensor.
		
		**Advantages:**
		- ✓ Non-contact measurement
		- ✓ Robust to vibration
		- ✓ No calibration
		
		**Disadvantages:**
		- ✗ Requires metal target on shaft
		- ✗ Limited to specific distances
		- ✗ Higher power consumption
		- ✗ More expensive ($100+)
		- ✗ Complex installation
		
		**Not Selected:** Unnecessary complexity, higher cost
		
		---
		
		### Option 4: Capacitive Sensor
		
		**Description:** Detects capacitance changes as target passes.
		
		**Advantages:**
		- ✓ Non-contact
		- ✓ Works with non-metallic targets
		
		**Disadvantages:**
		- ✗ Sensitive to environmental conditions
		- ✗ High cost ($150+)
		- ✗ Complex setup and calibration
		- ✗ Unreliable in testing environment
		
		**Not Selected:** Unreliable, overcomplicated
		
		---
		
		## 3. Comparison Matrix
		
		| Feature | Hall-Effect | Optical | Inductive | Capacitive |
		|---------|-------------|---------|-----------|------------|
		| **Cost** | $$ | $$$$ | $$$ | $$$$ |
		| **Accuracy** | ±1% | ±0.1% | ±0.5% | ±2% |
		| **Installation** | Easy | Medium | Medium | Hard |
		| **Maintenance** | None | Periodic cleaning | Rare | Frequent |
		| **Temperature Range** | -40 to +85°C | -10 to +70°C | -20 to +100°C | -10 to +60°C |
		| **Environmental Robustness** | IP67 | IP54 | IP67 | IP54 |
		| **Power Consumption** | Low | Medium | High | Medium |
		| **Calibration** | None | Optional | None | Required |
		| **Complexity** | Simple | Complex | Medium | Complex |
		| **Reliability (ASIL A)** | Proven | Overkill | Good | Questionable |
		
		---
		
		## 4. Cost Analysis
		
		### Hall-Effect Option (Selected)
		
		| Item | Cost | Notes |
		|------|------|-------|
		| Sensor | $30 | Standard automotive tachometer |
		| Connector | $5 | 3-pin header housing |
		| Wiring | $5 | Shielded twisted pair, 5m |
		| Installation labor | $20 | One-time technician time |
		| **Total** | **$60** | Per test stand |
		
		### Optical Encoder Option (Alternative)
		
		| Item | Cost | Notes |
		|------|------|-------|
		| Sensor | $200 | High-precision optical |
		| Encoder wheel | $50 | Reflective marks |
		| Cable/connector | $20 | Proprietary interface |
		| Installation | $50 | Complex setup |
		| **Total** | **$320** | 5× more expensive |
		
		---
		
		## 5. Risk Analysis
		
		### Hall-Effect Sensor Risks
		
		| Risk | Probability | Impact | Mitigation |
		|------|-------------|--------|-----------|
		| Magnet detaches | Low | High | Use strong epoxy adhesive + retaining ring |
		| Poor sensor mounting | Medium | Medium | Template + installation guide |
		| EMI interference | Low | Medium | Shielded cable + filtering |
		| Mechanical wear | Low | Low | Expected lifetime &gt;5 years |
		
		### Optical Sensor Risks
		
		| Risk | Probability | Impact | Mitigation |
		|------|-------------|--------|-----------|
		| Contamination/dirt | High | High | Regular cleaning required |
		| Connector issues | Medium | High | Proprietary difficult to replace |
		| Performance drift | Medium | Medium | Frequent calibration required |
		| Cost overrun | Low | High | Budget impact |
		
		---
		
		## 6. Application Scenarios
		
		### Scenario 1: Standard Motor Speed Monitoring
		
		**Requirement:** Monitor motor speed 0-5000 RPM during typical tests  
		**Solution:** Hall-Effect sensor (sufficient)  
		**Performance:** ±1% accuracy = ±50 RPM at 5000 RPM ✓
		
		### Scenario 2: High-Speed Performance Testing
		
		**Requirement:** Monitor speed at 8000-10000 RPM during extreme tests  
		**Solution:** Hall-Effect sensor (adequate)  
		**Performance:** ±1% accuracy = ±100 RPM at 10000 RPM ✓
		
		### Scenario 3: Advanced Analysis (Future)
		
		**Requirement:** Require &lt;0.1% accuracy for detailed analysis  
		**Solution:** Upgrade to optical encoder when needed  
		**Note:** Hall-Effect sufficient for current ASIL A requirement
		
		---
		
		## 7. Selection Justification
		
		### Why Hall-Effect Tachometer?
		
		1. **Cost Efficiency:** $60 total vs $320+ for alternatives (80% savings)
		2. **Simplicity:** Minimal installation complexity, no calibration
		3. **Reliability:** Proven automotive-grade component
		4. **ASIL A Compliance:** Exceeds ASIL A requirements
		5. **Availability:** Standard parts, short delivery times
		6. **Maintainability:** Simple troubleshooting and replacement
		7. **Performance:** Adequate accuracy (±1%) for motor monitoring
		8. **Future-Proof:** Easy to upgrade if ASIL B required later
		
		### ASIL A Justification
		
		| ASIL Level | Sensor Accuracy Needed | Hall-Effect Capability | Status |
		|-----------|------------------------|----------------------|--------|
		| **QM** | Low (±5%) | ±1% | Exceeds |
		| **A** | Medium (±2%) | ±1% | **Meets** ✓ |
		| **B** | Good (±1%) | ±1% | Exceeds |
		| **C** | Excellent (±0.5%) | ±1% | Exceeds |
		| **D** | Precision (±0.1%) | ±1% | Close (consider upgrade) |
		
		---
		
		## 8. Implementation Plan
		
		### Phase 1: Procurement
		- Order Hall-Effect sensor ($30)
		- Source connector and wiring ($10)
		- Estimated lead time: 1 week
		
		### Phase 2: Installation
		- Mount sensor on motor test stand
		- Calibrate magnet position
		- Test pulse frequency (manual verification)
		- Estimated time: 30 minutes
		
		### Phase 3: Integration
		- Connect to Raspberry Pi GPIO 17
		- Load MotorSpeedSensor driver (SWD-010)
		- Verify RPM reading accuracy
		- Estimated time: 1 hour
		
		### Phase 4: Validation
		- Run full test suite (LLTC-010)
		- Verify speed range 0-10000 RPM
		- Check accuracy ±1%
		- Document results
		- Estimated time: 2 hours
		
		---
		
		## 9. Alternative Sensor Profiles (For Reference)
		
		### If Optical Encoder Were Selected
		
		**Setup Would Require:**
		- Reflective encoder wheel (add $50)
		- Precise mounting bracket (add $40)
		- Regular cleaning procedure
		- Higher installation time (2+ hours)
		- Periodic calibration
		
		**Not justified for ASIL A but could be considered if:**
		- ASIL B required in future
		- High-precision trend analysis needed
		- Cost is not a constraint
		
		---
		
		## 10. Conclusion
		
		**Selected Sensor:** Standard Hall-Effect Tachometer  
		**Rationale:** Optimal balance of cost, reliability, simplicity, and performance for ASIL A motor speed monitoring
		
		**Key Decision Factors:**
		1. ✓ Meets accuracy requirement (±1%)
		2. ✓ Lowest total cost ($60)
		3. ✓ Simplest installation
		4. ✓ Proven reliability
		5. ✓ ASIL A compliant
		6. ✓ Industry standard
		
		**Recommendation:** Proceed with Hall-Effect tachometer implementation.
		
		---
		
		**Document Status:** Approved  
		**Review Date:** 2025-11-03  
		**Approved By:** Design Team  
		**Traceability:** SRD-010
		
		````



{% endraw %}

**Fallacies:**

_None_
