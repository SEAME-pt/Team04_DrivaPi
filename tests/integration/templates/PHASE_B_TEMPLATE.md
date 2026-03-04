# Integration Test Execution Template - Phase B
## Raspberry Pi ↔ STM32 CAN Bidirectional Communication

---

## Header / Metadata
- **Date:** [YYYY-MM-DD]
- **Time Started:** [HH:MM]
- **Tester Name:** [Full Name]
- **Test Phase:** B
- **Test Cycle:** [Sprint X]

---

## Test Information
- **Phase Name:** CAN Bidirectional Communication
- **Test Objective:** Verify bidirectional CAN communication between Raspberry Pi and STM32
- **Related Requirements:**
  - Integration Test Plan - Phase B
  - `/docs/tests/integration-test-plan.md`
  - CAN communication specification

---

## Environment Setup

### Hardware Required
- [ ] Raspberry Pi 5 with CAN controller/transceiver hat
- [ ] STM32U585 microcontroller
- [ ] CAN transceiver on stm32 board
- [ ] CAN termination resistors (120Ω) at both ends
- [ ] Oscilloscope (if used)

### Software Required
- [ ] CAN driver configured on Raspberry Pi
- [ ] STM32 firmware loaded with CAN interrupt functionality
- [ ] Raspberry Pi C++ bidirectional communication test code compiled and ready 

### Configuration Settings
- **CAN Bus:** [CAN1]
- **Baud Rate:** [1Mbps]

### Prerequisites Checklist
- [ ] CAN transceiver powered and operational
- [ ] Termination resistors properly installed
- [ ] CAN bus continuity verified with multimeter
- [ ] CAN driver loaded on Raspberry Pi
- [ ] STM32 firmware programmed and running
- [ ] Network isolated from traffic

---

## Pre-Test Checklist
- [ ] CAN bus powered
- [ ] All CAN connectors seated properly
- [ ] No visible damage to CAN cables or connectors
- [ ] Oscilloscope connected to CAN bus (if used)
- [ ] Monitoring software started and recording enabled
- [ ] Both Raspberry Pi and STM32 powered and responsive
- [ ] CAN interface brought up: `ip link set can1 up`
- [ ] Test environment stable and isolated

---

## Execution Steps

### Step 1: Verify CAN Bus Physical Connectivity
**Procedure:**
1. Measure voltage between CAN_H and CAN_L on both ends
2. Verify CAN_H and CAN_L not shorted together
3. Check termination resistor resistance (should be ~120Ω)
4. Verify all connectors are seated properly

**Expected Output:**
```
CAN_H: ~2.5V at rest
CAN_L: ~2.5V at rest
Termination: ~60Ω (two 120Ω in parallel)
```

**Actual Output:**
```
[Record measurements here]
```

**Measurements:**
- CAN_H voltage: _______ V
- CAN_L voltage: _______ V
- Differential voltage: _______ V
- Termination resistance: _______ Ω

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

### Step 2: Initialize CAN on Raspberry Pi
**Procedure:**
1. Bring up CAN interface: `sudo ip link set can1 up type can bitrate 1000000`
2. Verify interface is up: `ip link show can1`

**Expected Output:**
```
can1: <NOARP,UP,LOWER_UP> mtu 16 qdisc mq state UP mode DEFAULT group 33
    link/can  promiscuity 0
    RX packets: 0  TX packets: 0
```

**Actual Output:**
```
[Record actual output here]
```

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

### Step 3: Verify STM32 CAN Configuration
**Procedure:**
1. Connect to STM32 via serial terminal
2. Verify CAN peripheral initialized
3. Check baud rate matches Raspberry Pi
4. Verify CAN RX interrupt is enabled and configured to echo messages back

**Expected Output:**
```
STM32 CAN Controller Initialized
Baud Rate: 1000000 bps
RX Interrupt: Enabled
Echo Mode: Active
TX Ready
```

**Actual Output:**
```
[Record actual output here]
```

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

### Step 4: Single Message Transmission - Rpi → STM32
**Procedure:**
1. Send test message from Raspberry Pi to STM32
2. Use cansend tool: `cansend can1 123#AABBCCDDEE`
3. Capture on logic analyzer (if available)
4. Verify message received on STM32 and echoed back

**Expected Output:**
```
CAN message transmitted with ID 0x123
Payload: AA BB CC DD EE
STM32 received message successfully
STM32 echoed message back to Raspberry Pi
No CAN errors reported
```

**Actual Output:**
```
[Record actual output here]
```

**CAN Message Details:**
- Message ID Transmitted: 0x_______
- Payload Transmitted: _______________
- STM32 Confirmation: [Received/Not Received]

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---

### Step 5: Bidirectional Communication Test - Rpi → STM32 → Rpi
**Procedure:**
1. Compile and run the C++ communication test program on Raspberry Pi
2. The program will:
   - Send 1000 CAN messages with ID 0x123
   - Each message contains a timestamp (8 bytes, packed uint64_t in microseconds)
   - STM32 receives each message via CAN interrupt and immediately echoes it back
   - Raspberry Pi receives the echo and verifies communication is working
   - 100ms delay between each iteration
3. Monitor the test output for successful message exchanges
4. Record any timeouts or errors

**Test Execution:**
```bash
# Compile the C++ communication test code
c++ -o can_communication_test can_latency_receive_test.cpp

# Run the communication test
./can_communication_test > communication_results

# Test will output values for each iteration
# Or "TIMEOUT" if no response within 100ms
# Or "RX_ERROR" if response format is incorrect
```

**Expected Output:**
```
Successful message exchanges with minimal timeouts or errors
Majority of iterations complete successfully
```

**Actual Output:**
```
[Record actual output here]
```

**Test Results:**
- Total Iterations: 1000
- Successful Communications: _______
- Timeouts: _______
- Errors: _______
- Success Rate: _______%

**Pass Criteria:** 
- Success Rate > 95% ✓ (Actual: _______% )

**Status:** [ ] PASS [ ] FAIL

**Notes/Issues:** [If any]

---



## Results Recording

### Overall Status
- [ ] **PASS** - All acceptance criteria met
- [ ] **FAIL** - One or more acceptance criteria not met
- [ ] **CONDITIONAL PASS** - Minor issues requiring documentation

### Pass/Fail Criteria Met
- [ ] CAN bus physical connectivity verified
- [ ] Bidirectional communication working (Rpi ↔ STM32)
- [ ] Single message transmission test passed
- [ ] STM32 CAN interrupt echo functionality working
- [ ] Success rate > 95% during communication test
- [ ] No critical errors preventing communication

### Key Measurements Summary
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Total Iterations | 1000 | N/A | INFO |
| Successful Communications | ___ | > 950 | PASS/FAIL |
| Success Rate | ___% | > 95% | PASS/FAIL |
| Timeouts | ___ | < 50 | PASS/FAIL |
| Errors | ___ | < 10 | PASS/FAIL |

### Issues Encountered
- [ ] No issues
- [ ] Issues found (describe below):

**Issue #1:** [Description]
- Severity: [Critical/High/Medium/Low]
- Impact: [Impact on system]
- Workaround: [If applicable]

**Issue #2:** [Description]
- Severity: [Critical/High/Medium/Low]
- Impact: [Impact on system]
- Workaround: [If applicable]

### Communication Test Summary
- Total Iterations: 1000
- Successful Communications: _______
- Success Rate: _______% 
- Timeout Count: _______
- Error Count: _______
- Communication Status: [Stable/Unstable]

---

## Evidence Artifacts

### CAN Logs
- [ ] Communication test raw output: `communication_results`
  - Location: _______________
  - Samples: 1000
  - Format: Plain text

### Screenshots
- [ ] Test execution terminal output: `[filename]`

### Video Record
- [ ] Test execution video: `[filename]`
  - Duration: _______ seconds
  - Location: _______________
  - Notes: _______________
  
---

## Notes / Observations

### General Observations
[Record general notes about test execution and environment]

### CAN Bus Quality
[Notes on signal quality, noise, interference observed]

### Communication Observations
[Analysis of communication stability and reliability]

### Recommendations for Next Iteration
[Suggestions for improvements]

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
**Location in Repository:** `/tests/integration/executions/phase_b/`
**Committed:** [ ] Yes [ ] No

---

**Template Version:** 1.0 | **Last Updated:** 2026-02-23 | **Created by:** Team04_DrivaPi Integration Test Team
