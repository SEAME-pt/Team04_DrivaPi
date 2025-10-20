# Verification & Validation (VV) plan — TSF companion

This document provides a practical, repository-focused Verification & Validation (VV) plan template mapped to ASIL levels (A–D). It is intended to be used alongside the project requirement templates, traceability matrix, and CI checks. The goal is to provide a minimum viable VV framework that teams can follow to collect evidence, run checks, and prepare for audits.

> Assumptions
> - "Requirement" refers to YAML files under `reqs/` following the TSF templates.
> - Traceability matrix (CSV + manifest) is produced by `scripts/traceability_check.py` and stored in `artifacts/` by CI.
> - The VV activities below are intended as guidance; adapt to project risk, contractual, or regulatory needs.

## How to use this file
- For each requirement, pick the ASIL level (A–D) in the `header` or `metadata` fields, or include mapping in the traceability CSV.
- Use the per-ASIL checklists when authoring a requirement and when performing reviews.
- Store verification artifacts (test results, design review notes, static analysis reports) in `artifacts/verification/` and reference them from requirement YAMLs via `links:`.
- CI will publish the traceability manifest and report. Keep artifacts referenced in the manifest stable for audit retrieval.

## Summary table (quick)
- ASIL A: Low safety-criticality. Lightweight verification: peer review, unit tests where applicable, traceability to design.
- ASIL B: Moderate. Add integration tests, design reviews, requirement-to-test mapping, and static checks.
- ASIL C: High. Add formal test reports, code coverage gating, design verification sign-offs, and records of test execution.
- ASIL D: Very high. Require test benches, hardware-in-the-loop (HIL) runs (if applicable), independent verification, formal change control, and signed evidence.

---

## Per-ASIL guidance and checklist

### ASIL A — Minimal assurance
Recommended verification activities
- Authoring: clear acceptance criteria (GIVEN/WHEN/THEN), owner assigned, assumptions noted.
- Review: 1 peer review; reviewer signs `reviewers` in YAML and sets `reviewed:` date when approved.
- Tests: unit tests exercising logic directly associated with the requirement; smoke/integration tests if component-level integration required.
- Evidence: small test report, review notes, traceability mapping to design/code where applicable.

Checklist for authors/reviewers
- [ ] Requirement text unambiguous and self-contained
- [ ] Acceptance criteria present and executable
- [ ] Owner assigned
- [ ] Traceability links to design/code/tests added if available
- [ ] Peer-reviewed and `reviewed:` field set

### ASIL B — Moderate assurance
Recommended verification activities
- Authoring: as ASIL A; ensure acceptance criteria cover edge-cases.
- Review: multi-disciplinary review (design + implementation). Use checklist in PR template.
- Tests: unit + integration tests, with CI run and passing build.
- Static analysis: run linters / style or basic static checks; include results in artifacts.
- Evidence: test logs, CI job IDs, design review notes.

Checklist for authors/reviewers
- [ ] All ASIL A checks complete
- [ ] Integration tests exist and pass in CI
- [ ] Traceability from requirement to test case(s) exists in the matrix
- [ ] Static checks executed and listed in artifacts
- [ ] Design reviewer signoff

### ASIL C — Elevated assurance
Recommended verification activities
- Authoring: more formal acceptance criteria; enumerate environmental assumptions and error modes.
- Review: independent reviewer(s) where possible; document review findings and mitigations.
- Tests: targeted system/integration tests; regression test suites; reproducible test scripts that can be run locally and in CI.
- Coverage and metrics: measure and record coverage/metric goals where applicable (e.g., code coverage for safety-related software modules).
- Evidence: signed test reports, coverage reports, review minutes, configuration of test environment.

Checklist for authors/reviewers
- [ ] All ASIL B checks complete
- [ ] Independent reviewer signoff (non-author)
- [ ] Reproducible test procedures and logs stored under artifacts/verification/
- [ ] Coverage/metric reports attached and reviewed
- [ ] Design verification recorded and linked

### ASIL D — Highest assurance
Recommended verification activities
- Authoring: formal specification-style acceptance criteria; enumerated failure modes and mitigations.
- Review: independent verification team where possible; formal review minutes and signed approvals.
- Tests: full system-level tests including HIL (hardware-in-the-loop) if required; regression and stress tests; documented environmental variation testing.
- Configuration management: strict change control for any changes to requirement files or verification artifacts; baselining of approved SHAs.
- Evidence: signed and timestamped test reports, test bench configurations, calibration records, and full chain-of-custody of artifacts.

Checklist for authors/reviewers
- [ ] All ASIL C checks complete
- [ ] Formal sign-off by designated authority
- [ ] System/HIL tests executed; artifacts stored and checksums recorded
- [ ] Baseline tag created for the approved SHA(s)
- [ ] Retention policy for artifacts defined and applied (e.g., S3 retention or central vault)

---

## Verification artifacts organization (recommended)
- `artifacts/verification/tests/` — store machine-readable test results (JUnit, JSON, CSV)
- `artifacts/verification/reports/` — human-readable test reports and review minutes (PDF/MD)
- `artifacts/verification/coverage/` — coverage reports
- `artifacts/verification/bench/` — HIL/bench logs and calibration data (if applicable)
- `artifacts/traceability/` — output of `scripts/traceability_check.py` (matrix CSVs, manifest.json, report.md)

## Mapping: requirement → evidence (example YAML snippet)
Add a `links:` entry in a requirement that references an artifact stored in `artifacts/`:

```yaml
links:
  - artifacts/verification/tests/REQ-1234-junit.xml
  - artifacts/verification/reports/REQ-1234-test-report.md
```

CI and automation notes
- CI already publishes the traceability manifest and report to Actions artifacts. For long-term retention, configure the repository CN as documented in `docs/tsf/TRACEABILITY_README.md` to enable S3 retention.
- For ASIL C/D, prefer creating a baseline PR and tag (scripts/baseline_reqs.py) and store the tag/PR number in the requirement `reviewed:` or `baseline:` fields.

## Next steps and templates
- Use this file as a living template; iterate with engineering and safety teams.
- Optional: create ASIL-specific PR templates that require certain checklist items before merging.
- Optional: automate mapping enforcement in `scripts/traceability_check.py` so that requirements without required evidence fail the CI for higher ASILs.

## Appendix: Example quick mapping
- ASIL A: unit tests + peer review
- ASIL B: unit + integration tests + design review + static checks
- ASIL C: system tests + coverage reports + independent review
- ASIL D: HIL/system bench + formal sign-off + baselined artifacts


---

Document created: 2025-10-17
