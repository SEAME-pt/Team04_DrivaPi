# TSF Workflows - DrivaPi

**Purpose:** Step-by-step guides for common TSF tasks
**Tools Used:** `trudag` + `doorstop` only
**Evidence-Based:** Every workflow produces verifiable artifacts

---

## 📋 Available Workflows

1. [Create a New Requirement](#workflow-1-create-a-new-requirement)
2. [Link Requirements (Traceability)](#workflow-2-link-requirements)
3. [Review & Approve Requirements](#workflow-3-review--approve)
4. [Generate Traceability Matrix](#workflow-4-generate-traceability-matrix)
5. [Create a Baseline](#workflow-5-create-a-baseline)
6. [Fix Validation Errors](#workflow-6-fix-validation-errors)

---

## Workflow 1: Create a New Requirement

**Time:** 10-15 minutes
**Evidence Produced:** YAML file, validation logs, PR

### When to Use
- Starting a new feature
- Decomposing parent requirements
- Adding test cases

### Steps

#### Option A: Interactive (Recommended)

```bash
# Step 1: Create new requirement interactively
doorstop add SWD

# doorstop will:
# - Ask for header
# - Create new file with next available ID
# - Open in your editor

# Step 2: Edit the requirement
doorstop edit SWD-042

# Step 3: Fill in mandatory fields:
# - header: "Short title"
# - text: "The software SHALL..."
# - ASIL: A/B/C/D/QM
# - Verification Method: Unit Test / Integration Test / etc.
# - links: [SRD-015]  ← Parent requirement
# - reviewers:
#     - name: "Your Name"
#       email: "you@example.com"
# - reviewed: ''  ← Leave empty
```

#### Option B: Manual

```bash
# Step 1: Copy template
cp reqs/templates/SWD-template.yml reqs/swd/SWD-042.yml

# Step 2: Edit file
nano reqs/swd/SWD-042.yml

# Step 3: Update all fields:
# - Change SWD-000 to SWD-042 (2 places: top-level ID and ref:)
# - Update header, text, links, reviewers
```

#### Step 4: Validate

```bash
# Run official validation
trudag manage lint

# Expected output:
# ✓ All requirements validated

# If errors, fix them and re-run
```

#### Step 5: Commit & Push

```bash
# Stage file
git add reqs/swd/SWD-042.yml

# Commit with conventional commit message
git commit -m "feat(swd): Add SWD-042 temperature monitoring"

# Push to branch
git push origin feature/swd-042
```

#### Step 6: Create Pull Request

1. Go to GitHub
2. Create PR from your branch
3. Add template checklist (`.github/PULL_REQUEST_TEMPLATE.md`)
4. Request 2 reviewers (ASIL B+)

### Evidence Checklist

- [x] YAML file created in correct location
- [x] `trudag manage lint` passes
- [x] `doorstop` validation passes
- [x] Git commit created
- [x] PR created with reviewers assigned

---

## Workflow 2: Link Requirements

**Time:** 5 minutes
**Evidence Produced:** Updated YAML, validation logs

### When to Use
- Creating child requirement for existing parent
- Adding test cases for software requirements
- Completing V-Model traceability chain

### Steps

```bash
# Step 1: Link child to parent
doorstop link SWD-042 SRD-015

# This updates SWD-042.yml:
# links: [SRD-015]

# Step 2: Verify link is valid
trudag manage lint
doorstop

# Step 3: Check bidirectional traceability
doorstop publish all docs/temp-report/
# Open docs/temp-report/index.html to verify
```

### Manual Alternative

```yaml
# Edit SWD-042.yml directly:
SWD-042:
  # ... other fields ...
  links:
    - SRD-015      # Parent requirement
    - SRD-016      # Can have multiple parents
```

### Validation

```bash
# Ensure parent exists
ls reqs/srd/SRD-015.yml

# Validate links
trudag manage lint

# If error "parent not found", create parent first
```

### Evidence Checklist

- [x] `links:` field updated in child YAML
- [x] Parent requirement exists
- [x] `doorstop` shows no broken links
- [x] Traceability visible in published report

---

## Workflow 3: Review & Approve

**Time:** 15-20 minutes
**Evidence Produced:** Reviewed YAML with git SHA, commit log

### When to Use
- PR review completed
- All feedback addressed
- Ready to mark requirement as approved

### Prerequisites
- [ ] All PR comments resolved
- [ ] CI checks passing
- [ ] 2+ reviewers approved (ASIL B+)

### Steps (Reviewer)

```bash
# Step 1: Pull latest changes
git checkout feature/swd-042
git pull origin feature/swd-042

# Step 2: Validate locally
trudag manage lint
doorstop

# Step 3: Review content
# - Check "SHALL" statements are clear
# - Verify acceptance criteria exist
# - Check ASIL level appropriate
# - Verify links to parent(s)
# - Check units/timing specified

# Step 4: If approved, mark as reviewed
trudag manage set-item reqs/swd/SWD-042.yml

# This updates the 'reviewed:' field with current git SHA
```

### Alternative: Manual Approval

```yaml
# Edit SWD-042.yml:
SWD-042:
  # ... fields ...
  reviewed: 'abc123def456'  # Current git SHA

# Get current SHA:
git rev-parse HEAD
```

### Step 5: Commit Approval

```bash
# Stage changes
git add reqs/swd/SWD-042.yml

# Commit with review message
git commit -m "review: Approve SWD-042 - temperature monitoring

Reviewed by: John Doe, Jane Smith
Date: 2025-10-20
Validation: trudag + doorstop passed"

# Push
git push origin feature/swd-042
```

### Step 6: Merge PR

1. Final CI check passes
2. Merge PR to main
3. Delete feature branch

### Evidence Checklist

- [x] `reviewed:` field contains valid git SHA
- [x] Reviewer name in commit message
- [x] PR approval logs
- [x] CI passed on merge

---

## Workflow 4: Generate Traceability Matrix

**Time:** 5 minutes
**Evidence Produced:** CSV matrix, JSON manifest, ZIP report

### When to Use
- Weekly traceability review
- Sprint retrospective
- Before baseline creation
- Coverage gap analysis

### Steps

```bash
# Step 1: Update Doorstop structure
trudag manage migrate

# Step 2: Export traceability report
trudag report export --output artifacts/traceability/report-$(date +%Y%m%d).zip

# Step 3: Extract and review
cd artifacts/traceability/
unzip report-$(date +%Y%m%d).zip -d report-latest/
cd report-latest/

# Files generated:
# - matrix.csv         ← Main traceability matrix
# - manifest.json      ← Metadata and links
# - report.md          ← Human-readable summary
```

### Review Matrix

```bash
# Open CSV in Excel/LibreOffice
libreoffice matrix.csv

# Or view in terminal
column -s, -t < matrix.csv | less -S

# Check for:
# - Missing links (empty parent_links or child_links)
# - Unreviewed requirements (reviewed field empty)
# - Coverage gaps (requirements without tests)
```

### Alternative: Doorstop HTML Report

```bash
# Generate HTML report
doorstop publish all docs/doorstop-report/

# Open in browser
open docs/doorstop-report/index.html
```

### Evidence Checklist

- [x] Traceability report ZIP created
- [x] matrix.csv contains all requirements
- [x] No broken links reported
- [x] Coverage gaps identified and documented

---

## Workflow 5: Create a Baseline

**Time:** 10 minutes
**Evidence Produced:** Git tag, Trustable report, baseline archive

### When to Use
- End of sprint
- Major milestone
- Release preparation
- Before major changes

### Prerequisites
- [ ] All requirements reviewed
- [ ] No broken links
- [ ] Traceability matrix complete
- [ ] CI passing

### Steps

```bash
# Step 1: Verify everything is clean
trudag manage lint
doorstop

# Step 2: Generate final traceability report
trudag manage migrate
trudag report export --output artifacts/baselines/BASELINE-V1.0-$(date +%Y%m%d).zip

# Step 3: Create git tag
git tag -a BASELINE-V1.0 -m "Baseline Version 1.0

Requirements:
- 15 URD (User Requirements)
- 28 SRD (System Requirements)
- 45 SWD (Software Requirements)
- 45 LLTC (Test Cases)

Coverage: 100%
ASIL: A/B
Reviewed: All requirements approved
Date: 2025-10-20"

# Step 4: Push tag
git push origin BASELINE-V1.0

# Step 5: Archive artifacts
cd artifacts/baselines/
tar -czf BASELINE-V1.0-complete.tar.gz \
  BASELINE-V1.0-*.zip \
  ../traceability/matrix.csv \
  ../verification/

# Step 6: Commit archive
git add baselines/
git commit -m "release: Create BASELINE-V1.0

Includes:
- Trustable report
- Traceability matrix
- Verification artifacts"
git push
```

### GitHub Release (Optional)

1. Go to GitHub Releases
2. Create release from `BASELINE-V1.0` tag
3. Upload `BASELINE-V1.0-complete.tar.gz`
4. Add release notes
5. Publish release

### Evidence Checklist

- [x] Git tag created
- [x] Trustable report exported
- [x] Archive created with all artifacts
- [x] Tag pushed to GitHub
- [x] Release notes documented

---

## Workflow 6: Fix Validation Errors

**Time:** Variable (5-30 minutes)
**Evidence Produced:** Fixed YAML, validation logs

### Common Errors

#### Error: "ref field does not match filename"

**Example:**
```
reqs/swd/SWD-042.yml: ref field is 'SWD-041' but should be 'SWD-042'
```

**Fix:**
```yaml
# Change:
SWD-041:
  ref: SWD-041

# To:
SWD-042:
  ref: SWD-042
```

#### Error: "Missing required field: reviewers"

**Fix:**
```yaml
# Add reviewers block:
reviewers:
  - name: "Your Name"
    email: "you@example.com"
```

#### Error: "Parent link not found: SRD-999"

**Cause:** Linked parent doesn't exist

**Fix Option 1:** Create parent first
```bash
doorstop add SRD
doorstop edit SRD-999
```

**Fix Option 2:** Remove invalid link
```yaml
# Change:
links: [SRD-999]

# To (if no parent yet):
links: []
```

#### Error: "reviewed field must be empty or valid git SHA"

**Fix:**
```yaml
# Must be one of:
reviewed: ''                           # Not yet reviewed (correct)
reviewed: 'abc123def456789...'         # Valid git SHA (correct)
reviewed: 'approved'                   # Invalid! Don't use
```

### Validation Workflow

```bash
# Step 1: Run validation
trudag manage lint 2>&1 | tee validation-errors.log

# Step 2: Fix errors one by one
# Read validation-errors.log

# Step 3: Re-validate after each fix
trudag manage lint

# Step 4: When all pass, commit fixes
git add reqs/
git commit -m "fix: Resolve validation errors

- Fixed ref fields in SWD-042, SWD-043
- Added missing reviewers in URD-010
- Corrected broken link in SRD-025"
git push
```

### Evidence Checklist

- [x] `trudag manage lint` passes (no errors)
- [x] `doorstop` validates successfully
- [x] Fixes committed with descriptive message
- [x] CI passes after push

---

## 📊 Daily Workflow Summary

**Morning Routine (5 min):**
```bash
git pull origin main
source .venv/bin/activate
trudag manage lint
doorstop
```

**Creating Requirements (per requirement: ~15 min):**
1. Create: `doorstop add <TYPE>`
2. Edit: Fill mandatory fields
3. Validate: `trudag manage lint`
4. Commit & PR

**Reviewing (per requirement: ~15 min):**
1. Pull branch
2. Validate: `trudag manage lint`
3. Review content
4. Approve: `trudag manage set-item <file>`
5. Commit & merge

**Weekly Tasks (Friday: 30 min):**
1. Generate traceability: `trudag report export`
2. Review coverage gaps
3. Update documentation
4. Team sync

**Sprint End (2 hours):**
1. Full validation
2. Traceability audit
3. Create baseline
4. Archive artifacts
5. Retrospective

---

## 🆘 Quick Help

**Command not found?**
```bash
source .venv/bin/activate
```

**Validation fails?**
```bash
trudag manage lint 2>&1 | less
# Read errors carefully
```

**Need help?**
- Check `docs/tsf/reference.md`
- Ask in team standup
- Review `docs/tsf/training.md`

---

## 📚 Related Documentation

- **Setup:** `docs/tsf/start.md`
- **Reference:** `docs/tsf/reference.md`
- **Training:** `docs/tsf/training.md`
- **Evidence:** `docs/tsf/evidence.md`

---

**Last Updated:** October 2025
**Maintained By:** DrivaPi Team
