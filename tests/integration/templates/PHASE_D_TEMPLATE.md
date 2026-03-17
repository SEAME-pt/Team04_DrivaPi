# Integration Test Execution Template - Phase D
## Speed Sensor → STM32 Pulse Signal Validation

---

## Header / Metadata
- **Date:** [YYYY-MM-DD]
- **Time Started:** [HH:MM]
- **Tester Name:** [Full Name]
- **Test Phase:** D
- **Test Cycle:** [Sprint X]

---

## Test Information
- **Phase Name:** Speed Sensor Pulse Detection Basic Integration
- **Test Objective:** Validate that the STM32 correctly detects speed sensor pulses via external interrupt and increments the pulse counter, verifying basic hardware integration
- **Related Requirements:**
  - Integration Test Plan - Phase D
  - `/docs/tests/integration-test-plan.md`
  - Speed sensor datasheet and pulse specification

---

## Environment Setup

### Hardware Required
- [ ] STM32U585 with external interrupt capability (EXTI)
- [ ] Speed sensor
- [ ] Test wheel or mechanism to trigger sensor pulses
- [ ] Power supply for sensor and STM32
- [ ] USB cable for STM32 UART interface
- [ ] Oscilloscope (optional - for signal verification)

### Software Required
- [ ] STM32 firmware with speed sensor interrupt handler
- [ ] UART terminal (115200 baud)

### Configuration Settings
- **Sensor Type:** LM393 (Dual Differential Comparator)
- **Input Pin:** SPEED_SENSOR_Pin (EXTI9)
- **Interrupt Type:** External interrupt (rising edge)
- **UART Baud Rate:** 115200

### Prerequisites Checklist
- [ ] Sensor power supply verified and stable
- [ ] Sensor signal properly connected to STM32 EXTI pin
- [ ] External interrupt configured in firmware
- [ ] UART logging enabled and functional
- [ ] Test wheel or trigger mechanism ready

---

## Pre-Test Checklist
- [ ] Sensor power voltage: _______ V (expected: 5V)
- [ ] Signal output line not shorted
- [ ] STM32 powered and firmware loaded
- [ ] UART connected and terminal open at 115200 baud
- [ ] Test environment stable and isolated
- [ ] Initial pulse count displayed as 0

---

## Execution Steps

### Step 1: Verify Sensor Signal Physical Characteristics (Optional)
**Procedure:**
1. Use oscilloscope to verify sensor signal (if available)
2. Check signal voltage levels
3. Verify signal is clean and suitable for STM32 input

**Expected Output:**
```
Sensor signal detected
Voltage levels: 0V - 3.3V
Signal clean, no excessive noise
```

**Actual Output:**
```
[Record measurements here - or mark N/A if oscilloscope not used]
```

**Signal Measurements (Optional):**
- Signal voltage (high): _______ V
- Signal voltage (low): _______ V
- Signal quality: [ ] Clean [ ] Noisy [ ] N/A

**Status:** [ ] PASS [ ] FAIL [ ] SKIPPED

**Notes/Issues:** [If any]

---

### Step 2: Verify Firmware and UART Connection
**Procedure:**
1. Ensure STM32 firmware with speed sensor interrupt handler is loaded
2. Open UART terminal at 115200 baud
3. Reset STM32 and verify initial state
4. Confirm pulse count starts at 0

**Expected Output:**
```
UART connection established
Firmware running
Initial pulse count: 0
Ready for pulse detection
```

**Actual Output:**
```
[Record output here]
```

**Verification:**
- UART connected: [ ] Yes [ ] No
- Firmware responsive: [ ] Yes [ ] No
- Initial pulse count: _______

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

### Step 3: Single Pulse Detection Test
**Procedure:**
1. Manually trigger the sensor once
2. Observe UART output for pulse detection message
3. Verify pulse count increments by 1

**Expected UART Output:**
```
Pulse detected! Total count: 1
```

**Actual UART Output:**
```
[Record output here]
```

**Results:**
- Pulse detected: [ ] Yes [ ] No
- Count incremented: [ ] Yes [ ] No
- UART message correct: [ ] Yes [ ] No

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

### Step 4: Multiple Pulse Detection Test
**Procedure:**
1. Trigger the sensor multiple times
2. Count manually how many times you triggered the sensor
3. Compare manual count with STM32 pulse count in UART
4. Verify all pulses are detected

**Test Configuration:**
- Manual trigger count: 10 pulses

**Expected UART Output (last message):**
```
Pulse detected! Total count: 10
```

**Actual Output:**
```
[Record UART messages here]
```

**Pulse Count Results:**
- Expected pulse count: 10
- Actual pulse count: _______
- Difference: _______ pulses
- Detection rate: _______ %

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

### Step 5: Continuous Pulse Detection Test
**Procedure:**
1. Rotate the wheel continuously at moderate speed for 30 seconds
2. Observe UART messages streaming pulse counts
3. Verify no pulses are missed during continuous operation
4. Check for any interrupt handling issues

**Expected Behavior:**
```
Pulse detected! Total count: 1
Pulse detected! Total count: 2
Pulse detected! Total count: 3
...
Pulse detected! Total count: N
(continuous messages)
```

**Actual Output:**
```
[Record observation here]
```

**Results:**
- Continuous detection: [ ] Working [ ] Not working
- Messages streaming: [ ] Yes [ ] No
- Any missed pulses observed: [ ] Yes [ ] No
- Final pulse count: _______

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

## Results Recording

### Overall Status
- [ ] **PASS** - All acceptance criteria met
- [ ] **FAIL** - One or more acceptance criteria not met
- [ ] **CONDITIONAL PASS** - Minor issues requiring documentation

### Pass/Fail Criteria Met
- [ ] Single pulse detection working correctly
- [ ] UART message displays on pulse detection
- [ ] Pulse count increments correctly
- [ ] Multiple pulses detected accurately
- [ ] Continuous pulse detection working without missed pulses
- [ ] No interrupt handling errors observed

### Issues Encountered
- [ ] No issues
- [ ] Issues found (describe below):

**Issue #1:** [Description]
- Severity: [Critical/High/Medium/Low]
- Test affected: [Single/Multiple/Continuous]
- Root cause: [If known]
- Workaround: [If applicable]

**Issue #2:** [Description]
- Severity: [Critical/High/Medium/Low]
- Test affected: [Single/Multiple/Continuous]
- Root cause: [If known]
- Workaround: [If applicable]

### Performance Metrics Summary
- Total pulses detected: _______
- Pulse detection accuracy: _______ %
- Missed pulses: _______

---

## Evidence Artifacts

### Video Record
- [ ] Test execution video: `[filename]`
  - Duration: _______ seconds
  - Location: _______________
  - Notes: _______________

### Logs (Optional)
- [ ] UART console log: `[filename]`
  - Location: _______________
  - Pulse messages captured: _______

### Screenshots (Optional)
- [ ] UART output showing pulse detection: `[filename]`
- [ ] Oscilloscope waveform (if used): `[filename]`

---

## Notes / Observations

### Sensor Signal Quality
[Observations about signal quality, trigger mechanism reliability]

### Pulse Detection Performance
[Analysis of detection accuracy, any missed pulses, UART response]

### Interrupt Handling
[Notes on interrupt behavior, UART message timing]

### Environmental Factors
[Any factors affecting pulse detection]

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
**Location in Repository:** `/tests/integration/executions/phase_d/`
**Committed:** [ ] Yes [ ] No

---

**Template Version:** 1.0 | **Last Updated:** 2026-02-23 | **Created by:** Team04_DrivaPi Integration Test Team
