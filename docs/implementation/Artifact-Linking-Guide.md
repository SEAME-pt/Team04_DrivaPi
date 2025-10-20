# Artifact Linking Implementation Guide

**Purpose:** Step-by-step guide to link requirements to design documents, source code, and tests

---

## Overview

**Why Link Artifacts?**
- Proves requirements are implemented
- Enables impact analysis (change propagation)
- Required for TSF compliance
- Closes gaps identified in `gap-report.csv`

---

## Artifact Types

### 1. Design Artifacts
Documents explaining HOW the system works:
- Architecture diagrams
- Design documents
- Interface specifications
- Data models

### 2. Code Artifacts
Source code implementing the requirement:
- C++ source files (`.cpp`)
- Header files (`.hpp`, `.h`)
- Python modules (`.py`)
- Configuration files

### 3. Test Artifacts
Verification that requirement is met:
- Test specifications
- Test cases (unit, integration, system)
- Test scripts
- Test reports

---

## YAML Artifact Syntax

Add to your requirement YAML:

```yaml
artifact:
  - type: design
    path: docs/architecture/battery-monitoring.md
    description: Battery voltage monitoring architecture

  - type: code
    path: src/sensors/battery_voltage.cpp
    description: ADC reading implementation

  - type: test
    path: tests/unit/test_battery_voltage.py
    description: Unit tests for battery voltage reading
```

### Supported Types:
- `design` - Architecture, design documents
- `code` - Source code, scripts
- `test` - Test cases, test specifications
- `doc` - Additional documentation
- `config` - Configuration files

---

## Step-by-Step Implementation

### Phase 1: Document Architecture (Week 1)

#### Step 1.1: Create Architecture Document

Create `docs/architecture/drivapiS-system-architecture.md`:

```markdown
# DrivaPi System Architecture

## Overview
DrivaPi is an automotive HMI display system for Raspberry Pi...

## Components

### 1. Sensor Interface Module
- **Purpose:** Read vehicle sensors (speed, temperature, battery)
- **Implementation:** `src/sensors/`
- **Requirements:** SRD-001, SRD-002

### 2. Display Manager
- **Purpose:** Render UI on Qt display
- **Implementation:** `src/display/`
- **Requirements:** SRD-003

### 3. Data Processing
- **Purpose:** Filter and validate sensor data
- **Implementation:** `src/processing/`
- **Requirements:** SRD-004
```

#### Step 1.2: Link Architecture to System Requirements

Edit `reqs/srd/SRD-001.yml`:

```yaml
ref: SRD-001
header: Vehicle Speed Monitoring
text: |
  The system shall monitor vehicle speed via OBD-II interface
  with accuracy of ±1 km/h
links: [URD-001]
artifact:
  - type: design
    path: docs/architecture/drivapi-system-architecture.md
    description: System architecture overview
reviewers: [your-name]
reviewed: ''
```

---

### Phase 2: Link Existing Code (Week 1-2)

#### Step 2.1: Identify Relevant Code

For each SWD requirement, find implementing code:

```bash
# Search codebase for relevant functionality
grep -r "battery" src/
grep -r "speed" src/
grep -r "display" src/
```

#### Step 2.2: Add Code Artifacts

Example for `reqs/swd/SWD-001.yml`:

```yaml
ref: SWD-001
header: Battery Voltage ADC Implementation
text: |
  The software shall read battery voltage via ADC channel 0
  with 12-bit resolution at 10Hz sampling rate
links: [SRD-002]
artifact:
  - type: design
    path: docs/architecture/sensor-interface-design.md
    description: Sensor interface detailed design

  - type: code
    path: src/sensors/battery_voltage.cpp
    description: Battery voltage ADC reading implementation

  - type: code
    path: src/sensors/battery_voltage.h
    description: Battery voltage sensor interface header

  - type: config
    path: config/adc_channels.yaml
    description: ADC channel configuration
reviewers: [dev-lead]
reviewed: ''
```

---

### Phase 3: Link Test Cases (Week 2)

#### Step 3.1: Create Test Specifications

For complex requirements, create detailed test specs:

Create `tests/specs/test-spec-battery-voltage.md`:

```markdown
# Test Specification: Battery Voltage Reading

**Requirement:** SWD-001
**ASIL Level:** B

## Test Cases

### TC-BV-001: Nominal Voltage Reading
- **Precondition:** Battery voltage = 12.5V
- **Steps:**
  1. Initialize ADC
  2. Read channel 0
  3. Convert to voltage
- **Expected:** Reading = 12.5V ± 0.1V
- **ASIL Coverage:** B

### TC-BV-002: Low Voltage Detection
- **Precondition:** Battery voltage = 10.0V
- **Expected:** Low battery warning triggered
```

#### Step 3.2: Link Tests to Requirements

Update `reqs/lltc/LLTC-001.yml`:

```yaml
ref: LLTC-001
header: Battery Voltage Test Suite
text: |
  Verify battery voltage reading accuracy and error handling
links: [SWD-001]
artifact:
  - type: test
    path: tests/specs/test-spec-battery-voltage.md
    description: Detailed test specification

  - type: test
    path: tests/unit/test_battery_voltage.py
    description: Unit test implementation

  - type: test
    path: tests/integration/test_sensor_interface.py
    description: Integration tests for sensor interface
reviewers: [qa-lead]
reviewed: ''
```

---

### Phase 4: Update Templates (Week 2)

#### Step 4.1: Add Artifact Section to Templates

Update `reqs/templates/SWD-000.yml`:

```yaml
ref: SWD-000
header: Template Software Requirement
text: |
  The software shall... [describe specific behavior]
rationale: |
  [Why this requirement exists]
links: [SRD-000]  # Parent system requirement

# Add artifact section to template
artifact:
  - type: design
    path: docs/design/component-name.md
    description: Detailed design document

  - type: code
    path: src/module/implementation.cpp
    description: Source code implementation

  - type: test
    path: tests/unit/test_implementation.py
    description: Unit tests

reviewers: []
reviewed: ''
```

Repeat for `URD-000.yml`, `SRD-000.yml`, `LLTC-000.yml`.

---

## Validation & Verification

### After Adding Artifacts:

#### 1. Validate YAML Syntax
```bash
python scripts/reqs_lint.py
```

#### 2. Check File Existence
```bash
# Verify all artifact paths exist
python scripts/verify_artifacts.py  # (create this script)
```

Example `scripts/verify_artifacts.py`:

```python
#!/usr/bin/env python3
"""Verify all artifact paths exist"""
import yaml
import sys
from pathlib import Path

def check_artifacts(req_file):
    with open(req_file) as f:
        req = yaml.safe_load(f)

    if 'artifact' not in req:
        return True

    errors = []
    for artifact in req['artifact']:
        path = Path(artifact['path'])
        if not path.exists():
            errors.append(f"Missing: {path}")

    return errors

# Run for all requirements...
```

#### 3. Run Traceability Check
```bash
python scripts/traceability_check.py
```

#### 4. Review Gap Report
```bash
cat artifacts/traceability/gap-report.csv
```

Expected: No more "missing artifact" entries!

---

## Best Practices

### ✅ DO:
- **Use relative paths** from repository root
- **Link to stable paths** (avoid generated files)
- **Include descriptions** to explain relationship
- **Keep paths updated** if files move
- **Link multiple artifacts** if needed

### ❌ DON'T:
- Link to external URLs (not under version control)
- Link to compiled binaries
- Link to temporary files
- Use absolute filesystem paths
- Link to files outside repository

---

## Maintenance

### When Code Changes:
1. Review affected requirements
2. Update artifact paths if files moved
3. Add new artifacts if functionality added
4. Re-run traceability check

### When Requirements Change:
1. Check if artifact links still valid
2. Update descriptions if behavior changed
3. Mark requirement as `reviewed: ''` (needs re-approval)

---

## Example: Complete Requirement with Artifacts

```yaml
ref: SWD-002
header: HMI Speed Display Rendering
text: |
  The software shall render vehicle speed on the Qt HMI display
  with refresh rate of 10Hz and latency < 100ms from sensor read

  Acceptance Criteria:
  - Display updated within 100ms of new sensor data
  - Font size: 48pt for speed value
  - Units displayed: "km/h"
  - Decimal precision: 1 decimal place

rationale: |
  Users need real-time speed feedback for safe driving.
  10Hz refresh provides smooth display updates without flicker.

links:
  - SRD-003  # Parent: Display vehicle speed on HMI

artifact:
  - type: design
    path: docs/design/hmi-display-components.md
    description: HMI component architecture and Qt widget hierarchy

  - type: design
    path: docs/design/display-performance-analysis.md
    description: Latency analysis and optimization strategy

  - type: code
    path: src/hmi/speedometer_widget.cpp
    description: Qt speedometer widget implementation

  - type: code
    path: src/hmi/speedometer_widget.h
    description: Speedometer widget interface

  - type: code
    path: src/hmi/display_manager.cpp
    description: Display update manager with 10Hz timer

  - type: test
    path: tests/specs/hmi-display-test-spec.md
    description: Comprehensive display test specification

  - type: test
    path: tests/unit/test_speedometer_widget.cpp
    description: Unit tests for speedometer rendering

  - type: test
    path: tests/performance/test_display_latency.py
    description: Display latency measurement tests

  - type: config
    path: config/hmi_theme.yaml
    description: Display theme configuration (fonts, colors)

reviewers:
  - ui-designer
  - software-lead
  - qa-engineer

reviewed: ''  # Pending approval
```

---

## Progress Tracking

### Current Status (from gap-report.csv):
- URD-000: ❌ Missing artifacts
- URD-001: ❌ Missing artifacts
- SRD-000: ❌ Missing artifacts
- SRD-001: ❌ Missing artifacts
- SWD-000: ❌ Missing artifacts
- SWD-001: ❌ Missing artifacts
- SWD-002: ❌ Missing artifacts
- LLTC-001: ❌ Missing artifacts

### Target (Week 2 End):
- URD-000: ✅ N/A (template)
- URD-001: ✅ Design doc linked
- SRD-000: ✅ N/A (template)
- SRD-001: ✅ Design + code linked
- SWD-000: ✅ Template updated
- SWD-001: ✅ Design + code + tests linked
- SWD-002: ✅ Design + code + tests linked
- LLTC-001: ✅ Test specs linked

---

## Checklist for Each Requirement

- [ ] Identify all relevant design documents
- [ ] Identify all implementing source files
- [ ] Identify all test cases
- [ ] Add `artifact:` section to YAML
- [ ] Verify all paths exist
- [ ] Add descriptions
- [ ] Run linter
- [ ] Check gap report
- [ ] Commit changes
- [ ] Update traceability matrix

---

## Next Steps

1. **Week 1, Day 1-2:** Create architecture documents
2. **Week 1, Day 3-4:** Link existing code to SWD requirements
3. **Week 1, Day 5:** Link test cases to LLTC requirements
4. **Week 2, Day 1-2:** Update templates with artifact sections
5. **Week 2, Day 3:** Create artifact verification script
6. **Week 2, Day 4-5:** Review and validate all links

**Goal:** Zero entries in `gap-report.csv` by end of Week 2!

---

## Questions?

- **Process questions:** See `docs/requirements/REVIEWER_CHECKLIST.md`
- **Technical issues:** Check `scripts/reqs_lint.py --help`
- **TSF questions:** Review `docs/tsf/TSF-training.md`
