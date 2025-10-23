# TSF Workflows

**3 main workflows you'll always use**

> **Basic commands:** See [reference.md](reference.md)

---

## Workflow 1: Create New Requirement

**When:** New feature, decompose parent requirement, add test

### Steps

```bash
# 1. Create file
trudag manage create-item SWD 042 reqs/swd

# 2. Edit (copy template from reqs/templates/ if it helps)
nano reqs/swd/SWD-042.md

# 3. Validate
trudag manage lint

# 4. Commit
git add reqs/swd/SWD-042.md .dotstop.dot
git commit -m "feat(swd): Add SWD-042 temperature monitoring"
git push origin feature/swd-042

# 5. Create PR, request 2 reviews (ASIL B)
```

**Tips:**
- Use SHALL for mandatory
- Include units, timing, ranges
- One testable thing per requirement
- Check templates in `reqs/templates/`

---

## Workflow 2: Link, Review and Approve

**When:** Requirement created and reviewed

### Part A: Link (Traceability)

```bash
# Link child → parent (ALWAYS bottom-up in V-Model)
trudag manage create-link SWD-042 SRD-015

# Verify
trudag manage lint
```

### Part B: Review

**Checklist before approval:**
- [ ] Requirement clear and testable?
- [ ] Correct ASIL?
- [ ] Links to correct parent?
- [ ] No ambiguities?
- [ ] Has units/constraints?

### Part C: Approve

```bash
# Mark as reviewed (updates status in tool)
trudag manage set-item SWD-042

# Update manually 'reviewed:' field in markdown for audit trail
nano reqs/swd/SWD-042.md

# Commit
git add reqs/swd/SWD-042.md
git commit -m "review: Approve SWD-042"
git push

# Merge PR on GitHub
```

**ASIL B requires 2+ approvers!**

---

## Workflow 3: Generate Report & Baseline

**When:** Sprint review, release, audit

### Weekly Report

```bash
# Calculate scores
trudag score

# Generate report
trudag publish --output-dir artifacts/trustable-report

# View dashboard
cat artifacts/trustable-report/dashboard.md
```

**What to check:**
- How many reviewed vs unreviewed?
- How many have evidence?
- Are there orphans (requirements without links)?

### Baseline (end of sprint/release)

```bash
# 1. Ensure everything reviewed
trudag score | grep unreviewed

# 2. Generate final report
trudag publish --output-dir artifacts/trustable-report

# 3. Git tag
git tag -a BASELINE-V1.0 -m "Sprint 1 baseline"

# 4. Archive report
mkdir -p artifacts/baselines
cp -r artifacts/trustable-report artifacts/baselines/v1.0-$(date +%Y%m%d)

# 5. Commit and push
git add artifacts/baselines/
git commit -m "baseline: Create V1.0 baseline"
git push origin main --tags
```

---

## Fix Common Errors

### "YAML syntax error"

```bash
# View first 20 lines
head -20 reqs/swd/SWD-042.md

# Check:
# - Has --- at start and end?
# - Correct indentation (2 spaces)?
# - Strings with "quotes" if they have special chars?
```

### "Missing required field: normative"

```bash
# Add to frontmatter:
---
normative: true
level: 3.0
---
```

### "Broken link: parent X not found"

```bash
# Create parent first
trudag manage create-item SRD 015 reqs/srd

# Then link
trudag manage create-link SWD-042 SRD-015
```

### "Requirement not in .dotstop.dot"

```bash
# Re-create using trudag (updates .dotstop.dot)
trudag manage create-item SWD 042 reqs/swd
```

---

## Complete Cycle: Real Example

**Feature:** Battery voltage monitoring

```bash
# === CREATE CHAIN ===
trudag manage create-item URD 100 reqs/urd
trudag manage create-item SRD 100 reqs/srd
trudag manage create-item SWD 100 reqs/swd
trudag manage create-item LLTC 100 reqs/lltc

# === EDIT (nano/code) ===
# URD-100: User needs to see voltage
# SRD-100: System reads ADC and provides to HMI
# SWD-100: Software BatteryMonitor class
# LLTC-100: Unit tests

# === LINK (bottom-up) ===
trudag manage create-link SRD-100 URD-100
trudag manage create-link SWD-100 SRD-100
trudag manage create-link LLTC-100 SWD-100

# === VALIDATE ===
trudag manage lint

# === COMMIT ===
git add reqs/ .dotstop.dot
git commit -m "feat: Add battery voltage monitoring chain"
git push origin feature/battery-voltage

# === CREATE PR, GET REVIEWS ===

# === APPROVE (after reviews) ===
trudag manage set-item URD-100
trudag manage set-item SRD-100
trudag manage set-item SWD-100
trudag manage set-item LLTC-100

# === UPDATE 'reviewed:' FIELDS MANUALLY ===
nano reqs/urd/URD-100.md
nano reqs/srd/SRD-100.md
nano reqs/swd/SWD-100.md
nano reqs/lltc/LLTC-100.md

git add reqs/
git commit -m "review: Approve battery voltage requirements"

# === MERGE PR ===

# === GENERATE REPORT ===
trudag publish --output-dir artifacts/trustable-report
```

---

**More info:**
- Commands → [reference.md](reference.md)
- Theory → [training.md](training.md)
- Evidence → [evidence.md](evidence.md)
