# TSF Evidence Guide

**Goal:** How to link artifacts to requirements
**Principle:** Each claim needs verifiable proof

> **Commands:** See [reference.md](reference.md)

---

## 📊 Evidence Types

### 1. Code (Implementation)

**What:** Source code implementing the requirement

```markdown
---
id: SWD-042
artifact:
  - type: code
    path: src/sensors/temperature.cpp
    description: Temperature sensor implementation
---
```

**Organization:**
```
src/
├── sensors/temperature.cpp
├── hmi/display.cpp
└── control/motor.cpp
```

---

### 2. Test (Verification)

**What:** Tests + execution results

```markdown
---
id: LLTC-042
artifact:
  - type: test
    path: tests/unit/test_temperature.cpp
    description: Sensor unit test

  - type: test
    path: artifacts/verification/tests/LLTC-042-results.xml
    description: Results (5/5 passed)
---
```

**Organization:**
```
tests/
├── unit/test_temperature.cpp
├── integration/test_can_bus.cpp
└── system/test_e2e.py

artifacts/verification/tests/
├── LLTC-042-junit.xml
└── LLTC-043-results.json
```

**JUnit XML format (preferred):**
```xml
<testsuite name="TempTests" tests="5" failures="0" errors="0">
  <testcase name="test_read_valid" time="0.045"/>
  <testcase name="test_timeout" time="0.067"/>
</testsuite>
```

---

### 3. Design (Architecture)

**What:** Diagrams, interface specs, design docs

```markdown
---
id: SRD-015
artifact:
  - type: design
    path: docs/design/architecture.puml
    description: System architecture diagram

  - type: design
    path: docs/design/can-bus-spec.md
    description: CAN bus interface specification
---
```

**Organization:**
```
docs/design/
├── architecture/
│   ├── system-overview.puml
│   └── component-diagram.png
└── interfaces/
    ├── can-bus-spec.md
    └── i2c-protocol.md
```

---

### 4. Review (Human Validation)

**What:** PRs, review commits, meeting notes

```markdown
---
id: SWD-042
reviewers:
  - name: "Carol Dev"
    email: "carol@example.com"
reviewed: "2025-10-21 — Reviewed by Carol"

artifact:
  - type: review
    path: https://github.com/SEAME-pt/Team04_DrivaPi/pull/142
    description: Code review with 2 approvals (ASIL B)
---
```

**Automatic evidence:**
- `reviewed:` field (with git SHA)
- Git commit log
- PR approvals on GitHub

---

### 5. Analysis (Automatic Checks)

**What:** Static analysis, coverage reports

```markdown
---
id: SWD-042
artifact:
  - type: analysis
    path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml
    description: Static analysis clean (0 errors)

  - type: coverage
    path: artifacts/verification/coverage/temperature.html
    description: Code coverage 98% lines
---
```

**Organization:**
```
artifacts/verification/
├── static-analysis/
│   ├── cppcheck-SWD-042.xml
│   └── clang-tidy-report.txt
└── coverage/
    └── lcov-report.html
```

---

### 6. Compliance (Standards)

**What:** Standards compliance documentation

```markdown
---
id: SWD-042
ASIL: B

artifact:
  - type: compliance
    path: docs/standards/iso26262/asil-justification.md
    description: ASIL B justification

  - type: compliance
    path: docs/standards/iso26262/hazard-analysis.md
    description: Hazard analysis (S2×E4×C2)
---
```

**Organization:**
```
docs/standards/
├── iso26262/
│   ├── asil-justification.md
│   └── hazard-analysis.md
└── autosar/
    └── component-mapping.md
```

---

## 🔗 How to Link Evidence

### In Requirement Frontmatter

```markdown
---
ref: SWD-042
artifact:
  - type: <type>
    path: <relative/path>
    description: "<What this proves>"
---
```

### Complete Example

```markdown
---
id: SWD-042
header: "Temperature sensor monitoring"
ASIL: B

artifact:
  # Implementation
  - type: code
    path: src/sensors/temperature.cpp
    description: TempSensor class

  # Tests
  - type: test
    path: tests/unit/test_temperature.cpp
    description: Unit tests
  - type: test
    path: artifacts/verification/tests/LLTC-042-results.xml
    description: Test results (5/5 passed)

  # Review
  - type: review
    path: https://github.com/SEAME-pt/Team04_DrivaPi/pull/42
    description: Code review 2 approvals

  # Analysis
  - type: analysis
    path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml
    description: Static analysis clean
  - type: coverage
    path: artifacts/verification/coverage/temperature.html
    description: 98% line coverage

  # Compliance
  - type: compliance
    path: docs/standards/iso26262/asil-b-temp.md
    description: ASIL B justification

acceptance:
  - GIVEN: I2C sensor at 0x48
    WHEN: readTemp() called
    THEN: Returns temp ±0.5°C in <10ms
---
The software SHALL read temperature via I2C...
```

---

## 📁 Naming Conventions

### Test Results

```
artifacts/verification/tests/<REQ-ID>-<type>.<ext>

Examples:
LLTC-042-junit.xml
LLTC-043-integration.json
```

### Static Analysis

```
artifacts/verification/static-analysis/<tool>-<REQ-ID>.<ext>

Examples:
cppcheck-SWD-042.xml
clang-tidy-SWD-042.txt
```

### Coverage

```
artifacts/verification/coverage/<module>.<ext>

Examples:
temperature.html
speed_widget.lcov
```

---

## ✅ Checklist by ASIL

### ASIL A (DrivaPi display features)

- [ ] 1+ reviewer
- [ ] Code implemented
- [ ] Unit tests (>60% coverage)
- [ ] Git history

### ASIL B (DrivaPi typical: sensors, control)

- [ ] 2+ reviewers
- [ ] Code implemented
- [ ] Unit tests (>80% coverage)
- [ ] Integration tests
- [ ] Static analysis clean
- [ ] PR with 2+ approvals

### ASIL C (Emergency stop)

- [ ] All of ASIL B +
- [ ] System tests
- [ ] Independent review
- [ ] >90% coverage
- [ ] FMEA documented

---

## 🎯 Best Practices

1. **Link evidence as you create** - Don't leave for later
2. **Paths relative to repo root** - Portability
3. **Clear descriptions** - What each evidence proves
4. **Organize by requirement ID** - Easy to find
5. **Automate generation** - CI/CD for test results
6. **Review evidence with code** - PR includes both
7. **Keep updated** - Re-run tests after changes

---

## 🔄 Evidence Workflow

```bash
# 1. Create requirement
trudag manage create-item SWD 042 reqs/swd

# 2. Implement
nano src/sensors/temperature.cpp

# 3. Test
./run_tests.sh > artifacts/verification/tests/LLTC-042-results.xml

# 4. Analyze
cppcheck src/sensors/temperature.cpp 2> artifacts/verification/static-analysis/cppcheck-SWD-042.xml

# 5. Link everything in requirement
nano reqs/swd/SWD-042.md  # Add artifact: entries

# 6. Commit evidence + requirement together
git add src/ tests/ artifacts/ reqs/swd/SWD-042.md
git commit -m "feat(swd): Add SWD-042 with full evidence"
```

---

## 🐛 Common Problems

### "Evidence file not found"

**Cause:** Incorrect path

**Fix:**
```bash
# Verify path relative to root
ls artifacts/verification/tests/LLTC-042-junit.xml

# Fix in requirement
nano reqs/lltc/LLTC-042.md
```

### "Evidence not in report"

**Cause:** Not linked in frontmatter

**Fix:** Add `artifact:` section to requirement

### "Old evidence after code change"

**Cause:** Outdated test results

**Fix:**
```bash
# Re-run tests
./run_tests.sh

# Regenerate report
trudag publish --output-dir artifacts/trustable-report

# Commit updated evidence
git add artifacts/verification/
git commit -m "test: Update evidence for SWD-042"
```

---

**More info:**
- Commands → [reference.md](reference.md)
- Workflows → [workflow.md](workflow.md)
- Theory → [training.md](training.md)
