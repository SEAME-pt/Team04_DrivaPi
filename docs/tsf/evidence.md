# TSF Evidence Collection Guide

**Purpose:** Explain how to collect, organize, and link evidence for requirements
**Audience:** All team members
**Principle:** Every claim needs verifiable evidence

---

## 🎯 Core Principle

> **"Trust is based on evidence, not assumptions"**

In TSF, every requirement must be backed by **verifiable artifacts** that prove:
1. The requirement was reviewed
2. The implementation exists
3. The implementation was tested
4. The tests passed

---

## 📊 Evidence Types

### 1. Requirements Evidence

**What:** Proof that requirements were properly managed

**Artifacts:**
- YAML files with complete mandatory fields
- `reviewed:` field with git commit SHA
- Git commit logs showing who approved when
- PR approval records

**How to Collect:**
```bash
# Requirement file
reqs/swd/SWD-042.yml

# Git history shows review
git log reqs/swd/SWD-042.yml

# PR shows approvals
https://github.com/.../pull/123
```

**Evidence Quality:**
- ✅ Good: `reviewed: 'abc123def456...'` (40-char git SHA)
- ✅ Good: PR with 2+ approvals for ASIL B
- ❌ Bad: `reviewed: 'approved'` (not verifiable)
- ❌ Bad: No git history

---

### 2. Design Evidence

**What:** Proof that design was documented and reviewed

**Artifacts:**
- Architecture diagrams (PlantUML, Draw.io, etc.)
- Interface specifications (API docs, IDL files)
- Design review meeting notes
- Trade-off analysis documents

**Location:** `docs/design/` or `artifacts/verification/design/`

**Example Structure:**
```
docs/design/
├── architecture/
│   ├── system-overview.puml
│   ├── component-diagram.png
│   └── data-flow.md
├── interfaces/
│   ├── can-bus-spec.md
│   ├── qt-api.md
│   └── sensor-protocol.md
└── reviews/
    ├── design-review-2025-10-15.md
    └── architecture-signoff.pdf
```

**Linking from Requirement:**
```yaml
SRD-015:
  artifact:
    - type: design
      path: docs/design/architecture/system-overview.puml
      description: System architecture showing HMI → CAN bus flow

    - type: design
      path: docs/design/reviews/design-review-2025-10-15.md
      description: Design review meeting notes with sign-off
```

---

### 3. Implementation Evidence

**What:** Proof that code exists and was reviewed

**Artifacts:**
- Source code files
- Code review approvals (PR)
- Static analysis reports
- Code coverage reports

**Location:** `src/` (code) + `artifacts/verification/` (reports)

**Example:**
```
src/
├── sensors/
│   ├── temperature_reader.cpp
│   ├── temperature_reader.h
│   └── CMakeLists.txt
└── hmi/
    ├── speed_widget.cpp
    └── speed_widget.h

artifacts/verification/
├── static-analysis/
│   ├── cppcheck-report.xml
│   └── clang-tidy-report.txt
└── coverage/
    └── lcov-report.html
```

**Linking from Requirement:**
```yaml
SWD-042:
  artifact:
    - type: code
      path: src/sensors/temperature_reader.cpp
      description: Temperature sensor reader implementation

    - type: code
      path: src/sensors/temperature_reader.h
      description: Public interface header

    - type: review
      path: https://github.com/.../pull/142
      description: Code review with 2 approvals

    - type: analysis
      path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml
      description: Static analysis clean (0 errors)
```

---

### 4. Test Evidence

**What:** Proof that requirements were tested and passed

**Artifacts:**
- Test code (unit/integration/system tests)
- Test results (JUnit XML, JSON, etc.)
- Test execution logs
- Coverage reports
- CI/CD pipeline logs

**Location:** `tests/` (code) + `artifacts/verification/tests/` (results)

**Example Structure:**
```
tests/
├── unit/
│   ├── test_temperature_reader.cpp
│   └── test_speed_widget.cpp
├── integration/
│   ├── test_can_bus_integration.cpp
│   └── test_sensor_hmi_flow.cpp
└── system/
    └── test_end_to_end.py

artifacts/verification/tests/
├── LLTC-042-junit.xml       # Unit test results
├── LLTC-043-integration.xml # Integration test results
└── LLTC-044-system.log      # System test log
```

**Test Result Formats:**

**JUnit XML (preferred):**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="TemperatureReaderTests" tests="5" failures="0" errors="0" time="0.234">
  <testcase name="test_read_valid_temperature" time="0.045"/>
  <testcase name="test_read_invalid_temperature" time="0.038"/>
  <testcase name="test_timeout_handling" time="0.067"/>
  <testcase name="test_accuracy_within_spec" time="0.042"/>
  <testcase name="test_performance_under_10ms" time="0.042"/>
</testsuite>
```

**JSON (alternative):**
```json
{
  "test_suite": "TemperatureReaderTests",
  "total": 5,
  "passed": 5,
  "failed": 0,
  "duration_ms": 234,
  "tests": [
    {
      "name": "test_read_valid_temperature",
      "status": "PASS",
      "duration_ms": 45
    }
  ]
}
```

**Linking from Test Case:**
```yaml
LLTC-042:
  artifact:
    - type: test
      path: tests/unit/test_temperature_reader.cpp
      description: Unit test implementation

    - type: test
      path: artifacts/verification/tests/LLTC-042-junit.xml
      description: Test execution results (5/5 passed)

    - type: test
      path: artifacts/verification/coverage/LLTC-042-coverage.html
      description: Code coverage 95% (38/40 lines)
```

---

### 5. Traceability Evidence

**What:** Proof that requirements are linked across V-Model

**Artifacts:**
- Traceability matrix (CSV)
- Traceability manifest (JSON)
- Doorstop graph (DOT)
- Trustable report (ZIP)

**Generated By:** CI/CD using official tools

**Location:** `artifacts/traceability/`

**Example:**
```bash
# Generate traceability
trudag manage migrate
trudag report export --output artifacts/traceability/report-$(date +%Y%m%d).zip

# Contents:
artifacts/traceability/
├── report-20251020.zip
│   ├── matrix.csv           # Traceability matrix
│   ├── manifest.json        # Metadata + links
│   └── report.md            # Human-readable summary
└── .dotstop.dot             # Doorstop graph
```

**Matrix Format (CSV):**
```csv
req_id,header,type,parent_links,child_links,asil,verification,reviewed
URD-001,Display speed,URD,[],[SRD-001],B,UAT,abc123
SRD-001,HMI speed,SRD,[URD-001],[SWD-001],B,System Test,def456
SWD-001,Qt widget,SWD,[SRD-001],[LLTC-001],B,Unit Test,ghi789
LLTC-001,Test widget,LLTC,[SWD-001],[],B,Unit Test,jkl012
```

---

### 6. Baseline Evidence

**What:** Proof of approved requirement sets at specific points in time

**Artifacts:**
- Git tags (immutable)
- Trustable reports (ZIP)
- Archived verification artifacts
- Release notes

**Location:** `artifacts/baselines/`

**Example:**
```
artifacts/baselines/
├── BASELINE-SPRINT-1-20251020.zip
│   ├── trustable-report.zip
│   ├── traceability-matrix.csv
│   └── manifest.json
└── BASELINE-V1.0-20251115.tar.gz
    ├── trustable-report.zip
    ├── verification-artifacts/
    │   ├── tests/
    │   ├── reviews/
    │   └── coverage/
    └── release-notes.md
```

**Creating Baseline:**
```bash
# 1. Tag in git
git tag -a BASELINE-SPRINT-1 -m "Sprint 1 baseline

Requirements: 88 total (15 URD, 28 SRD, 45 SWD)
Coverage: 100% traced, 95% reviewed
ASIL: A/B distribution
Tests: 45/45 passed
Date: 2025-10-20"

# 2. Export Trustable report
trudag report export --output artifacts/baselines/sprint-1-$(date +%Y%m%d).zip

# 3. Archive all verification artifacts
cd artifacts/
tar -czf baselines/BASELINE-SPRINT-1-complete.tar.gz \
  traceability/ \
  verification/ \
  baselines/sprint-1-*.zip

# 4. Push tag
git push origin BASELINE-SPRINT-1

# 5. Commit artifacts
git add baselines/
git commit -m "release: Create BASELINE-SPRINT-1"
git push
```

---

## 📂 Evidence Organization

### Recommended Structure

```
Team04_DrivaPi/
├── reqs/                      # Requirements (source of truth)
│   ├── urd/URD-*.yml
│   ├── srd/SRD-*.yml
│   ├── swd/SWD-*.yml
│   └── lltc/LLTC-*.yml
│
├── docs/                      # Design documentation
│   ├── design/
│   │   ├── architecture/
│   │   ├── interfaces/
│   │   └── reviews/
│   └── ...
│
├── src/                       # Implementation
│   ├── sensors/
│   ├── hmi/
│   └── ...
│
├── tests/                     # Test code
│   ├── unit/
│   ├── integration/
│   └── system/
│
└── artifacts/                 # Generated evidence
    ├── traceability/          # Auto-generated by CI
    │   ├── matrix.csv
    │   ├── manifest.json
    │   └── report-*.zip
    │
    ├── verification/          # Test results & reviews
    │   ├── tests/             # Test execution results
    │   │   ├── LLTC-*-junit.xml
    │   │   └── LLTC-*-integration.log
    │   ├── reviews/           # Review meeting notes
    │   │   ├── SRD-*-review.md
    │   │   └── SWD-*-signoff.pdf
    │   ├── coverage/          # Code coverage reports
    │   │   └── lcov-report/
    │   └── static-analysis/   # Linter/analyzer outputs
    │       ├── cppcheck-*.xml
    │       └── clang-tidy-*.txt
    │
    └── baselines/             # Baseline snapshots
        ├── BASELINE-*.zip
        └── BASELINE-*.tar.gz
```

---

## 🔗 Linking Evidence to Requirements

### YAML Artifact Field

```yaml
SWD-042:
  ref: SWD-042
  header: "Temperature sensor reader"
  text: "The software SHALL read temperature sensor..."
  # ... other fields ...

  artifact:
    # Design evidence
    - type: design
      path: docs/design/interfaces/temperature-sensor-api.md
      description: Temperature sensor interface specification

    # Implementation evidence
    - type: code
      path: src/sensors/temperature_reader.cpp
      description: Implementation

    - type: code
      path: src/sensors/temperature_reader.h
      description: Public interface

    # Review evidence
    - type: review
      path: https://github.com/SEAME-pt/Team04_DrivaPi/pull/142
      description: Code review with 2 approvals (John, Jane)

    # Test evidence
    - type: test
      path: tests/unit/test_temperature_reader.cpp
      description: Unit test suite

    - type: test
      path: artifacts/verification/tests/LLTC-042-junit.xml
      description: Test execution (8/8 passed, 234ms)

    # Coverage evidence
    - type: test
      path: artifacts/verification/coverage/temperature_reader-coverage.html
      description: Code coverage 95% (38/40 lines)
```

### Evidence Types

Use these standardized `type:` values:

| Type | Description | Example |
|------|-------------|---------|
| `design` | Design documents | Architecture diagrams, specs |
| `code` | Source code | .cpp, .h, .py files |
| `review` | Reviews | PR approvals, meeting notes |
| `test` | Test code or results | Test files, JUnit XML |
| `analysis` | Static analysis | Cppcheck, clang-tidy |
| `report` | Summary reports | Coverage, performance |

---

## 🤖 CI/CD Automation

### GitHub Actions Workflow

**File:** `.github/workflows/tsf-validation.yml`

```yaml
name: TSF Validation

on:
  pull_request:
  push:
    branches: [main, development]

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install TSF tools
        run: |
          pip install doorstop pyyaml
          git clone https://gitlab.com/CodethinkLabs/trustable/trustable.git /tmp/trustable
          cd /tmp/trustable && git checkout 2025.9.16 && pip install .

      - name: Validate requirements
        run: |
          trudag manage lint
          doorstop

      - name: Generate traceability
        run: |
          trudag manage migrate
          trudag report export --output artifacts/traceability/ci-report.zip

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: tsf-artifacts
          path: |
            artifacts/traceability/
            .dotstop.dot
          retention-days: 90
```

### What CI Generates

**On every PR/push:**
1. Validation logs (`trudag manage lint` output)
2. Traceability matrix (CSV)
3. Traceability manifest (JSON)
4. Trustable report (ZIP)

**Download from:**
- GitHub Actions → Workflow run → Artifacts tab
- Retention: 90 days (configurable)

---

## 📊 Evidence Checklist by ASIL

### ASIL QM (Quality Management)

**Minimum Evidence:**
- [ ] Requirement YAML with all mandatory fields
- [ ] Basic peer review (1 reviewer)
- [ ] Link to parent (if applicable)

**No mandatory test evidence**

### ASIL A (Low Risk)

**Required Evidence:**
- [ ] Requirement YAML reviewed and approved
- [ ] 1 peer reviewer
- [ ] Unit tests (if software requirement)
- [ ] Test results (JUnit XML or equivalent)
- [ ] Traceability to parent

**Example:**
```
SWD-042 (ASIL A):
  ✓ Reviewed by John Doe
  ✓ Unit test: tests/unit/test_temp_reader.cpp
  ✓ Test results: LLTC-042-junit.xml (5/5 passed)
  ✓ Linked to: SRD-015
```

### ASIL B (Low-Medium Risk)

**Required Evidence:**
- [ ] Requirement YAML reviewed and approved
- [ ] 2 reviewers (domain + technical)
- [ ] Unit tests
- [ ] Integration tests
- [ ] Test results for both
- [ ] Design review notes
- [ ] Static analysis report
- [ ] Traceability complete

**Example:**
```
SWD-042 (ASIL B):
  ✓ Reviewed by John Doe + Jane Smith
  ✓ Design review: docs/design/reviews/SWD-042-review.md
  ✓ Unit tests: tests/unit/test_temp_reader.cpp
  ✓ Integration tests: tests/integration/test_sensor_flow.cpp
  ✓ Test results: LLTC-042-junit.xml + LLTC-043-integration.xml
  ✓ Static analysis: cppcheck-SWD-042.xml (0 errors)
  ✓ Linked to: SRD-015
```

### ASIL C (Medium Risk)

**Required Evidence:**
- [ ] All ASIL B evidence
- [ ] Independent reviewer (non-author)
- [ ] System tests
- [ ] Code coverage report (>80%)
- [ ] Formal test report with sign-off
- [ ] Test procedures documented
- [ ] Environment configuration recorded

**Example:**
```
SWD-042 (ASIL C):
  ✓ All ASIL B evidence
  ✓ Independent review by: External-Reviewer@company.com
  ✓ System tests: tests/system/test_end_to_end.py
  ✓ Coverage: 92% (46/50 lines)
  ✓ Test report: artifacts/verification/reports/SWD-042-test-report.pdf
  ✓ Test procedure: docs/test-procedures/SWD-042-procedure.md
  ✓ Environment: Ubuntu 22.04, GCC 11.4, Python 3.11
```

### ASIL D (High Risk)

**Required Evidence:**
- [ ] All ASIL C evidence
- [ ] Formal sign-off by authority
- [ ] HIL (Hardware-in-Loop) test logs
- [ ] Full traceability audit report
- [ ] Change control records
- [ ] Test bench configuration
- [ ] Baseline tag with artifacts

**Note:** ASIL D requirements should be rare in DrivaPi project.

---

## 🔍 Evidence Review Process

### Weekly Review (Friday)

**Checklist:**
1. Run traceability report
2. Check for requirements without evidence
3. Verify test results are recent (<1 week)
4. Confirm all reviewed fields have valid SHAs
5. Document any gaps

**Command:**
```bash
# Generate fresh report
trudag report export --output artifacts/weekly-$(date +%Y%m%d).zip

# Review matrix
unzip -p artifacts/weekly-*.zip matrix.csv | \
  grep -E ',,$'  # Find rows with missing evidence
```

### Sprint Review

**Evidence Audit:**
1. Complete traceability coverage
2. All requirements reviewed
3. All tests passing
4. Coverage meets targets
5. Baseline created

**Output:** Sprint baseline archive

### Release Review

**Final Evidence Package:**
1. All requirements reviewed and baselined
2. Complete traceability matrix
3. All verification artifacts archived
4. Release notes
5. Git tag created
6. Artifacts stored long-term

---

## 📈 Metrics

### Coverage Metrics

```bash
# Requirements coverage
total_reqs=$(find reqs/ -name "*.yml" -not -path "*/templates/*" | wc -l)
reviewed_reqs=$(grep -l "reviewed: '[a-f0-9]" reqs/*/*.yml | wc -l)
coverage=$((reviewed_reqs * 100 / total_reqs))

echo "Requirements reviewed: $reviewed_reqs / $total_reqs ($coverage%)"
```

### Test Evidence Metrics

```bash
# Count test artifacts
total_lltc=$(find reqs/lltc/ -name "*.yml" | wc -l)
test_results=$(find artifacts/verification/tests/ -name "LLTC-*.xml" | wc -l)
test_coverage=$((test_results * 100 / total_lltc))

echo "Test evidence: $test_results / $total_lltc ($test_coverage%)"
```

---

## 🎯 Best Practices

### DO:
- ✅ Commit evidence artifacts to git
- ✅ Use standard formats (JUnit XML, JSON)
- ✅ Link evidence in YAML `artifact:` field
- ✅ Generate evidence automatically (CI/CD)
- ✅ Archive baselines with all evidence
- ✅ Use official tools only
- ✅ Keep evidence traceable to requirements

### DON'T:
- ❌ Store evidence only locally
- ❌ Use custom formats without documentation
- ❌ Forget to link evidence in YAML
- ❌ Manually create evidence (automate!)
- ❌ Delete old evidence (archive it)
- ❌ Use custom scripts (official tools only)
- ❌ Have "orphan" evidence (not linked to requirement)

---

## 🆘 Troubleshooting

### Problem: Missing evidence links

**Symptom:** Traceability report shows gaps

**Solution:**
```bash
# Find requirements without evidence
grep -L "artifact:" reqs/swd/*.yml

# Add artifact links
nano reqs/swd/SWD-042.yml
# Add artifact: section
```

### Problem: Test results not found

**Symptom:** CI passes but no test artifacts

**Solution:**
```yaml
# Add to CI workflow
- name: Run tests
  run: |
    pytest tests/unit/ --junitxml=artifacts/verification/tests/results.xml

- name: Upload test results
  uses: actions/upload-artifact@v4
  with:
    name: test-results
    path: artifacts/verification/tests/*.xml
```

### Problem: Old evidence

**Symptom:** Evidence older than requirement

**Solution:**
```bash
# Re-run tests
pytest tests/unit/test_temperature_reader.cpp --junitxml=artifacts/verification/tests/LLTC-042-junit.xml

# Update requirement with new evidence path
# Commit both test result and updated YAML
```

---

## 📚 Templates

### Test Result Template (JUnit XML)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="TestSuiteName" tests="5" failures="0" errors="0" time="0.234" timestamp="2025-10-20T10:30:00">
  <testcase classname="ClassName" name="test_case_1" time="0.045">
    <!-- Test passed -->
  </testcase>
  <testcase classname="ClassName" name="test_case_2" time="0.038">
    <failure message="Expected 42, got 41" type="AssertionError">
      Traceback...
    </failure>
  </testcase>
</testsuite>
```

### Review Notes Template

```markdown
# Design Review: SWD-042

**Date:** 2025-10-20
**Reviewers:** John Doe, Jane Smith
**Requirement:** SWD-042 - Temperature sensor reader

## Summary
Design reviewed and approved with minor recommendations.

## Review Items
- [x] Architecture appropriate for ASIL B
- [x] Interfaces well-defined
- [x] Error handling complete
- [x] Performance requirements met

## Recommendations
1. Add timeout parameter to API
2. Document calibration procedure

## Decision
**APPROVED** with recommendations to be addressed before implementation.

**Sign-off:**
- John Doe: Approved (john.doe@example.com)
- Jane Smith: Approved (jane.smith@example.com)
```

---

**Last Updated:** October 2025
**Maintained By:** DrivaPi Team
