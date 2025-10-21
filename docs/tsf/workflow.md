# TSF Workflows - DrivaPi

**Purpose:** Step-by-step guides for common TSF tasks
**Tool Used:** `trudag` (official TSF tool)
**Evidence-Based:** Every workflow produces verifiable artifacts

---

## 📋 Available Workflows

1. [Create a New Requirement](#workflow-1-create-a-new-requirement)
2. [Link Requirements (Traceability)](#workflow-2-link-requirements)
3. [Review & Approve Requirements](#workflow-3-review--approve)
4. [Generate Traceability Report](#workflow-4-generate-traceability-report)
5. [Create a Baseline](#workflow-5-create-a-baseline)
6. [Fix Validation Errors](#workflow-6-fix-validation-errors)

---

## Workflow 1: Create a New Requirement

**Time:** 10-15 minutes
**Evidence Produced:** Markdown file, updated `.dotstop.dot`, validation logs

### When to Use
- Starting a new feature
- Decomposing parent requirements
- Adding test cases

### Steps

#### Step 1: Create Requirement with trudag

```bash
# Activate environment
source .venv/bin/activate

# Create new requirement
# Format: trudag manage create-item <TYPE> <NUMBER> <DIRECTORY>
trudag manage create-item SWD 042 reqs/swd

# This creates:
# - reqs/swd/SWD-042.md (markdown file)
# - Updates .dotstop.dot (graph structure)
```

#### Step 2: Edit the Requirement File

```bash
# Open in your editor
nano reqs/swd/SWD-042.md
# or
code reqs/swd/SWD-042.md
```

**Required structure:**

```markdown
---
normative: true
level: 3.0
ASIL: B
verification_method: "Unit Test"
reviewers:
  - name: "Your Name"
    email: "you@example.com"
reviewed: ''  # Leave empty until approved
active: true
derived: false
---
The software SHALL convert raw CAN speed data (0.1 km/h units) to
integer km/h and update the display module within 50ms of receipt.
```

**💡 Tips:**
- Use templates from `reqs/templates/` as reference
- Be specific and testable ("SHALL do X within Y ms")
- Include units, timing constraints, ranges
- One requirement = one testable thing

#### Step 3: Validate

```bash
# Check syntax and structure
trudag manage lint

# Expected output:
✓ All requirements validated
✓ No syntax errors

# If errors appear, read carefully and fix
```

#### Step 4: Commit & Push

```bash
# Stage files
git add reqs/swd/SWD-042.md .dotstop.dot

# Commit with conventional commit message
git commit -m "feat(swd): Add SWD-042 temperature monitoring"

# Push to branch
git push origin feature/swd-042
```

#### Step 5: Create Pull Request

1. Go to GitHub
2. Create PR from your branch
3. Add description
4. Request 2 reviewers (ASIL B requirement)

### Evidence Checklist

- [x] Markdown file created in `reqs/<type>/`
- [x] `.dotstop.dot` updated
- [x] `trudag manage lint` passes
- [x] Git commit created
- [x] PR created with reviewers

---

## Workflow 2: Link Requirements

**Time:** 5 minutes
**Evidence Produced:** Updated `.dotstop.dot`, validation logs

### When to Use
- Connecting child requirement to parent
- Completing V-Model traceability chain
- Adding test cases for software requirements

### Understanding Links

**Rule:** Child links TO parent (upward in V-Model)

```
URD-001 (User need)
   ↑ links to
SRD-001 (System req)
   ↑ links to
SWD-042 (Software design)
   ↑ links to
LLTC-042 (Test case)
```

### Steps

```bash
# Create link: child → parent
# Format: trudag manage create-link <CHILD-ID> <PARENT-ID>

trudag manage create-link SWD-042 SRD-015

# This updates .dotstop.dot automatically
```

**What happens:**
- `.dotstop.dot` updated with new edge
- Traceability chain established
- No manual YAML editing needed!

### Validate Links

```bash
# Check all links are valid
trudag manage lint

# Expected:
✓ No broken links
✓ All parents exist
```

### Multiple Parents

```bash
# A requirement can link to multiple parents
trudag manage create-link SWD-042 SRD-015
trudag manage create-link SWD-042 SRD-016

# Both links are tracked in .dotstop.dot
```

### Verify Traceability

```bash
# Generate report to visualize links
trudag publish --output-dir artifacts/trustable-report

# Open artifacts/trustable-report/dashboard.md
# Check that your requirement appears with correct links
```

### Evidence Checklist

- [x] `.dotstop.dot` updated with new edge
- [x] `trudag manage lint` shows no broken links
- [x] Parent requirement exists
- [x] Traceability visible in published report

---

## Workflow 3: Review & Approve

**Time:** 15-20 minutes
**Evidence Produced:** Reviewed requirement with git SHA

### When to Use
- PR review completed
- All feedback addressed
- Ready to mark requirement as trustworthy

### Prerequisites
- [ ] All PR comments resolved
- [ ] CI checks passing
- [ ] 2+ reviewers approved (ASIL B+)

### Steps (Reviewer)

#### Step 1: Pull Latest Changes

```bash
git checkout feature/swd-042
git pull origin feature/swd-042
```

#### Step 2: Validate Locally

```bash
# Activate environment
source .venv/bin/activate

# Run validation
trudag manage lint

# Should pass with no errors
```

#### Step 3: Review Content

**Check:**
- ✅ Requirement is clear and testable
- ✅ ASIL level appropriate
- ✅ Links to correct parent(s)
- ✅ No ambiguous language
- ✅ Includes units/constraints where needed

#### Step 4: Mark as Reviewed

```bash
# Mark requirement as reviewed
# This updates the 'reviewed:' field with git commit SHA
trudag manage set-item SWD-042

# Check the file was updated
cat reqs/swd/SWD-042.md | grep reviewed
# Should show: reviewed: '2025-10-21 — Reviewed and approved...'
```

#### Step 5: Commit Approval

```bash
# Stage changes
git add reqs/swd/SWD-042.md

# Commit with review message
git commit -m "review: Approve SWD-042 temperature monitoring"

# Push
git push origin feature/swd-042
```

#### Step 6: Merge PR

1. Approve PR on GitHub
2. Merge to main branch
3. Delete feature branch

### Evidence Trail

**What's recorded:**
1. `reviewed:` field contains approval date + reviewer
2. Git commit shows who approved and when
3. PR shows approval discussion
4. Git SHA provides immutable audit trail

### Evidence Checklist

- [x] `reviewed:` field populated
- [x] Git commit with approval message
- [x] PR merged to main
- [x] Reviewer identity recorded

---

## Workflow 4: Generate Traceability Report

**Time:** 5 minutes
**Evidence Produced:** HTML/Markdown report, scores

### When to Use
- Sprint review
- Audit preparation
- Progress tracking
- Identifying coverage gaps

### Steps

#### Step 1: Calculate Scores

```bash
# Calculate trust scores for all requirements
trudag score

# Output shows:
# - Total statements
# - Reviewed vs unreviewed
# - Evidence attached
# - Overall trustability score
```

#### Step 2: Generate Report

```bash
# Create full Trustable report
trudag publish --output-dir artifacts/trustable-report

# Optional: Run with validators (if configured)
trudag publish --validate --output-dir artifacts/trustable-report
```

#### Step 3: Review Outputs

```bash
# Check generated files
ls artifacts/trustable-report/

# Key files:
# - dashboard.md              (summary metrics)
# - trustable_report_for_Software.md  (compliance report)
# - URD.md, SRD.md, SWD.md, LLTC.md  (requirements by type)
# - figs/                     (charts and graphs)
```

#### Step 4: Open Dashboard

```bash
# View in browser or markdown viewer
open artifacts/trustable-report/dashboard.md

# Key metrics:
# - Evidence score distribution
# - Expectation scores
# - Total statements reviewed
# - Orphaned statements (warnings)
```

### Understanding the Report

**dashboard.md contains:**
- Number of statements by type
- Reviewed vs unreviewed counts
- Score distributions (histograms)
- Orphaned items

**trustable_report_for_Software.md contains:**
- Compliance table by requirement level
- Individual requirement scores
- Review status
- Baseline information (commit SHA, date)

### Artifacts to Keep

```bash
# Save report for audit
cp -r artifacts/trustable-report artifacts/trustable-report-$(date +%Y%m%d)

# Commit to git
git add artifacts/trustable-report/
git commit -m "docs: Add trustable report for Sprint 1"
```

### Evidence Checklist

- [x] `trudag score` runs successfully
- [x] Report generated in `artifacts/trustable-report/`
- [x] Dashboard shows expected metrics
- [x] All requirements appear in report
- [x] Report saved for audit trail

---

## Workflow 5: Create a Baseline

**Time:** 10 minutes
**Evidence Produced:** Git tag, archived report

### When to Use
- End of sprint
- Before release
- Major milestone
- Audit requirement

### What is a Baseline?

**A baseline is:**
- A snapshot of requirements at a specific point in time
- Immutable (git tag)
- Includes all artifacts (code, tests, docs, reports)
- Verifiable (git SHA)

### Steps

#### Step 1: Ensure Everything is Reviewed

```bash
# Check for unreviewed items
trudag score | grep unreviewed

# If any found, review them first (Workflow 3)
```

#### Step 2: Generate Final Report

```bash
# Create clean report
trudag publish --output-dir artifacts/trustable-report

# Verify report looks correct
ls artifacts/trustable-report/
```

#### Step 3: Create Git Tag

```bash
# Tag format: BASELINE-<VERSION>
git tag -a BASELINE-V1.0 -m "Sprint 1 baseline - Speed display feature"

# Verify tag
git tag -l "BASELINE-*"
```

#### Step 4: Archive Report

```bash
# Create timestamped archive
mkdir -p artifacts/baselines
cp -r artifacts/trustable-report artifacts/baselines/v1.0-$(date +%Y%m%d)

# Create tarball
tar -czf artifacts/baselines/BASELINE-V1.0.tar.gz artifacts/trustable-report/

# Add to git
git add artifacts/baselines/BASELINE-V1.0.tar.gz
git commit -m "baseline: Create V1.0 baseline archive"
```

#### Step 5: Push Tag

```bash
# Push commits
git push origin main

# Push tag
git push origin BASELINE-V1.0
```

### Baseline Verification

**Anyone can verify the baseline:**

```bash
# Checkout specific baseline
git checkout BASELINE-V1.0

# Regenerate report
trudag publish --output-dir /tmp/verify-report

# Compare with archived report
diff -r /tmp/verify-report artifacts/baselines/v1.0-*/

# Should be identical (or minor timestamp differences)
```

### Evidence Checklist

- [x] All requirements reviewed
- [x] `trudag score` shows high trustability
- [x] Git tag created
- [x] Report archived in `artifacts/baselines/`
- [x] Tag pushed to remote
- [x] Baseline is reproducible

---

## Workflow 6: Fix Validation Errors

**Time:** 5-30 minutes (depends on error)
**Evidence Produced:** Fixed requirements, clean lint output

### Common Errors & Solutions

#### Error: "Markdown frontmatter syntax error"

**Example:**
```
Error parsing URD-001.md: YAML syntax error
```

**Solution:**
```bash
# Check YAML syntax
cat reqs/urd/URD-001.md | head -20

# Common issues:
# - Missing closing '---'
# - Unquoted strings with special chars
# - Incorrect indentation

# Fix example:
---
normative: true
level: 1.0
reviewers:
  - name: "Alice"  # Must quote if contains special chars
    email: "alice@example.com"
---
```

#### Error: "Missing required field: normative"

**Solution:**
```bash
# Add missing field to frontmatter
nano reqs/swd/SWD-042.md

# Ensure these fields exist:
---
normative: true    # Required
level: 3.0         # Required
---
```

#### Error: "Requirement not found in .dotstop.dot"

**Solution:**
```bash
# Re-create the requirement using trudag
trudag manage create-item SWD 042 reqs/swd

# This will update .dotstop.dot correctly
```

#### Error: "Broken link: parent X not found"

**Solution:**
```bash
# Check parent exists
ls reqs/srd/SRD-015.md

# If parent missing, create it first
trudag manage create-item SRD 015 reqs/srd

# Then re-link
trudag manage create-link SWD-042 SRD-015
```

#### Error: "Unreviewed items"

**This is a warning, not an error.**

**Solution:**
```bash
# Review items (Workflow 3)
trudag manage set-item SWD-042

# Or mark multiple at once
for id in URD-001 SRD-001 SWD-001 LLTC-001; do
  trudag manage set-item $id
done
```

### General Debug Process

```bash
# 1. Read error message carefully
trudag manage lint

# 2. Check file syntax
cat reqs/<type>/<ID>.md

# 3. Validate frontmatter YAML
python3 -c "import yaml; print(yaml.safe_load(open('reqs/swd/SWD-042.md').read().split('---')[1]))"

# 4. Check .dotstop.dot
cat .dotstop.dot | grep SWD-042

# 5. Re-run validation
trudag manage lint
```

### Evidence Checklist

- [x] Error message read and understood
- [x] Root cause identified
- [x] Fix applied
- [x] `trudag manage lint` passes
- [x] Changes committed

---

## 🎯 Quick Command Reference

```bash
# Create requirement
trudag manage create-item <TYPE> <NUM> reqs/<type>

# Link child → parent
trudag manage create-link <CHILD-ID> <PARENT-ID>

# Mark as reviewed
trudag manage set-item <ID>

# Validate
trudag manage lint

# Calculate scores
trudag score

# Generate report
trudag publish --output-dir artifacts/trustable-report

# Create baseline
git tag -a BASELINE-V1.0 -m "Description"
```

---

**Need help?** Check `docs/tsf/reference.md` for detailed command syntax.
