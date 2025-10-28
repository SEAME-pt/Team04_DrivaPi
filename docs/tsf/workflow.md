# TSF Workflows

**3 main workflows you'll always use**

> **Basic commands:** See [reference.md](reference.md)
> **Evidence & Scoring:** See [evidence.md](evidence.md)

---

## Workflow 1: Create New Requirement

**When:** New feature, decompose parent requirement, add test

### Steps

```bash
# 1. Create file
trudag manage create-item SWD 042 reqs/swd

# 2. Edit (copy template from reqs/templates/ if it helps)
nano reqs/swd/SWD-042.md

# 3. Validate syntax
trudag manage lint

# 4. Commit
git add reqs/swd/SWD-042.md .dotstop.dot
git commit -m "feat(swd): Add SWD-042 temperature monitoring"
git push origin feature/swd-042

# 5. Create PR, request 2 reviews (ASIL B)
```

**Tips:**
- Use **SHALL** for mandatory requirements
- Include units, timing, ranges (e.g., "±0.5°C in <10ms")
- One testable thing per requirement
- Check templates in `reqs/templates/`

---

## Workflow 2: Link, Add Evidence, Score, and Approve

**When:** Requirement created and ready for review

### Part A: Link (Traceability)

```bash
# Link child → parent (ALWAYS bottom-up in V-Model)
trudag manage create-link SWD-042 SRD-015

# Verify links
trudag manage lint
```

### Part B: Add Evidence & Configure Scoring

**Update the requirement file with evidence links:**

```bash
nano reqs/swd/SWD-042.md
```

**Add `references:` block (for passive artifact links):**
```yaml
---
id: SWD-042
# ... other fields ...

references:  # Links artifacts for human review & traceability
  - type: "file"
    path: src/sensors/temperature.cpp
  - type: "file"
    path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml
  - type: "file"
    path: tests/unit/test_temperature.cpp
---
```

**Add `score:` block (for manual SME assessment) or `evidence:` block (for automated validation):**

Option 1 - Manual SME Score:
```yaml
score:  # SME confidence in requirement based on evidence review
  CodeReviewer: 0.9   # 90% confident
  ArchSME: 0.85      # 85% confident
```

Option 2 - Automated Validator:
```yaml
evidence:  # Automated checking
  type: junit_pass_fail_checker
  references:
    - type: "file"
      path: artifacts/verification/tests/LLTC-042-junit.xml
  configuration:
    expected_tests: 5
```

Option 3 - Both (Recommended for ASIL B+):
```yaml
references:  # Human review links
  - type: "file"
    path: tests/unit/test_temperature.cpp
evidence:  # Automated check
  type: junit_pass_fail_checker
  references:
    - type: "file"
      path: artifacts/verification/tests/LLTC-042-junit.xml
  configuration:
    expected_tests: 5
score:  # Manual override/context
  QALead: 1.0
```

### Part C: Calculate Scores

```bash
# Calculate scores (runs evidence validators, aggregates SME scores)
trudag score

# Verify scores propagated
trudag publish --output-dir artifacts/trustable-report
cat artifacts/trustable-report/dashboard.md | grep SWD-042
```

### Part D: Review

**Checklist before approval:**
- [ ] Requirement statement clear and testable?
- [ ] Correct ASIL level?
- [ ] Links to correct parent?
- [ ] No ambiguities or grammatical issues?
- [ ] Has units, constraints, and timing?
- [ ] Evidence artifacts linked (`references:` block)?
- [ ] Score assigned (`score:` or `evidence:` block)?
- [ ] For ASIL B+: Multiple reviewers in `score:` block?

### Part E: Approve

```bash
# Mark as reviewed (updates git SHA in tool)
trudag manage set-item SWD-042

# Manually update 'reviewed:' field for audit trail
nano reqs/swd/SWD-042.md
# Edit reviewed: '' to reviewed: "YYYY-MM-DD - Approved by [Name] <email>"
# Example: reviewed: "2025-10-28 - Approved by Carol Dev <carol@example.com>"

# Commit
git add reqs/swd/SWD-042.md
git commit -m "review: Approve SWD-042 with evidence and scoring"
git push

# Merge PR on GitHub
```

**⚠️ ASIL B requires 2+ approvers with multiple `score:` entries!**

---

## Workflow 3: Generate Report & Baseline

**When:** Sprint review, release, audit

### Weekly Report

```bash
# Recalculate all scores (runs evidence validators)
trudag score

# Generate report
trudag publish --output-dir artifacts/trustable-report

# View summary dashboard
cat artifacts/trustable-report/dashboard.md
```

**What to check in dashboard:**
- How many requirements reviewed vs unreviewed requirements?
- How many requirements have evidence links and scores?
- Are there orphans (requirements without parent/child links)?
- What's the average trust score across levels?

### Baseline (end of sprint/release)

```bash
# 1. Ensure all critical requirements are reviewed
trudag score | grep -i "unreviewed"

# 2. Ensure all critical requirements have scores
trudag publish --output-dir artifacts/trustable-report

# 3. Create git tag for baseline
git tag -a BASELINE-V1.0 -m "Sprint 1 baseline - all core requirements approved and scored"

# 4. Archive report with timestamp
mkdir -p artifacts/baselines
cp -r artifacts/trustable-report artifacts/baselines/v1.0-$(date +%Y%m%d_%H%M%S)

# 5. Commit baseline archive
git add artifacts/baselines/
git commit -m "baseline: Create V1.0 baseline with scoring - $(date +%Y-%m-%d)"

# 6. Push with tags
git push origin master --tags
```

---

## Fix Common Errors

### "YAML syntax error"

```bash
# View frontmatter
head -40 reqs/swd/SWD-042.md

# Check:
# - Has --- at start (line 1) and end (line ~35)?
# - Correct indentation (2 spaces)?
# - Strings with special chars have "quotes"?
# - Lists use "- " (dash space)?
# - references:, score:, evidence: blocks are properly indented?
```

### "Missing required field: normative" or "level"

```bash
# Add to frontmatter:
---
normative: true
level: 3.0  # 1.0=URD, 2.0=SRD, 3.0=SWD, 4.0=LLTC
---
```

### "Broken link: parent X not found"

```bash
# Create parent first
trudag manage create-item SRD 015 reqs/srd

# Then link child → parent
trudag manage create-link SWD-042 SRD-015
```

### "Requirement not in .dotstop.dot"

```bash
# Recreate using trudag (updates .dotstop.dot automatically)
trudag manage create-item SWD 042 reqs/swd
```

### "Evidence file not found"

```bash
# Check references: block paths (relative to repo root)
nano reqs/swd/SWD-042.md

# Verify file exists
ls artifacts/verification/static-analysis/cppcheck-SWD-042.xml

# Fix path if needed, then re-run:
trudag manage lint
```

### "Requirement has score 0.0" (unexpected)

```bash
# Check if score: or evidence: block is present
cat reqs/swd/SWD-042.md | grep -A 5 "score:"

# If missing, add one:
nano reqs/swd/SWD-042.md

# Then recalculate
trudag score
```

### "evidence: validator fails"

```bash
# Check validator name exists
# Check validator is registered with trudag
# Verify configuration: parameters

# Example fix:
nano reqs/swd/SWD-042.md
# Update evidence: block with correct type and configuration

trudag score
```

---

## Complete Cycle: Real Example

**Feature:** Battery voltage monitoring (URD → SRD → SWD → LLTC)

### Step 1: Create Requirement Chain

```bash
trudag manage create-item URD 100 reqs/urd
trudag manage create-item SRD 100 reqs/srd
trudag manage create-item SWD 100 reqs/swd
trudag manage create-item LLTC 100 reqs/lltc
```

### Step 2: Edit Each Requirement

```bash
# URD-100: "User needs to see battery voltage on HMI"
nano reqs/urd/URD-100.md

# SRD-100: "System shall read ADC input and provide voltage value to HMI"
nano reqs/srd/SRD-100.md

# SWD-100: "Software module BatteryMonitor shall read GPIO ADC pin 3.3V range"
nano reqs/swd/SWD-100.md

# LLTC-100: "Unit tests verify BatteryMonitor reads correct values"
nano reqs/lltc/LLTC-100.md
```

### Step 3: Link (Bottom-Up V-Model)

```bash
trudag manage create-link SRD-100 URD-100
trudag manage create-link SWD-100 SRD-100
trudag manage create-link LLTC-100 SWD-100
```

### Step 4: Validate Structure

```bash
trudag manage lint
```

### Step 5: Commit & Create PR

```bash
git add reqs/ .dotstop.dot
git commit -m "feat: Add battery voltage monitoring requirement chain"
git push origin feature/battery-voltage
# Create PR on GitHub, request 2 reviews
```

### Step 6: Add Evidence & Scoring

```bash
# After code/tests written, add evidence links
nano reqs/swd/SWD-100.md
# Add references: block with src/battery_monitor.cpp, analysis reports

nano reqs/lltc/LLTC-100.md
# Add references: block with tests/unit/test_battery.cpp
# Add evidence: block with junit validator

git add reqs/
git commit -m "docs(swd): Add evidence links for SWD-100"
git push
```

### Step 7: Calculate Scores

```bash
trudag score
```

### Step 8: Approve After Review

```bash
# After PR approvals:
trudag manage set-item URD-100
trudag manage set-item SRD-100
trudag manage set-item SWD-100
trudag manage set-item LLTC-100

# Manually update 'reviewed:' fields
nano reqs/urd/URD-100.md
nano reqs/srd/SRD-100.md
nano reqs/swd/SWD-100.md
nano reqs/lltc/LLTC-100.md

# Example:
# reviewed: "2025-10-28 - Approved by Alice Dev <alice@example.com> & Bob Test <bob@example.com>"

git add reqs/
git commit -m "review: Approve battery voltage monitoring chain (URD/SRD/SWD/LLTC-100)"
git push

# Merge PR on GitHub
```

### Step 9: Generate Final Report

```bash
trudag score
trudag publish --output-dir artifacts/trustable-report

# Check dashboard
cat artifacts/trustable-report/dashboard.md
```

### Step 10: Create Baseline

```bash
git tag -a BASELINE-V1.0 -m "Battery voltage monitoring feature complete and scored"
mkdir -p artifacts/baselines
cp -r artifacts/trustable-report artifacts/baselines/v1.0-$(date +%Y%m%d)
git add artifacts/baselines/
git commit -m "baseline: Create V1.0 with battery monitoring scored"
git push origin master --tags
```

---

## Quick Decision Tree

```
New requirement?
├─ YES → Workflow 1: Create
└─ NO ─ Need to review?
        ├─ YES → Workflow 2: Link, Evidence, Score, Approve
        └─ NO ─ Need report?
                ├─ YES → Workflow 3: Report & Baseline
                └─ NO → Continue development
```

---

**More info:**
- Commands → [reference.md](reference.md)
- Quick Reference → [quick-reference.md](quick-reference.md)
- Theory → [training.md](training.md)
- Evidence & Scoring → [evidence.md](evidence.md)
