# DrivaPi Integration Test Plan

## Main Goal

Document the integration tests for DrivaPi system components, defining test objectives, setups, assertions, and pass criteria for validating communication and data flow across component interfaces: PS3 controller input, CAN bus communication, I2C motor control, and speed sensor processing.

---

## Integration Test Phases

### Phase A: PS3 Controller → Raspberry Pi

**Objective**: Verify that PS3 controller (Shanwan) commands are correctly received, decoded and validated by the Raspberry Pi.

**Test Setup**:
- Connect Shanwan PS3 controller via 2.4GHz USB dongle to Raspberry Pi
- Inject commands using the physical controller
- Monitor command reception and decoding on the Raspberry Pi

**Assertions**:
- ✅ Correct command decoded (speed, steering, mode values match input)
- ✅ Invalid signals are rejected or handled safely

**Tools & Methods**:
- Shanwan PS3 controller hardware

**Pass Criteria**:
- All valid commands decoded with 100% accuracy
- Invalid/malformed commands rejected without system crash

**Evidence**:
- Runtime logs from [rust/controller/src/main.rs](rust/controller/src/main.rs) showing decoded PS3 input (e.g., `println!("Button test: {:?}", data);`) alongside the CAN payloads sent.
- Video evidence: [tests/integration/joystick_integration.mp4](tests/integration/joystick_integration.mp4) demonstrating PS3 controller input successfully decoded and processed by the Raspberry Pi.

---

### Phase B: Raspberry Pi ↔ STM32 (CAN Bidirectional)

**Objective**: Validate bidirectional CAN bus communication between Raspberry Pi and STM32 microcontroller.

**Test Setup**:
- Use SocketCAN on the Raspberry Pi with the latency test tool `can_latency_receive_test.cpp` (docs/data-transfer/CAN/latency) to send frames and measure echoed responses.
- Run STM32 firmware `can_latency_send_test.c` (docs/data-transfer/CAN/latency) to receive frames and echo them back for round trip measurement.
- Capture STM32 UART logs that show received frames and echo timing.

**Test Cases**:
1. **CAN ID Validation**: Correct CAN identifiers used for each message type
2. **Payload Encoding**: Data bytes match expected format and values
3. **Timing**: Message latency and frequency meet requirements

**Assertions**:
- ✅ CAN messages use correct IDs
- ✅ Payload structure matches protocol specification


**Pass Criteria**:
- All payloads correctly encoded/decoded

---

### Phase C: STM32 → Motor Controllers (I2C (Inter-Integrated Circuit))

**Objective**: Verify that STM32 correctly sends I2C commands to motor controller boards and receives proper acknowledgments.

**Test Setup**:
- Inject commands to STM32
- Verify I2C write operations and ACK (Acknowledge)/NACK (Not Acknowledged) responses
- Observe physical motor behavior

**Architecture**:
- Throttle motor controller: I2C address 0x60
- Steering motor controller: I2C address 0x40
- STM32 acts as I2C master, motor controllers as I2C slaves

**Test Cases**:
1. **Throttle I2C Communication**: CAN throttle command → I2C write to 0x60 → ACK received
2. **Steering I2C Communication**: CAN steering command → I2C write to 0x40 → ACK received

**Tools**:
- UART logs from STM32 (show I2C transaction status)

**Assertions**:
- ✅ I2C write to 0x60 (throttle) uses correct address and payload
- ✅ I2C write to 0x40 (steering) uses correct address and payload
- ✅ ACK received from both motor controllers
- ✅ NACK or I2C timeout triggers error handling
- ✅ No unintended motor activation during startup

**Automation Tip**:
Log I2C transaction status (ACK/NACK) from STM32 firmware and parse logs programmatically for pass/fail validation.

**Pass Criteria**:
- 100% correct I2C addressing (0x60 for throttle, 0x40 for steering)
- All valid commands receive ACK from motor controllers
- I2C errors handled without system crash

**Evidence**:
- Test implementation files: [tests/integration/motors-and-speed-sensor-integration/src/](tests/integration/motors-and-speed-sensor-integration/src/) and [tests/integration/motors-and-speed-sensor-integration/inc/](tests/integration/motors-and-speed-sensor-integration/inc/) containing I2C integration test code (`i2c_integration_test.c/h`), PCA9685 driver (`pca9685.c/h`), and test main (`main.c/h`)
- Video evidence: [tests/integration/motors_integration.mp4](tests/integration/motors_integration.mp4) demonstrating successful I2C communication with motor controllers and proper motor actuation

---

### Phase D: Speed Sensor → STM32

**Objective**: Validate that speed sensor data is correctly read and processed by STM32.

**Test Setup**:
- Connect speed sensor to GPIO pin **PD9** (rising edge interrupt)
- Monitor UART output for pulse detection messages
- Count pulses and verify accuracy over time

**Hardware Configuration**:
- Speed sensor output → PD9 (EXTI9 interrupt, rising edge trigger)
- UART output for validation (115200 baud)
- Interrupt increments counter and prints message on each pulse

**Test Cases**:
1. **Pulse Detection**: Interrupt triggered on each sensor pulse
2. **Counter Accuracy**: Pulse count incremented correctly
3. **UART Output**: Message printed for each pulse received
4. **Zero Input Handling**: System stable with no pulses
5. **Sustained Operation**: Counter remains stable over extended testing

**Assertions**:
- ✅ Interrupt fires on rising edge of sensor signal
- ✅ Counter increments correctly for each pulse
- ✅ UART prints confirmation message per pulse
- ✅ No data corruption or missed pulses
- ✅ System remains stable under continuous operation

**Tools**:
- UART terminal monitor (115200 baud, 8N1)

**Pass Criteria**:
- Interrupt correctly triggered on PD9
- Counter increments match actual pulse count
- UART output message printed for each pulse
- No system crashes or hangs
- Stable operation over sustained pulse input

**Evidence**:
- Test implementation: [tests/integration/motors-and-speed-sensor-integration/src/stm32u5xx_it.c](tests/integration/motors-and-speed-sensor-integration/src/stm32u5xx_it.c) - `EXTI9_IRQHandler()` with interrupt service routine
- Main firmware: [tests/integration/motors-and-speed-sensor-integration/src/main.c](tests/integration/motors-and-speed-sensor-integration/src/main.c) - speed sensor interrupt configuration
- Video evidence: [tests/integration/speed_sensor_integration.mp4](tests/integration/speed_sensor_integration.mp4) demonstrating successful pulse detection on PD9 with UART output confirming each pulse received

---

## Success Criteria

All integration phases pass their defined criteria, demonstrating:
- Reliable module-to-module communication
- Correct data transformation across interfaces
- Proper error handling and failsafe behavior
- System stability under normal and edge-case conditions
