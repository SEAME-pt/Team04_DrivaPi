# Integration Test Execution Template - Phase C
## STM32 → Motor Controllers I2C Communication

---

## Header / Metadata
- **Date:** [YYYY-MM-DD]
- **Time Started:** [HH:MM]
- **Tester Name:** [Full Name]
- **Test Phase:** C
- **Test Cycle:** [Sprint X]

---

## Test Information
- **Phase Name:** I2C Motor Controller Basic Integration
- **Test Objective:** Validate basic I2C communication with the PCA9685 motor controllers (0x60 and 0x40) using the on-device test suite and confirm ACK results in UART logs
- **Related Requirements:**
  - Integration Test Plan - Phase C
  - `/docs/tests/integration-test-plan.md`
  - I2C motor controller datasheet and addressing specification

---

## Environment Setup

### Hardware Required
- [ ] STM32U585 microcontroller with I2C interface
- [ ] PiRacer expansion board (single board with integrated dual motor controllers and I2C interface)
  - Motor Controller #1 (Address: 0x60)
  - Motor Controller #2 (Address: 0x40)
- [ ] USB cables for STM32
- [ ] Power cable for expansion board
### Software Required
- [ ] STM32 firmware with I2C driver

### Configuration Settings
- **I2C Bus:** [I2C3]
- **Clock Speed:** [180] kHz
- **Expansion Board:** PiRacer Kit
- **Motor Controller 1 Address:** 0x60
- **Motor Controller 2 Address:** 0x40
- **SDA/SCL Voltage:** [3.3V]

### Prerequisites Checklist
- [ ] Connection diagram verified and matches
- [ ] STM32 I2C peripheral configured
- [ ] All devices on same I2C bus
- [ ] No address conflicts between devices

---

## Pre-Test Checklist
- [ ] I2C bus voltage: _______ V (expected 3.3V)
- [ ] SDA/SCL not shorted or stuck
- [ ] STM32 powered and firmware loaded
- [ ] Motor controllers powered
- [ ] UART connected for logs
- [ ] Test environment stable and isolated

---

## Execution Steps

### Step 1: Verify I2C Bus Physical Characteristics
**Procedure:**
1. Measure voltage on SDA and SCL lines
2. Verify lines are pulled HIGH at rest
3. Check for stuck-low or stuck-high conditions

**Expected Output:**
```
SDA voltage at rest: 3.3V
SCL voltage at rest: 3.3V
No stuck conditions detected
```

**Measurements:**
- SDA idle voltage: _______ V
- SCL idle voltage: _______ V

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

### Step 2: Run Phase C I2C Integration Test Suite
**Procedure:**
1. Build and flash the integration test firmware
2. Ensure `RunI2CIntegrationTests()` is enabled in `main.c`
3. Open a UART terminal at 115200 baud
4. Observe UART logs and record results

**Expected UART Output (summary):**
```
Phase C: STM32 → Motor Controllers (I2C)
Integration Test Suite
=== Test 1: Device Initialization ===
PASS: Throttle controller (0x60) init
PASS: Steering controller (0x40) init
=== Test 2: Throttle I2C Write + ACK ===
PASS: Motor control - 0% (stop)
PASS: Motor control - 25% left turn
PASS: Motor control - 50% left turn
PASS: Motor control - 50% right turn
PASS: Motor control - back to stop
=== Test 3: Steering I2C Write + ACK ===
PASS: Steering 0x40 - center position
PASS: Steering 0x40 - left turn
PASS: Steering 0x40 - right turn
PASS: Steering 0x40 - back to center
Test Summary
Total Tests: __
Passed: __
Failed: __
```

**Actual Output:**
```
[Record UART output here]
```

**Results:**
- Test 1 (Device Initialization): [ ] PASS [ ] FAIL
- Test 2 (Throttle Write + ACK): [ ] PASS [ ] FAIL
- Test 3 (Steering Write + ACK): [ ] PASS [ ] FAIL

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

## Results Recording

### Overall Status
- [ ] **PASS** - All acceptance criteria met
- [ ] **FAIL** - One or more acceptance criteria not met
- [ ] **CONDITIONAL PASS** - Minor issues requiring documentation

### Pass/Fail Criteria Met
- [ ] Motor controller 1 (0x60) initialized successfully
- [ ] Motor controller 2 (0x40) initialized successfully
- [ ] Throttle write commands returned ACK (HAL_OK)
- [ ] Steering write commands returned ACK (HAL_OK)

### Key Measurements Summary
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Controller 0x60 Init | PASS/FAIL | PASS | PASS/FAIL |
| Controller 0x40 Init | PASS/FAIL | PASS | PASS/FAIL |
| Throttle Writes | PASS/FAIL | PASS | PASS/FAIL |
| Steering Writes | PASS/FAIL | PASS | PASS/FAIL |

### Issues Encountered
- [ ] No issues
- [ ] Issues found (describe below):

**Issue #1:** [Description]
- Severity: [Critical/High/Medium/Low]
- Devices affected: [0x60/0x40/Both]
- Root cause analysis: [If known]

**Issue #2:** [Description]
- Severity: [Critical/High/Medium/Low]
- Devices affected: [0x60/0x40/Both]
- Root cause analysis: [If known]

---

## Evidence Artifacts

### Logs
- [ ] UART console log: `[filename]`
  - Location: _______________

### Video Record
- [ ] Test execution video: `[filename]`
  - Duration: _______ seconds
  - Location: _______________
  - Notes: _______________

---

## Notes / Observations

### I2C Bus Quality
[Observations on signal integrity, timing, quality]

### Motor Controller Behavior
[Notes on how motor controllers responded to commands]

### Addressing Observations
[Specific observations about addressing, collisions, or quirks]

### Parameter Accuracy
[Did actual timing, voltages, frequencies match specifications?]

### Recommendations for Next Iteration
[Suggestions for improvements or additional testing]

### Follow-up Actions
- [ ] Action 1: [Description] - Owner: _______ - Due: _______
- [ ] Action 2: [Description] - Owner: _______ - Due: _______

---

## Sign-Off

### Test Status
**Final Status:** [ ] PASS [ ] FAIL [ ] CONDITIONAL PASS

### Review & Approval
- **Tested By:** [Tester Name] - Signature/Date: _______________
- **Reviewed By:** [Reviewer Name] - Signature/Date: _______________
- **Approved By:** [Reviewer Name] - Signature/Date: _______________

### Date Approved
**Date:** [YYYY-MM-DD]

### Archive Reference
**Location in Repository:** `/tests/integration/executions/phase_c/`
**Committed:** [ ] Yes [ ] No

---

**Template Version:** 1.0 | **Last Updated:** 2026-02-23 | **Created by:** Team04_DrivaPi Integration Test Team
