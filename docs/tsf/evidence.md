# TSF Evidence Guide

**Goal:** How to link artifacts (evidence), configure automated validation, and understand scoring using the `trudag` tool.
**Principle:** Each claim (Statement) needs verifiable proof. Confidence (Score) is derived from evidence assessment.

> **Commands:** See [reference.md](reference.md)
> **Workflow:** See [workflow.md](workflow.md)

---

## 📝 Spike Summary: Clarifying Linking Syntax (references: vs. evidence:)

**Date:** October 28, 2025

Based on analysis (GitHub Issue #59) and `trudag` CLI documentation, the team clarifies syntax usage:

1. **`references:` Block:** Standard method for linking passive artifacts (files, URLs). Provides context for human review and traceability links in reports. **Does not automatically contribute to scores.**
2. **`evidence:` Block:** Exclusively for configuring custom automated validators. Requires writing validator code to automatically calculate a score based on artifact content. Not for passive linking.
3. **`score:` Block:** Used for recording manual Subject Matter Expert (SME) scores based on their review of the Statement and linked references.
4. **Deprecated `artifact:` Block:** Not standard for `trudag` and should not be used.

**Implementation:** This document details usage for `references:`, `evidence:`, and `score:`.

---

## 💯 How Scores are Determined

The **"Trustable Score"** (0.0 to 1.0) for each requirement reflects the team's confidence in its truth, based on evidence. Scores originate at the lowest levels (Evidence/Premises, like LLTCs) and are propagated upwards by `trudag score` / `trudag publish`.

There are **two primary ways** a requirement gets its initial score:

### 1. Manual SME Assessment (score: block)

**Process:** One or more Subject Matter Experts (SMEs) review the requirement Statement and the artifacts linked in its `references:` block. Based on their judgment, they add their score to the `score:` block in the `.md` file's frontmatter.

**Syntax:**
```yaml
---
id: LLTC-042
# ... header, text, ASIL, reviewed ...
references: # Artifacts the SME reviews
  - type: "file"
    path: tests/unit/test_temperature.cpp
  - type: "file"
    path: artifacts/verification/tests/LLTC-042-junit.xml
score: # Manual SME scores
    ReviewerA: 0.9 # Reviewer A is 90% confident
    ReviewerB: 0.8 # Reviewer B is 80% confident
---
```

**Interpretation (Probability):** The score represents the SME's confidence probability:
- **1.0:** Certain the Statement is true based on evidence.
- **0.0:** Certain the Statement is false based on evidence.
- **0.5:** Completely uncertain or no useful information in evidence.

**Subjectivity & Calibration:** This method is subjective. For consistency, teams should:
- Define a scoring rubric (see "SME Scoring Guidance" below).
- Ensure SMEs assess only within their expertise.
- Ideally, SMEs should undergo calibration exercises to improve accuracy and counter overconfidence.
- Use multiple reviewers where possible. `trudag` aggregates multiple SME scores (e.g., by averaging).
- **Default:** Unscored items (no `score:` block and no `evidence:` block) default to a score of **0.0**.

### 2. Automated Validation (evidence: block)

**Process:** Configure the requirement to be scored automatically by a custom validator script/function you provide. `trudag score` executes this validator.

**Syntax:**
```yaml
---
id: LLTC-042
# ... header, text, ASIL, reviewed ...
evidence: # Configure automated check
  type: junit_pass_fail_checker # Your custom validator's name
  references: # File validator needs to read
    - type: "file"
      path: artifacts/verification/tests/LLTC-042-junit.xml
  configuration: # Args for validator
    expected_tests: 5
# score: block can coexist for manual override or context
---
```

**Objectivity:** This provides objective scoring based on predefined rules coded into the validator (e.g., "return 1.0 if tests pass, else 0.0").

**Requirement:** Requires development effort to create and register the custom validators with `trudag`.

### 3. Score Propagation (How trudag score calculates higher levels)

- Scores originate from the bottom nodes (Evidence/Premises like LLTCs) using either manual `score:` blocks or automated `evidence:` blocks.
- `trudag score` then calculates the score for parent nodes (SWDs, SRDs, URDs) recursively.
- **Current Tool Logic:** The score of a parent is the **mean (average)** of the scores of its immediate children (supporting Statements).
  - **Example:** If SRD-001 is supported by SWD-001 (score 0.8) and SWD-002 (score 0.6), the score for SRD-001 would be (0.8 + 0.6) / 2 = **0.7**.
- **Note:** The theoretical "Mathematical Roadmap" describes a more complex calculation involving "completeness" and "correctness", but the current tool uses the simpler mean calculation.

---

## 📋 SME Scoring Guidance (for score: block)

Since manual scoring is subjective, establishing team guidelines is crucial. Consider these factors when assigning a score (0.0 - 1.0):

### Evidence Completeness
- Does the linked evidence (`references:`) fully cover all aspects claimed in the Statement text?
- Are all acceptance criteria addressed by tests?
- **Score Guide:** 1.0 = Fully covered; 0.7-0.9 = Minor gaps; 0.5-0.6 = Significant gaps; <0.5 = Mostly missing.

### Evidence Correctness & Quality
- Do the results (e.g., test reports) show success?
- Does the linked code/design appear logically correct and implement the requirement?
- Is the evidence clear, well-formatted, and understandable?
- **Score Guide:** 1.0 = Correct & High Quality; 0.7-0.9 = Minor issues/doubts; 0.5-0.6 = Major concerns; <0.5 = Incorrect/Poor Quality.

### Evidence Sufficiency (ASIL Dependent)
- Is enough evidence provided for the requirement's ASIL level? (Refer to ASIL Checklists below).
- **Score Guide:** 1.0 = All required evidence types present and linked; Lower scores for missing evidence types (e.g., missing static analysis for ASIL B might cap score at 0.7).

### Traceability Links
- Does the requirement correctly link to appropriate parents/children (verified via `trudag manage lint` and report)? (While `trudag` handles propagation, severe link errors might reduce confidence).

### Personal Confidence & Calibration
- Reflect honestly on your certainty based only on the provided evidence. Avoid assuming external knowledge.
- Are you within your area of expertise? If not, a score closer to 0.5 might be appropriate.
- Consider your calibration: do you tend to be overconfident? Adjust accordingly.

**Team Action:** Define a specific scoring rubric based on these or similar criteria for consistency.

---

## 📊 Evidence Types & Artifacts

These are common types of evidence relevant to DrivaPi and the artifacts that represent them.

### 1. Code (Implementation)

**What:** Source code implementing the requirement.
**Artifacts:** `.cpp`, `.h`, `.rs` files in `src/`.
**Linked In:** SWD requirements.

**Example (using references:):**
```yaml
---
id: SWD-042
# ... other fields ...
references:
  - type: "file"
    path: src/sensors/temperature.cpp
score: # Example manual score based on code review
  CodeSME: 0.9
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

**What:** Test code and execution results.
**Artifacts:** Test code files (`tests/`), result files (`artifacts/verification/tests/`, e.g., `.xml`).
**Linked In:** LLTC requirements.

**Example (using references: and evidence:):**
```yaml
---
id: LLTC-042
# ... other fields ...
evidence: # Automatically score 1.0 if tests pass, 0.0 otherwise
  type: junit_pass_fail_checker
  references:
    - type: "file"
      path: artifacts/verification/tests/LLTC-042-junit.xml
  configuration:
    expected_tests: 5
references: # Passive link to test code for humans
  - type: "file"
    path: tests/unit/test_temperature.cpp
# score: block could still be added for SME override/comment
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

**What:** Diagrams, interface specs, design documents.
**Artifacts:** Documentation files (`docs/design/`, `.puml`, `.png`, `.md`).
**Linked In:** SRD or SWD requirements.

**Example (using references:):**
```yaml
---
id: SRD-015
# ... other fields ...
references:
  - type: "file"
    path: docs/design/architecture/system_overview.puml
  - type: "file"
    path: docs/design/interfaces/can-bus-spec.md
score: # Example manual score based on design review
  ArchSME: 0.8
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

**What:** Evidence of human review (PRs, commit hashes). Complements the manual `reviewed:` field.
**Artifacts:** URLs to PRs, specific Git commit SHAs.
**Linked In:** Any requirement type (URD, SRD, SWD, LLTC).

**Example (using references:):**
```yaml
---
id: SWD-042
reviewers:
  - name: "Carol Dev"
    email: "carol@example.com"
reviewed: "YYYY-MM-DD - Approved by Carol Dev <carol@example.com>"
# ... other fields ...
references:
  - type: "url" # Placeholder type
    path: https://github.com/SEAME-pt/Team04_DrivaPi/pull/142
# Score might be derived from children or have its own manual score
score:
  LeadDev: 1.0 # Confidence based on PR approval and child scores
---
```

**Note:** The `trudag` documentation explicitly mentions `file` and `gitlab` types. Using `path:` with the full URL is the practical approach. The manual `reviewed:` field remains the primary human audit trail within the file.

**Automatic evidence:**
- `reviewed:` field (with git SHA)
- Git commit log
- PR approvals on GitHub

---

### 5. Analysis (Automatic Checks)

**What:** Static analysis, coverage reports generated by CI.
**Artifacts:** Report files (`artifacts/verification/static-analysis/`, `artifacts/verification/coverage/`, e.g., `.xml`, `.txt`, `.info`).
**Linked In:** SWD requirements related to the analyzed code.

**Example (using references: and evidence:):**
```yaml
---
id: SWD-042
# ... other fields ...
references: # Passive links to reports
  - type: "file"
    path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml
  - type: "file"
    path: artifacts/verification/coverage/temperature_summary.txt
evidence: # Automatically score based on static analysis
  type: cppcheck_error_validator
  references:
    - type: "file"
      path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml
  configuration:
    fail_on_severity: ["error"]
score: # Manual score can coexist
  QualitySME: 0.9
---
```

**Organization:**
```
artifacts/verification/
├── static-analysis/
│   ├── cppcheck-SWD-042.xml
│   └── clang-tidy-report.txt
└── coverage/
    └── temperature_summary.txt # Or .html, .info
```

---

### 6. Compliance (Standards)

**What:** Documentation proving adherence to standards (ISO 26262, etc.).
**Artifacts:** Documents detailing HARA, ASIL justifications (`docs/standards/`).
**Linked In:** Requirements where ASIL or standard compliance is relevant (URD, SRD, SWD).

**Example (using references:):**
```yaml
---
id: SWD-042
ASIL: B
# ... other fields ...
references:
  - type: "file"
    path: docs/standards/iso26262/asil-justification-swd-042.md
  - type: "file"
    path: docs/standards/iso26262/hazard-analysis-temperature.md
score: # Manual score based on compliance doc review
  SafetySME: 1.0
---
```

**Organization:**
```
docs/standards/
├── iso26262/
│   ├── asil-justification-swd-042.md
│   └── hazard-analysis-temperature.md
└── autosar/
    └── component-mapping.md
```

---

## 🔗 How to Link Evidence & Configure Validation

### Method 1: Linking Passive Artifacts (Using references:)

Add a `references:` block (a YAML list) to the frontmatter. Each item represents one linked artifact. This provides context for human SME scoring.

```yaml
---
id: <REQ-ID>
# ... other fields ...
references:
  - type: "file"
    path: <relative/path/to/artifact>
  # ... more references ...
score: # REQUIRED if no evidence block and not propagated
  <SME_ID>: <0.0-1.0>
---
```

**Purpose:** Links artifacts for human reviewers. The SME reviews these artifacts and manually assigns a score in the `score:` block.

---

### Method 2: Configuring Automated Validators (Using evidence:)

Add an `evidence:` block to configure an automated validator that will calculate the score programmatically.

```yaml
---
id: <REQ-ID>
# ... other fields ...
evidence:
  type: <validator_name>
  references:
    - type: "file"
      path: <path/to/artifact/to/validate>
  configuration:
    <param1>: <value1>
    <param2>: <value2>
# score: block is optional here, can coexist for manual override
---
```

**Purpose:** Automates scoring based on predefined validation logic (e.g., test pass/fail, zero errors in static analysis).

**Requirements:**
- Custom validator must be implemented and registered with `trudag`
- Validator reads the artifact(s) specified in `evidence.references`
- Validator returns a score (0.0 - 1.0) based on its logic

---

### Method 3: Combining Methods

You can use both `references:` and `evidence:` blocks together, and optionally include a `score:` block for manual SME input.

```yaml
---
id: SWD-042
# ... other fields ...
references: # Passive links for human context
  - type: "file"
    path: src/sensors/temperature.cpp
  - type: "url"
    path: https://github.com/SEAME-pt/Team04_DrivaPi/pull/42
evidence: # Automated check
  type: cppcheck_error_validator
  references:
    - type: "file"
      path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml
  configuration:
    fail_on_severity: ["error"]
score: # Manual SME score (can override or complement automated score)
  CodeReviewer: 1.0
---
```

**When to combine:**
- `references:` provides full context for documentation and traceability
- `evidence:` provides automated scoring for objective criteria
- `score:` allows SME to provide additional confidence assessment or override

---

## 📁 Naming Conventions

*(These conventions remain valid)*

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
temperature_summary.txt
speed_widget.lcov
```

---

## ✅ Checklist by ASIL

*(This checklist remains valid; ensure `references:` links and appropriate scoring are used)*

### ASIL A (DrivaPi display features)

- [ ] 1+ reviewer (Manual `reviewed:` field filled)
- [ ] Code implemented (`references:` link to code)
- [ ] Unit tests (`references:` link to test code & results, aim >60% coverage)
- [ ] Git history (Implicit)
- [ ] **Score assigned** (`score:` block or `evidence:` block)

### ASIL B (DrivaPi typical: sensors, control)

- [ ] 2+ reviewers (Manual `reviewed:` field filled, potentially list multiple reviewers)
- [ ] Code implemented (`references:` link)
- [ ] Unit tests (`references:` link, aim >80% coverage)
- [ ] Integration tests (`references:` link to code & results)
- [ ] Static analysis clean (`references:` link to report showing 0 errors, consider `evidence:` validator)
- [ ] PR with 2+ approvals (`references:` link to PR URL)
- [ ] **Score assigned** (`score:` block with multiple SMEs or `evidence:` block)

### ASIL C (Emergency stop)

- [ ] All of ASIL B +
- [ ] System tests (`references:` link)
- [ ] Independent review noted in `reviewed:` field or linked (`references:`)
- [ ] Aim >90% coverage (`references:` link to coverage report, consider `evidence:` validator)
- [ ] FMEA documented (`references:` link to FMEA doc)
- [ ] **Score assigned** (`score:` block with multiple independent SMEs)

### ASIL D (Highest safety level — not currently used in DrivaPi)

- [ ] All ASIL C items
- [ ] Formal methods evidence (e.g., formal proofs, model checking; add `references:` links to artifacts)
- [ ] Tool qualification evidence (documentation that verification tools are qualified per ISO 26262; add `references:` link)
- [ ] Executable validation (mandatory — prototyping or simulation evidence; add `references:` link)
- [ ] **Score assigned** (`score:` block with multiple independent SMEs)

---

## 🎯 Best Practices

1. **Link evidence using the `references:` block** as you create/generate it for human traceability.
2. **Use paths relative to repo root** in `path:` for portability.
3. **Ensure the `path:` is clear and specific.**
4. **Organize generated artifacts by requirement ID** where practical.
5. **Automate artifact generation** via CI/CD. Ensure CI commits artifacts meant for version control.
6. **Implement `evidence:` validators** for objective criteria (test pass/fail, static analysis errors).
7. **Assign `score:` values** for all bottom-level requirements (LLTCs) based on SME review.
8. **Use multiple SME reviewers** in `score:` block for higher ASIL levels.
9. **Review linked evidence** as part of the requirement/code review process.
10. **Keep evidence updated:** Re-run CI (tests, analysis) when code changes and commit updated artifacts. Ensure `references:` paths remain correct and re-run `trudag score`.

---

## 🔄 Evidence Workflow (Updated for references:, evidence:, and score:)

```bash
# 1. Create/Edit requirement
trudag manage create-item SWD 042 reqs/swd
nano reqs/swd/SWD-042.md

# 2. Implement code
nano src/sensors/temperature.cpp

# 3. Implement test
nano tests/unit/test_temperature.cpp

# --- CI Pipeline Executes ---
# 4. CI runs tests & generates results
./run_tests.sh > artifacts/verification/tests/LLTC-042-results.xml
# 5. CI runs analysis & generates report
cppcheck src/sensors/temperature.cpp 2> artifacts/verification/static-analysis/cppcheck-SWD-042.xml
# 6. CI commits generated artifacts (if configured)
git add artifacts/verification/... && git commit ...
# --- End CI Pipeline ---

# 7. Link artifacts and configure scoring in requirement
nano reqs/swd/SWD-042.md
# Add 'references:' block with paths
# Add 'evidence:' block if automated validation desired
# Add 'score:' block with SME assessment (or wait for evidence validator)

# 8. Validate TSF structure
trudag manage lint

# 9. Calculate scores (runs evidence validators, aggregates SME scores)
trudag score

# 10. Commit requirement changes
git add reqs/swd/SWD-042.md .dotstop.dot # .dotstop might change
git commit -m "feat(swd): Add SWD-042 with evidence links and scoring"

# 11. Generate trustable report
trudag publish --output-dir artifacts/trustable-report

# 12. Create PR for review (includes code, tests, req with links & scores, generated artifacts)
```

---

## 🐛 Common Problems

*(Updated for `references:`, `evidence:`, and `score:`)*

### "Evidence file not found" (Report Error)

**Cause:** Incorrect `path:` in `references:` or `evidence.references:` block.

**Fix:** Verify path relative to repo root; correct in `.md`. Run `ls path/from/repo/root` to verify.

### "Evidence not shown in report"

**Cause:** `references:` block missing or incorrectly formatted YAML in frontmatter.

**Fix:** Add/correct the `references:` section in the requirement `.md`. Run `trudag manage lint` to validate.

### "Requirement has score 0.0" (Unexpected)

**Cause:** No `score:` block and no `evidence:` block provided, and requirement is not a parent with children.

**Fix:** Add either a `score:` block with SME assessment or an `evidence:` block with automated validator configuration.

### "Score not updated after evidence change"

**Cause:** `trudag score` not re-run after artifacts changed.

**Fix:** Re-run `trudag score` after CI updates artifacts or after manually changing `score:` values. Commit updated `.dotstop.dot` if changed.

### "Old evidence linked after code change"

**Cause:** CI didn't re-run/commit updated generated artifacts (test results, analysis).

**Fix:** Trigger CI. Ensure CI commits updated artifact files. Verify `references:` paths point to the latest artifacts. Re-run `trudag score`.

### "evidence: validator fails"

**Cause:** Custom validator not properly registered or has a bug.

**Fix:** Check validator implementation. Ensure it's registered with `trudag`. Test validator standalone. Check `configuration:` parameters in `evidence:` block.

---

**More info:**
- Commands → [reference.md](reference.md)
- Workflows → [workflow.md](workflow.md)
- Theory → [training.md](training.md)
