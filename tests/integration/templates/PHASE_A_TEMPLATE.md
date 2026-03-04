# Integration Test Execution Template - Phase A
## PS3 Controller → Raspberry Pi

---

## Header / Metadata
- **Date:** [YYYY-MM-DD]
- **Time Started:** [HH:MM]
- **Tester Name:** [Full Name]
- **Test Phase:** A
- **Test Cycle:** [Sprint X]

---

## Test Information
- **Phase Name:** PS3 Controller Input Validation & Command Decoding
- **Test Objective:** Validate PS3 controller input is correctly decoded
- **Related Requirements:** 
  - Integration Test Plan - Phase A
  - `/docs/tests/integration-test-plan.md`
  - Controller application specification

---

## Environment Setup

### Hardware Required
- [ ] PS3 Controller
- [ ] Raspberry Pi 5
- [ ] USB dongle for PS3 controller connection
- [ ] Network connectivity (if testing remotely)

### Software Required
- [ ] Controller application
- [ ] SSH client (if testing remotely)

### Configuration Settings
- **Controller Port:** __________ 

### Prerequisites Checklist
- [ ] PS3 controller paired with Raspberry Pi
- [ ] Controller application installed and ready

---

## Pre-Test Checklist
- [ ] PS3 controller fully charged (>80%)
- [ ] Raspberry Pi powered on and responsive
- [ ] Controller application deployed and ready to start
- [ ] Test environment isolated from other network traffic and interfering processes
- [ ] SSH connection tested (if testing remotely)

---

## Execution Steps

### Step 1: Start Controller Application
**Procedure:**
1. Connect to Raspberry Pi directly or via SSH
2. Navigate to controller application directory
3. Start the controller application with debug logging enabled
4. Wait for initialization complete message (typically 2-3 seconds)

**Expected Output:**
```
Controller Application Started
Listening for PS3 controller input on [port]
Ready for input
```

**Actual Output:**
```
[Record actual output here]
```

**Notes/Issues:** [If any]

---

### Step 2: Connect PS3 Controller
**Procedure:**
1. Press start button on PS3 controller
2. Observe connection confirmation on Raspberry Pi
3. Verify controller connection status in application logs

**Expected Output:**
```
PS3 Controller Connected
```

**Actual Output:**
```
[Record actual output here]
```

**Notes/Issues:** [If any]

---

### Step 3: Test Analog Stick Input
**Procedure:**
1. **Left Analog Stick:**
   - Move left analog stick to full up position
   - Record decoded value in application
   - Repeat for: down and center
2. **Right Analog Stick:**
   - Move right analog stick to full left position
   - Record decoded value in application
   - Repeat for: right and center

**Expected Output:**
- Left stick center: Y= 0
- Left stick full up: Y=4096
- Left stick full down: Y=-4096
- Right stick center: X=90
- Right stick full left: X=0
- Right stick full right: X=180
- Each direction shows correct analog value decoding for both sticks

**Actual Output:**
```
[Record actual output here]
```

**Notes/Issues:** [If any]

---

### Step 4: Test Button Inputs
**Procedure:**
1. Press each button sequentially: Cross, Circle, Triangle, Square
2. Record decoded button press in application logs
3. Test L1, L2, R1, R2 shoulder buttons

**Button Test Results:**

| Button | Decoded Value | Status |
|--------|---------------|--------|
| Cross (X) | ___ | PASS/FAIL |
| Circle (O) | ___ | PASS/FAIL |
| Triangle (Δ) | ___ | PASS/FAIL |
| Square (□) | ___ | PASS/FAIL |
| L1 | ___ | PASS/FAIL |
| L2 | ___ | PASS/FAIL |
| R1 | ___ | PASS/FAIL |
| R2 | ___ | PASS/FAIL |

---

### Step 5: Stress Test - Rapid Input
**Procedure:**
1. Perform rapid button presses (10 presses/second for 10 seconds)
2. Monitor for dropped inputs or errors
3. Verify no buffer overflow or crash occurs

**Expected Output:**
- All inputs captured without loss

**Actual Output:**
```
[Record measurements here]
```

**Notes/Issues:** [If any]

---

### Step 6: Stop Test & Verify Clean Shutdown
**Procedure:**
1. Disconnect PS3 controller
2. Stop controller application gracefully

**Expected Output:**
```
PS3 Controller Disconnected
Controller Application Shutting Down
All resources released
```

**Actual Output:**
```
[Record actual output here]
```

**Notes/Issues:** [If any]

---

## Results Recording

### Overall Status
- [ ] **PASS** - All acceptance criteria met
- [ ] **FAIL** - One or more acceptance criteria not met
- [ ] **CONDITIONAL PASS** - Minor issues requiring documentation

### Pass/Fail Criteria Met
- [ ] 100% command decoding accuracy achieved
- [ ] All button inputs correctly decoded
- [ ] All analog values correctly mapped
- [ ] No message loss during stress test
- [ ] Application started and stopped cleanly

### Issues Encountered
- [ ] No issues
- [ ] Issues found (describe below):

**Issue #1:** [Description]
- Severity: [Critical/High/Medium/Low]
- Workaround: [If applicable]
- Follow-up Required: [Yes/No]

**Issue #2:** [Description]
- Severity: [Critical/High/Medium/Low]  
- Workaround: [If applicable]
- Follow-up Required: [Yes/No]

---

## Evidence Artifacts

### Logs Captured (if applicable)
- [ ] Controller application log: `[filename]`
  - Location: _______________

### Video Record
- [ ] Test execution video: `[filename]`
  - Duration: _______ seconds
  - Location: _______________
  - Notes: _______________

### Physical Observations
- [ ] PS3 Controller condition: [Good/Acceptable/Issues]
  - Notes: _______________
- [ ] Raspberry Pi behavior: [Normal/Concerning]
  - Notes: _______________

---

## Notes / Observations

### General Observations
[Record general notes about test execution, environment, or interesting findings]

### Anomalies Found
[Document any unexpected behaviors or discrepancies]

### Recommendations for Next Iteration
[Suggestions for improvement or follow-up testing]

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
**Location in Repository:** `/tests/integration/executions/phase_a/`
**Committed:** [ ] Yes [ ] No

---

**Template Version:** 1.0 | **Last Updated:** 2026-02-23 | **Created by:** Team04_DrivaPi
