## TSF Hands-on Lab

Purpose: a short, repeatable lab that teaches requirement authors and reviewers how to create a requirement, add acceptance criteria, link verification evidence, run the repository checks (linter and traceability), fix issues, and create a baseline.

Audience: new team members and reviewers. The lab maps directly to the assessment rubric and CI checks used by this repository.

Duration: 30-60 minutes

Prerequisites
- A working checkout of this repository on your machine.
- Python 3 installed (python3 on PATH).
- A terminal with the repo root as the current directory.

Lab steps

1) Create a new requirement from a template

 - Copy an existing template or use the repository templates as a starting point. For example:

   - Create `reqs/swd/SWD-NEW-EXERCISE.yml` and use `reqs/templates/SWD-template.yml` as a guide.

 - Minimal YAML structure the linter expects (example):

   SWD-XXX:
     header: "Sensor input validation"
     text: "The system shall reject invalid sensor data as defined by schema v1."
     ref: SWD-XXX
     reviewers:
       - name: Jane Doe <jane@example.com>
     reviewed: ""
     links:
       - TEST-001
     acceptance:
       - GIVEN: a malformed sensor payload
         WHEN: the payload is submitted
         THEN: the system rejects it and logs the error code 400

2) Run the linter

 - Run the linter in the repository root. To skip template warnings during the lab run use `--ignore-templates`:

 ```bash
 python3 scripts/reqs_lint.py reqs --verbose --ignore-templates --check-links
 ```

 - Expected outcome:
  ## TSF Hands-on Lab — Authoring, Linting & Traceability

  Purpose
  - Hands-on, repeatable lab for requirement authors and reviewers. Participants will: author a requirement from a template, add acceptance criteria, link verification evidence, run the repo checks (linter and traceability), fix issues, and baseline the requirement.

  Audience and duration
  - Audience: engineers and reviewers who will author or review requirements.
  - Duration: ~30–60 minutes.

  Objectives
  - Author a valid requirement using provided templates or `scripts/new_req.py`.
  - Run and fix issues reported by `scripts/reqs_lint.py`.
  - Create a traceability mapping and verify it with `scripts/traceability_check.py`.
  - Mark the requirement `reviewed:` and create a baseline commit/PR.

  Prerequisites
  - Repository checkout.
  - Python 3 (python3 on PATH).
  - git configured locally.
  - (Optional) AWS CLI if you plan to test S3 artifact retention.

  Quick workflow (commands)

  1) Create a branch

  ```bash
  git checkout -b lab/req-authoring-<yourname>
  ```

  2) Bootstrap a requirement

  Option A — use the helper:

  ```bash
  python3 scripts/new_req.py swd SWD-999
  # creates reqs/swd/SWD-999.yml from the template
  ```

  Option B — copy template and edit

  ```
  cp reqs/templates/SWD-template.yml reqs/swd/SWD-999.yml
  ```

  Minimal YAML example (what the linter expects):

  ```yaml
  SWD-999:
    header: "Sensor input validation"
    text: "The system shall reject invalid sensor data as defined by schema v1."
    ref: SWD-999
    reviewers:
      - name: Jane Doe <jane@example.com>
    reviewed: ""
    links:
      - LLTC-999
    acceptance:
      - GIVEN: a malformed sensor payload
        WHEN: the payload is submitted
        THEN: the system rejects it and logs a 400 error
  ```

  3) Run the linter (skip template noise during the lab)

  ```bash
  python3 scripts/reqs_lint.py reqs --verbose --ignore-templates --check-links
  ```

  - Expected: `OK: no issues found` for a clean file set.
  - If issues appear, fix the YAML (top-level ID, `ref:`, `reviewers:` block, acceptance presence) and re-run.

  4) Create a minimal linked LLTC placeholder (traceability demo)

  ```bash
  cp reqs/templates/LLTC-template.yml reqs/lltc/LLTC-999.yml
  # edit header/text/ref to LLTC-999 and commit
  ```

  5) Run the traceability checker

  ```bash
  python3 scripts/traceability_check.py reqs --output artifacts/traceability --by-category
  ```

  - Expected artifacts: `artifacts/traceability/` (per-category CSVs), `artifacts/traceability-report.md`, `artifacts/traceability-manifest.json`.
  - If the checker reports orphaned requirements or broken links, inspect the source YAMLs and `links:` entries.

  6) Mark reviewed and baseline

  - After verifying locally, set the `reviewed:` field to the commit SHA that you validated:

  ```bash
  git rev-parse --verify HEAD
  # set that SHA in the YAML under reviewed:
  ```

  - Commit and push your changes, then open a PR. CI will run the linter and traceability checks and publish artifacts.

  7) Cleanup (optional)

  - Remove lab-specific reqs or move them to `reqs/examples/` if you want to keep them.

  Grading and pass criteria (maps to the TSF Assessment Rubric)
  - Lab tasks (each pass=1):
    - Requirement authored with `ref`, `header`, `text`.
    - Linter runs clean for authored files.
    - Traceability mapping appears in the generated matrix/report.
    - `reviewed:` set to a valid git SHA.
    - PR created and CI artifacts generated.
  - Lab passing threshold: 4/5.

  Troubleshooting notes
  - Template warnings: templates intentionally contain placeholder IDs. Use `--ignore-templates` during lab runs.
  - Evidence detection: the checker uses `traceability_patterns.json` to match artifact names/types. If your artifacts use different naming, add patterns to that JSON and re-run the checker.
  - CI failures: inspect the CI job artifacts (traceability CSVs and report) in the workflow run to debug link or evidence issues.

  Instructor notes
  - The instructor should verify YAML correctness, the traceability report, and that the `reviewed:` field contains a valid commit SHA.
  - Record lab results manually in `docs/tsf/training-results.md` (or ask me to add a small helper to record results automatically).

  Document created/updated: 2025-10-17
- Update `reviewed:` in your SWD YAML with the git commit SHA (e.g., `git rev-parse HEAD`) after your PR or after commit.

