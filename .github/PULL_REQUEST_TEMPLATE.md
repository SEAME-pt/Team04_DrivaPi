# Pull Request — Requirement / Safety change template

Use this template for PRs that add or modify requirements, verification artifacts, or traceability mappings.

## Summary
- Short description of the change:
- Type: (requirement / test / traceability / docs / other)
- Affected requirement IDs (comma-separated):

## ASIL and impact
- ASIL level (A/B/C/D or N/A):
- Summary of safety impact (one sentence):

## Checklist — author
- [ ] I added/updated the requirement YAML under `reqs/` and followed the TSF template
- [ ] `acceptance:` criteria are present and specified (GIVEN/WHEN/THEN)
- [ ] `owner:` and `assumptions:` fields are populated where applicable
- [ ] Traceability links to design/tests added to `links:` in the requirement YAML
- [ ] CI passes locally and in GitHub Actions (linter + traceability)
- [ ] For ASIL C/D: verification artifacts attached under `artifacts/verification/` and referenced in the requirement `links:`

## Reviewer notes
- Focus areas for review:
  - Acceptance criteria clarity and testability
  - Correct ASIL mapping
  - Complete traceability (requirement → test → design)

## How to test locally
- Run linter and traceability check:

```bash
python3 scripts/reqs_lint.py reqs/ --check-links --require-acceptance
python3 scripts/traceability_check.py --output artifacts/traceability/
```

## Notes / context
- Add any additional context or screenshots here.

---

Please set the PR reviewers to a person with domain knowledge and a second reviewer for independent verification when ASIL >= C.
