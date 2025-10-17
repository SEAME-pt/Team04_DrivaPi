# Requirement Review Checklist (Author + Reviewer)

A concise checklist to use when authoring and reviewing requirements. Add the checklist to PR descriptions and use it as a gate for reviewers.

General (all ASILs)
- [ ] Requirement ID and `ref:` match filename and format (e.g., URD-001)
- [ ] Title and `text:` are clear and unambiguous
- [ ] `owner:` field present
- [ ] `assumptions:` enumerated (or explicitly empty list)
- [ ] `acceptance:` present with GIVEN/WHEN/THEN style items
- [ ] `reviewers:` includes at least one reviewer and `reviewed:` set when approved
- [ ] `links:` include design or test artifacts where applicable
- [ ] Linter (`scripts/reqs_lint.py`) run and pass locally

ASIL-specific additions
- ASIL A
  - [ ] Peer review completed
  - [ ] Unit tests (if applicable) exist
- ASIL B
  - [ ] Integration tests included and passing
  - [ ] Design reviewer signed off
  - [ ] Static checks executed (lint or basic static analysis)
- ASIL C
  - [ ] Independent reviewer (non-author) performed review
  - [ ] System/integration test procedures documented and reproducible
  - [ ] Coverage/metric reports attached
- ASIL D
  - [ ] Formal sign-off attached (document or PR approval by authority)
  - [ ] System/HIL test logs attached and checksums recorded
  - [ ] Baseline tag or PR referenced in the `baseline:` or `reviewed:` field

Verification evidence
- Store machine-readable test outputs under `artifacts/verification/tests/`
- Store human-readable review minutes and reports under `artifacts/verification/reports/`
- Reference the artifact paths from `links:` in the requirement YAML

Reviewer instructions
- Ensure acceptance criteria are testable and precise
- Validate traceability to tests and design where applicable
- For ASIL C/D, verify that artifacts are reproducible and stored in the artifact tree

Usage
- Copy the checklist into PR descriptions for requirement changes
- Use CI to verify presence of `acceptance:` for all requirements (already enforced in the workflow when enabled)

Document created: 2025-10-17
