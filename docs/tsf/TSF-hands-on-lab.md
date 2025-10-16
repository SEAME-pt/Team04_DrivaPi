# TSF Hands-on Lab — Authoring, Linting, Traceability

Duration: ~45–60 minutes
Audience: engineers and reviewers who will author requirements

Objectives
- Author a requirement using the template
- Run the linter and fix issues
- Create a simple traceability mapping to a test case
- Run the traceability checker and inspect the report
- Mark the requirement reviewed and create a baseline commit

Pre-reqs (local dev machine)
- Python 3.11
- git configured
- (optional) AWS CLI if using S3 uploads

Exercise steps

1) Create a branch

```bash
git checkout -b lab/req-authoring-<yourname>
```

2) Bootstrap a requirement

```bash
python3 scripts/new_req.py swd SWD-999
# or copy a template and rename to SWD-999.yml in reqs/swd/
```

3) Edit the YAML file
- Fill `header`, `text` (one-sentence requirement + acceptance criteria)
- Add `links:` to an upstream SRD or a test-case ID (LLTC)
- Add yourself as the reviewer under `reviewers:` (you can be both author and reviewer for lab purposes)

4) Run linter

```bash
python3 scripts/reqs_lint.py reqs/swd --verbose --ignore-templates
```

- Fix any issues shown by the linter and re-run until it reports `OK: no issues found`.

5) Create a small test placeholder
- Add an LLTC entry in `reqs/lltc/LLTC-999.yml` and link it from your SWD using `links: [LLTC-999]`.

6) Run traceability checker

```bash
python3 scripts/traceability_check.py reqs --output artifacts/traceability-matrix.csv
```

- Inspect `artifacts/traceability-report.md` and `artifacts/traceability-matrix.csv`.

7) Mark reviewed and baseline
- Update `reviewed:` in your SWD YAML with the git commit SHA (e.g., `git rev-parse HEAD`) after your PR or after commit.

```bash
git add reqs/swd/SWD-999.yml reqs/lltc/LLTC-999.yml
git commit -m "lab: add SWD-999 and LLTC-999"
# copy the commit SHA and set reviewed: in the YAML, then commit that change
```

8) Push and create PR
- Push the branch and create a PR. The CI will run the linter and traceability checks and upload artifacts.

Cleanup
- Remove the lab items or keep them as examples in a lab/ directory if desired.

Instructor notes
- The instructor should verify the YAML correctness, traceability report, and that the `reviewed:` field contains a valid commit SHA.

