

---

### SWD-998 ### {: .item-element .item-section class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"}
## Software Design Requirement Statement

The motor speed sensor module shall implement a GPIO-based interface that has pulse reading, RPM conversion, range validation, and error handling.
{: .expanded-item-element }

**Item Status:**

☑ Item Reviewed<br>☑ Children linked<br>

**Supported Requests:**

- [SRD-998](SRD.md#srd-998){.item-element class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"}

**Supporting Items:**

- [LLTC-996](LLTC.md#lltc-996){.item-element class="tsf-score" style="background-color:hsl(1.2, 100%, 64%)"}

- [LLTC-997](LLTC.md#lltc-997){.item-element class="tsf-score" style="background-color:hsl(114.0, 100%, 31%)"}

- [LLTC-998](LLTC.md#lltc-998){.item-element class="tsf-score" style="background-color:hsl(82.8, 100%, 40%)"}

{% raw %}

**References:**

- `src/sensors/motor_speed.cpp`

	??? "Click to view reference"

		````cpp
		/**
		 * @file motor_speed.cpp
		 * @brief Motor speed sensor driver implementation
		 * @version 1.0
		 * @date 2025-11-03
		 *
		 * Requirement: SWD-998
		 * ASIL: A
		 */
		
		#include "motor_speed.h"
		#include &lt;stdint.h&gt;
		#include &lt;chrono&gt;
		#include &lt;thread&gt;
		
		// GPIO interface (simplified for Raspberry Pi)
		class GPIODriver {
		private:
		    int pin;
		    int pulse_count;
		    bool is_setup;
		
		public:
		    GPIODriver(int pin_num) : pin(pin_num), pulse_count(0), is_setup(false) {}
		
		    /**
		     * Setup GPIO pin for input
		     * @return 0 on success, -1 on error
		     */
		    int setup(void) {
		        // In real implementation, use wiringPi or similar
		        // gpio.setup_gpio(pin);
		        is_setup = true;
		        return 0;
		    }
		
		    /**
		     * Read pulse count from GPIO pin over specified duration
		     * @param duration_ms Time window in milliseconds
		     * @return Number of pulses, -1 on error
		     */
		    int read_pulse_count(int duration_ms) {
		        if (!is_setup) {
		            return -1;
		        }
		
		        // In real implementation:
		        // - Wait for duration_ms
		        // - Count rising edges on pin
		        // - Return count
		
		        // For testing, this is mocked
		        return pulse_count;
		    }
		
		    void set_pulse_count(int count) {
		        pulse_count = count;
		    }
		};
		
		// ============================================================================
		// MotorSpeedSensor Implementation
		// ============================================================================
		
		MotorSpeedSensor::MotorSpeedSensor(int gpio_pin)
		    : pin(gpio_pin), last_rpm(0), error_flag(false) {
		    gpio = new GPIODriver(gpio_pin);
		    gpio-&gt;setup();
		}
		
		MotorSpeedSensor::~MotorSpeedSensor() {
		    if (gpio) {
		        delete gpio;
		    }
		}
		
		int MotorSpeedSensor::read_rpm(void) {
		    // Read pulses over 1 second window
		    int pulses = gpio-&gt;read_pulse_count(1000);
		
		    // Check for error from GPIO
		    if (pulses &lt; 0) {
		        error_flag = true;
		        return -1;
		    }
		
		    // Convert pulses to RPM
		    // 1 pulse per motor revolution
		    int rpm = pulses * 60;
		
		    // Validate range (0-10000 RPM)
		    if (rpm &lt; 0 || rpm &gt; 10000) {
		        error_flag = true;
		        return -1;
		    }
		
		    // Update last valid reading
		    last_rpm = rpm;
		    error_flag = false;
		    return rpm;
		}
		
		int MotorSpeedSensor::get_last_rpm(void) const {
		    return last_rpm;
		}
		
		bool MotorSpeedSensor::has_error(void) const {
		    return error_flag;
		}
		
		void MotorSpeedSensor::clear_error(void) {
		    error_flag = false;
		}
		
		````


- `src/sensors/motor_speed.h`

	??? "Click to view reference"

		```text
		src/sensors/motor_speed.h
		```


- `docs/standards/iso26262/hara-motor-speed.md`

	??? "Click to view reference"

		````md
		
		
		**Date:** 2025-11-12 | **Authors/Reviewers:** Miguel/Gaspar | **ASIL Target:** QM
		
		## 1. Item Definition & Assumptions
		- **Description:** Motor speed sensor system for DrivaPi lab testing
		- **Boundaries:** Motor rotation → RPM value measurement and monitoring
		- **Interfaces:** GPIO hardware driver, Emergency stop button
		- **Context:** Laboratory environment, trained operators only, emergency stop available
		- **Assumptions:** 
		  - Controlled lab environment with proper safety equipment
		  - Trained operators present during all motor tests
		  - Emergency stop button accessible and functional
		
		## 2. Hazards & Operational Situations
		| ID | Hazard Description | Operational Situation | Exposure (E) / Justification |
		|:---|:---|:---|:---|
		| H-001 | Sensor fails silently during test | Extended motor test | E2 (Low probability; extended tests represent 2-5% of total operating time) |
		
		## 3. Risk Assessment & ASIL
		- **Severity (S):** S1 - Light to moderate injuries
		  - Worst outcome: Motor overheats due to undetected speed anomaly
		  - Potential consequence: Minor burn risk if operator touches overheated motor
		  - Classification: S1 (Light to moderate injuries - minor burns, no life-threatening harm)
		  
		- **Exposure (E):** E2 - Low probability (1-10% of operating time)
		  - Extended motor tests occur regularly but not continuously
		  - Historical data indicates approximately 2-5% of total operational time
		  - Justification: A few occurrences during system lifetime
		  
		- **Controllability (C):** C1 - Simply controllable
		  - Operator is present during all tests
		  - Emergency stop button readily accessible
		  - 99%+ of trained operators can avoid harm with sufficient warning
		  - Recovery action: Press emergency stop button immediately
		
		- **ASIL Calculation:** S1 + E2 + C1 = **QM** (from ISO 26262-3:2018 Table 4)
		  - Per ISO 26262-3:2018, Clause 6.4.3.10, Table 4
		  - Combination S1/E2/C1 results in QM
		
		## 4. Safety Goals
		| Goal ID | ASIL | Description | Safe State |
		|:---|:---|:---|:---|
		| SG-001 | QM | Motor speed sensor shall function reliably and accurately monitor motor RPM | Operator can monitor motor status and execute emergency stop if anomaly detected |
		
		## 5. Dependencies & Review Notes
		- **Dependencies:** 
		  - Emergency stop button system (must be functional)
		  - GPIO hardware driver (reliable pulse counting)
		  - Operator training and presence
		  - Lab environment controls
		  
		- **Related Requirements:** SWD-998 (Motor speed sensor implementation)
		- **Review:** 
		
		
		**References:** ISO 26262-3:2018 (Hazard Analysis and Risk Assessment)
		
		````


- `docs/standards/iso26262/asil-justification-SWD-998.md`

	??? "Click to view reference"

		````md
		# ASIL Justification: SWD-998
		**Date:** 2025-11-12 | **Author/Reviewer:** Bernardo Esteves/Hugo Lopes | **ASIL:** QM
		
		**Date:** 2025-11-12 | **Author/Reviewer:** Miguel/Gaspar | **ASIL Target:** QM
		
		## 1. Requirement Summary
		- **ID/Description:** SWD-998 - Motor speed sensor driver shall read GPIO pulses and convert to RPM.
		- **Related HARA/Safety Goal:** hara-motor-speed.md; N/A
		
		## 2. ASIL Assignment & Decomposition
		- **Assigned ASIL:** QM - Derived from HARA (S1 + E2 + C1 = QM)
		- **Justification:** This requirement implements motor speed monitoring addressing hazard H-01.
		
		## 3. Risk Assessment Summary
		| Factor | Classification | Justification/Evidence |
		|:---|:---|:---|
		| Severity (S) | S1 | Motor overheats - minor burn risk |
		| Exposure (E) | E2 | Extended tests ~2-5% of operation |
		| Controllability (C) | C1 | Operator observes and stops immediately |
		
		## 4. Verification Requirements (QM)
		- **Unit/Integration Testing:** 5 unit tests (Target: ≥70% coverage)
		- **Static Analysis:** cppcheck: 0 errors
		- **Code Review:** 1 independent reviewer (Joao Gaspar)
		
		## 5. Review Notes & Dependencies
		- **Dependencies:** GPIO driver, emergency stop system
		- **Review:** 2025-11-12 - Approved by Joao Gaspar joao.gaspar@seame.pt
		
		**References:** ISO 26262-9:2018
		
		````



{% endraw %}

**Fallacies:**

_None_
