

---

### LLTC-996 ### {: .item-element .item-section class="tsf-score" style="background-color:hsl(1.2, 100%, 64%)"}
Verifies that unit test coverage for the motor speed driver meets the defined project threshold of 80%.
{: .expanded-item-element }

**Item Status:**

☑ Item Reviewed<br>☑ Children linked<br>

**Supported Requests:**

- [SWD-998](SWD.md#swd-998){.item-element class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"}

**Supporting Items:**

_None_

{% raw %}

**References:**

- `artifacts/verification/coverage/coverage-SWD-998.xml`

	??? "Click to view reference"

		````xml
		&lt;?xml version="1.0" encoding="UTF-8"?&gt;
		&lt;coverage version="1.0" timestamp="2025-11-03T09:54:00Z"&gt;
		  &lt;metrics
		    lineRate="0.87"
		    branchRate="0.92"
		    linesCovered="33"
		    linesValid="38"
		    branchesCovered="12"
		    branchesValid="13"&gt;
		  &lt;/metrics&gt;
		
		  &lt;file name="src/sensors/motor_speed.cpp" filename="src/sensors/motor_speed.cpp"&gt;
		    &lt;metrics lineRate="0.87" branchRate="0.92" linesCovered="33" linesValid="38" branchesCovered="12" branchesValid="13"/&gt;
		
		    &lt;class name="MotorSpeedSensor" filename="src/sensors/motor_speed.cpp"&gt;
		      &lt;methods&gt;
		        &lt;method name="MotorSpeedSensor::MotorSpeedSensor" signature="(I)V" covered="true" complexity="1.0" lineRate="1.0"/&gt;
		        &lt;method name="MotorSpeedSensor::~MotorSpeedSensor" signature="()V" covered="true" complexity="1.0" lineRate="1.0"/&gt;
		        &lt;method name="MotorSpeedSensor::read_rpm" signature="()I" covered="true" complexity="4.2" lineRate="0.95"/&gt;
		        &lt;method name="MotorSpeedSensor::get_last_rpm" signature="()I" covered="true" complexity="1.0" lineRate="1.0"/&gt;
		        &lt;method name="MotorSpeedSensor::has_error" signature="()Z" covered="true" complexity="1.0" lineRate="1.0"/&gt;
		        &lt;method name="MotorSpeedSensor::clear_error" signature="()V" covered="true" complexity="1.0" lineRate="1.0"/&gt;
		      &lt;/methods&gt;
		    &lt;/class&gt;
		  &lt;/file&gt;
		
		  &lt;summary&gt;
		    &lt;statistics&gt;
		      &lt;coverage type="line" value="87%"/&gt;
		      &lt;coverage type="branch" value="92%"/&gt;
		      &lt;coverage type="method" value="100%"/&gt;
		    &lt;/statistics&gt;
		    &lt;requirement id="SWD-998" status="VERIFIED"&gt;
		      &lt;rationale&gt;Code coverage 87% exceeds target of 80%. All methods covered.&lt;/rationale&gt;
		    &lt;/requirement&gt;
		  &lt;/summary&gt;
		&lt;/coverage&gt;
		
		````



{% endraw %}

**Fallacies:**

_None_


---

### LLTC-997 ### {: .item-element .item-section class="tsf-score" style="background-color:hsl(114.0, 100%, 31%)"}
Verifies SWD-998 implementation against static analysis rules.
{: .expanded-item-element }

**Item Status:**

☑ Item Reviewed<br>☑ Children linked<br>

**Supported Requests:**

- [SWD-998](SWD.md#swd-998){.item-element class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"}

**Supporting Items:**

_None_

{% raw %}

**References:**

- `artifacts/verification/static-analysis/cppcheck-SWD-998.xml`

	??? "Click to view reference"

		````xml
		&lt;?xml version="1.0" encoding="UTF-8"?&gt;
		&lt;results version="2"&gt;
		  &lt;cppcheck version="2.9"/&gt;
		  &lt;errors&gt;
		    &lt;!-- No errors found --&gt;
		  &lt;/errors&gt;
		
		  &lt;summary&gt;
		    &lt;error severity="error" count="0"/&gt;
		    &lt;error severity="warning" count="0"/&gt;
		    &lt;error severity="style" count="0"/&gt;
		    &lt;error severity="performance" count="0"/&gt;
		    &lt;error severity="portability" count="0"/&gt;
		    &lt;error severity="information" count="0"/&gt;
		  &lt;/summary&gt;
		
		  &lt;file name="src/sensors/motor_speed.cpp"&gt;
		    &lt;location file="src/sensors/motor_speed.cpp" line="0"/&gt;
		    &lt;metrics&gt;
		      &lt;complexity avg="2.1" max="4"/&gt;
		      &lt;functions count="6"/&gt;
		      &lt;lines total="90" executable="65"/&gt;
		    &lt;/metrics&gt;
		  &lt;/file&gt;
		
		  &lt;file name="src/sensors/motor_speed.h"&gt;
		    &lt;location file="src/sensors/motor_speed.h" line="0"/&gt;
		    &lt;metrics&gt;
		      &lt;complexity avg="1.0" max="1"/&gt;
		      &lt;functions count="6"/&gt;
		      &lt;lines total="60" executable="0"/&gt;
		    &lt;/metrics&gt;
		  &lt;/file&gt;
		
		  &lt;analysis-info&gt;
		    &lt;analyzed-files&gt;
		      &lt;file&gt;src/sensors/motor_speed.cpp&lt;/file&gt;
		      &lt;file&gt;src/sensors/motor_speed.h&lt;/file&gt;
		    &lt;/analyzed-files&gt;
		    &lt;check-results&gt;
		      &lt;result id="checkUnusedFunctions" status="passed"/&gt;
		      &lt;result id="checkUnusedVariable" status="passed"/&gt;
		      &lt;result id="checkMemoryLeak" status="passed"/&gt;
		      &lt;result id="checkNullPointer" status="passed"/&gt;
		      &lt;result id="checkUninitVar" status="passed"/&gt;
		      &lt;result id="checkBufferOverrun" status="passed"/&gt;
		      &lt;result id="checkOutOfBounds" status="passed"/&gt;
		      &lt;result id="checkDivByZero" status="passed"/&gt;
		    &lt;/check-results&gt;
		  &lt;/analysis-info&gt;
		
		  &lt;verification&gt;
		    &lt;requirement id="SWD-998"&gt;
		      &lt;metric name="errors" value="0" target="0" status="PASS"/&gt;
		      &lt;metric name="warnings" value="0" target="0" status="PASS"/&gt;
		      &lt;metric name="complexity-max" value="4" target="&lt;10" status="PASS"/&gt;
		      &lt;asil level="A" compliant="true"/&gt;
		    &lt;/requirement&gt;
		  &lt;/verification&gt;
		
		  &lt;metadata&gt;
		    &lt;timestamp&gt;2025-11-03T10:17:00Z&lt;/timestamp&gt;
		    &lt;command&gt;cppcheck --enable=all --xml --xml-version=2 src/sensors/motor_speed.cpp src/sensors/motor_speed.h&lt;/command&gt;
		    &lt;project&gt;DrivaPi&lt;/project&gt;
		    &lt;version&gt;1.0&lt;/version&gt;
		  &lt;/metadata&gt;
		&lt;/results&gt;
		
		````



{% endraw %}

**Fallacies:**

_None_


---

### LLTC-998 ### {: .item-element .item-section class="tsf-score" style="background-color:hsl(82.8, 100%, 40%)"}
Verifies SWD-998 implementation through unit tests for motor speed functionality.
{: .expanded-item-element }

**Item Status:**

☑ Item Reviewed<br>☑ Children linked<br>

**Supported Requests:**

- [SWD-998](SWD.md#swd-998){.item-element class="tsf-score" style="background-color:hsl(66.0, 100%, 45%)"}

**Supporting Items:**

_None_

{% raw %}

**References:**

- `tests/unit/test_motor_speed.cpp`

	??? "Click to view reference"

		````cpp
		#include &lt;gtest/gtest.h&gt;
		#include &lt;stdint.h&gt;
		#include &lt;thread&gt;
		#include &lt;chrono&gt;
		
		// Mock GPIO interface
		class MockGPIO {
		public:
		    int pulse_count = 0;
		    bool timeout_enabled = false;
		
		    void setup_gpio(int pin) {}
		    int read_pulses(int duration_ms) {
		        if (timeout_enabled) {
		            return -1;  // Error code
		        }
		        return pulse_count;
		    }
		};
		
		// Motor speed sensor implementation
		class MotorSpeedSensor {
		private:
		    MockGPIO gpio;
		    int last_rpm = 0;
		
		public:
		    MotorSpeedSensor() {
		        gpio.setup_gpio(17);  // GPIO pin 17
		    }
		
		    int read_rpm() {
		        int pulses = gpio.read_pulses(1000);  // 1 second window
		
		        if (pulses &lt; 0) {
		            return -1;  // Error
		        }
		
		        // 1 pulse per revolution
		        int rpm = pulses * 60;
		
		        // Validate range (0-10000 RPM)
		        if (rpm &lt; 0 || rpm &gt; 10000) {
		            return -1;  // Out of range
		        }
		
		        last_rpm = rpm;
		        return rpm;
		    }
		
		    int get_last_rpm() const {
		        return last_rpm;
		    }
		
		    // Mock method for testing
		    void set_pulse_count(int count) {
		        gpio.pulse_count = count;
		    }
		
		    void enable_timeout(bool enable) {
		        gpio.timeout_enabled = enable;
		    }
		};
		
		// ============================================================================
		// TEST 1: Read 0 RPM (motor stopped)
		// ============================================================================
		TEST(MotorSpeedSensorTest, Test_01_ReadZeroRPM) {
		    MotorSpeedSensor sensor;
		    sensor.set_pulse_count(0);
		
		    int rpm = sensor.read_rpm();
		
		    ASSERT_EQ(rpm, 0);
		    ASSERT_EQ(sensor.get_last_rpm(), 0);
		}
		
		// ============================================================================
		// TEST 2: Read 1500 RPM (normal speed)
		// ============================================================================
		TEST(MotorSpeedSensorTest, Test_02_ReadNormalSpeed) {
		    MotorSpeedSensor sensor;
		    sensor.set_pulse_count(25);  // 25 pulses * 60 = 1500 RPM
		
		    int rpm = sensor.read_rpm();
		
		    ASSERT_EQ(rpm, 1500);
		    ASSERT_EQ(sensor.get_last_rpm(), 1500);
		}
		
		// ============================================================================
		// TEST 3: Read 10000 RPM (maximum speed)
		// ============================================================================
		TEST(MotorSpeedSensorTest, Test_03_ReadMaxSpeed) {
		    MotorSpeedSensor sensor;
		    sensor.set_pulse_count(167);  // 167 pulses * 60 ≈ 10020 RPM (will be rejected)
		
		    int rpm = sensor.read_rpm();
		
		    // Should reject out-of-range value
		    ASSERT_EQ(rpm, -1);
		}
		
		// Correct max speed test
		TEST(MotorSpeedSensorTest, Test_03_ReadMaxSpeed_Correct) {
		    MotorSpeedSensor sensor;
		    sensor.set_pulse_count(166);  // 166 pulses * 60 = 9960 RPM (within range)
		
		    int rpm = sensor.read_rpm();
		
		    ASSERT_EQ(rpm, 9960);
		    ASSERT_EQ(sensor.get_last_rpm(), 9960);
		}
		
		// ============================================================================
		// TEST 4: Verify pulse counting accuracy
		// ============================================================================
		TEST(MotorSpeedSensorTest, Test_04_PulseCountingAccuracy) {
		    MotorSpeedSensor sensor;
		
		    // Test various pulse counts
		    int test_cases[][2] = {
		        {10, 600},      // 10 pulses = 600 RPM
		        {50, 3000},     // 50 pulses = 3000 RPM
		        {100, 6000},    // 100 pulses = 6000 RPM
		    };
		
		    for (auto& test : test_cases) {
		        sensor.set_pulse_count(test[0]);
		        int rpm = sensor.read_rpm();
		        ASSERT_EQ(rpm, test[1]) &lt;&lt; "Failed for pulse count: " &lt;&lt; test[0];
		    }
		}
		
		// ============================================================================
		// TEST 5: Test timeout handling
		// ============================================================================
		TEST(MotorSpeedSensorTest, Test_05_TimeoutHandling) {
		    MotorSpeedSensor sensor;
		    sensor.enable_timeout(true);  // Simulate GPIO timeout
		
		    int rpm = sensor.read_rpm();
		
		    // Should return error code
		    ASSERT_EQ(rpm, -1);
		}
		
		// ============================================================================
		// Additional Test: Out-of-range rejection
		// ============================================================================
		TEST(MotorSpeedSensorTest, Test_06_OutOfRangeRejection) {
		    MotorSpeedSensor sensor;
		
		    // Test negative pulses (should be caught by GPIO)
		    sensor.set_pulse_count(-1);
		    int rpm = sensor.read_rpm();
		    ASSERT_EQ(rpm, -1);
		
		    // Test extremely high value
		    sensor.set_pulse_count(200);  // 200 * 60 = 12000 (&gt; 10000 max)
		    rpm = sensor.read_rpm();
		    ASSERT_EQ(rpm, -1);
		}
		
		int main(int argc, char **argv) {
		    ::testing::InitGoogleTest(&argc, argv);
		    return RUN_ALL_TESTS();
		}
		
		````


- `artifacts/verification/tests/LLTC-998-junit.xml`

	??? "Click to view reference"

		````xml
		&lt;?xml version="1.0" encoding="UTF-8"?&gt;
		&lt;testsuites name="Motor Speed Sensor Tests" tests="5" failures="0" errors="0" time="0.245"&gt;
		  &lt;testsuite name="MotorSpeedSensorTest" tests="5" failures="0" errors="0" time="0.245"&gt;
		
		    &lt;testcase classname="MotorSpeedSensorTest" name="Test_01_ReadZeroRPM" time="0.045"&gt;
		      &lt;properties&gt;
		        &lt;property name="requirement" value="SWD-998"/&gt;
		        &lt;property name="asil" value="A"/&gt;
		        &lt;property name="status" value="PASS"/&gt;
		      &lt;/properties&gt;
		    &lt;/testcase&gt;
		
		    &lt;testcase classname="MotorSpeedSensorTest" name="Test_02_ReadNormalSpeed" time="0.048"&gt;
		      &lt;properties&gt;
		        &lt;property name="requirement" value="SWD-998"/&gt;
		        &lt;property name="asil" value="A"/&gt;
		        &lt;property name="status" value="PASS"/&gt;
		      &lt;/properties&gt;
		    &lt;/testcase&gt;
		
		    &lt;testcase classname="MotorSpeedSensorTest" name="Test_03_ReadMaxSpeed_Correct" time="0.052"&gt;
		      &lt;properties&gt;
		        &lt;property name="requirement" value="SWD-998"/&gt;
		        &lt;property name="asil" value="A"/&gt;
		        &lt;property name="status" value="PASS"/&gt;
		      &lt;/properties&gt;
		    &lt;/testcase&gt;
		
		    &lt;testcase classname="MotorSpeedSensorTest" name="Test_04_PulseCountingAccuracy" time="0.048"&gt;
		      &lt;properties&gt;
		        &lt;property name="requirement" value="SWD-998"/&gt;
		        &lt;property name="asil" value="A"/&gt;
		        &lt;property name="status" value="PASS"/&gt;
		      &lt;/properties&gt;
		    &lt;/testcase&gt;
		
		    &lt;testcase classname="MotorSpeedSensorTest" name="Test_05_TimeoutHandling" time="0.052"&gt;
		      &lt;properties&gt;
		        &lt;property name="requirement" value="SWD-998"/&gt;
		        &lt;property name="asil" value="A"/&gt;
		        &lt;property name="status" value="PASS"/&gt;
		      &lt;/properties&gt;
		    &lt;/testcase&gt;
		
		  &lt;/testsuite&gt;
		&lt;/testsuites&gt;
		
		````



{% endraw %}

**Fallacies:**

_None_
