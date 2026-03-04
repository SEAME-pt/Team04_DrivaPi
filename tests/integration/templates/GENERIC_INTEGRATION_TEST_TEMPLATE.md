# Integration Test Execution Template - [Phase Name]
## [Test Scope Description]

---

## Header / Metadata
- **Date:** [YYYY-MM-DD]
- **Time Started:** [HH:MM]
- **Tester Name:** [Full Name]
- **Test Phase:** [Phase Identifier]
- **Test Cycle:** [Sprint X]

---

## Test Information
- **Phase Name:** [Full descriptive name of test phase]
- **Test Objective:** [Primary objective and goal of this test phase]
- **Related Requirements:** 
  - [Requirement 1]
  - [Requirement 2]
  - [Related documentation paths]

---

## Environment Setup

### Hardware Required
- [ ] [Hardware component 1]
- [ ] [Hardware component 2]
- [ ] [Additional hardware as needed]

### Software Required
- [ ] [Software/Firmware 1]
- [ ] [Software/Firmware 2]
- [ ] [Development/testing tools]
- [ ] [Additional software as needed]

### Configuration Settings
- **[Parameter 1]:** [Value/Range]
- **[Parameter 2]:** [Value/Range]
- **[Additional parameters as needed]**

### Prerequisites Checklist
- [ ] [Prerequisite condition 1]
- [ ] [Prerequisite condition 2]
- [ ] [Additional prerequisites as needed]

---

## Pre-Test Checklist
- [ ] [Pre-test verification item 1]
- [ ] [Pre-test verification item 2]
- [ ] [Physical measurement]: _______ [unit] (expected: [value])
- [ ] [Component status verification]
- [ ] [Connection verification]
- [ ] [Test environment stable and isolated]

---

## Execution Steps

### Step 1: [Step Title/Description]
**Procedure:**
1. [Action 1]
2. [Action 2]
4. [Additional actions as needed]

**Expected Output:**
```
[Expected console/log output]
[Expected measurements]
[Expected behavior]
```

**Actual Output:**
```
[Record actual output here]
```

**Measurements/Observations:**
- [Measurement 1]: _______ [unit]
- [Measurement 2]: _______ [unit]
- [ Observation 1 ]: [ Description ]

**Status:** [ ] PASS [ ] FAIL [ ] SKIPPED

**Notes/Issues:** [If any]

---

### Step [N]: [Step Title/Description]
**Procedure:**
1. [Action 1]
2. [Action 2]
3. [Additional actions as needed]

**Expected Output:**
```
[Expected console/log output]
[Expected measurements]
[Expected behavior]
```

**Actual Output:**
```
[Record actual output here]
```

**Measurements/Observations:**
- [Measurement 1]: _______ [unit]
- [ Observation 1 ]: [ Description ]

**Status:** [ ] PASS [ ] FAIL [ ] SKIPPED

**Notes/Issues:** [If any]

---

## Results Recording

### Overall Status
- [ ] **PASS** - All acceptance criteria met
- [ ] **FAIL** - One or more acceptance criteria not met
- [ ] **CONDITIONAL PASS** - Minor issues requiring documentation

### Pass/Fail Criteria Met
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Additional criteria as needed]

### Performance Metrics (if applicable)
| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| [Metric 1] | ___ | [threshold] | PASS/FAIL |
| [Metric 2] | ___ | [threshold] | PASS/FAIL |
| [Other Metric] | ___ | [threshold] | PASS/FAIL |

### Issues Encountered
- [ ] No issues
- [ ] Issues found (describe below):

**Issue #1:** [Description]
- Severity: [Critical/High/Medium/Low]
- Impact: [Description of impact]
- Root cause: [If known]
- Workaround: [If applicable]
- Follow-up Required: [Yes/No]

**Issue #2:** [Description]
- Severity: [Critical/High/Medium/Low]
- Impact: [Description of impact]
- Root cause: [If known]
- Workaround: [If applicable]
- Follow-up Required: [Yes/No]

---

## Evidence Artifacts

### Logs Captured
- [ ] [Log type 1]: `[filename]`
  - Location: _______________
  - [Additional metadata]

### Screenshots (if applicable)
- [ ] [Screenshot description]: `[filename]`
  - Location: _______________

### Video Record
- [ ] Test execution video: `[filename]`
  - Duration: _______ seconds
  - Location: _______________
  - Notes: _______________

### Physical Observations
- [ ] [Component] condition: [Status]
  - Notes: _______________
- [ ] [Component] behavior: [Status]
  - Notes: _______________

---

## Notes / Observations

### General Observations
[Record general notes about test execution, environment, or interesting findings]

### [Domain-Specific Observations]
[e.g., Signal Quality, Communication Stability, Component Behavior]
[Analysis of specific technical aspects relevant to the test phase]

### Anomalies Found
[Document any unexpected behaviors or discrepancies]

### Environmental Factors
[Note any environmental conditions that may have affected the test]

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
**Location in Repository:** `/tests/integration/executions/[phase_folder]/`
**Committed:** [ ] Yes [ ] No

---

**Template Version:** 1.0 | **Last Updated:** [2026-03-02] | **Created by:** Team04_DrivaPi
