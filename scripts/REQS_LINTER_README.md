# Requirements linter (scripts/reqs_lint.py)

This repository contains a small, dependency-free YAML linter to help maintain consistent requirement documents for the Trustable Software Framework (TSF) workflow.

Purpose
-------
- Ensure minimal structural quality and traceability of requirement files under `reqs/`.
- Catch common mistakes (leftover markdown fences, missing top-level ID mapping, mismatched `ref:` values, missing reviewer names).
- Be lightweight so it can run in pre-commit hooks or CI without external dependencies.

Quick usage
-----------
Run the linter against your `reqs/` directory:

```bash
python3 scripts/reqs_lint.py reqs --verbose
```

Exit codes
----------
- 0: no issues found
- 1: one or more issues detected
- 2: usage or path error

Checks performed
----------------
- No markdown code fences (```) are allowed inside YAML files.
- The first non-empty line must be a top-level mapping key representing the requirement ID, e.g. `SWD-001:`.
- The top-level ID must match the filename stem (for traceability).
- Files named `.doorstop.yml` are skipped (these are Doorstop configuration files, not requirement items).
- A `ref:` field must be present and equal to the file ID (the linter accepts indentation, quotes, and simple formatting).
- The `reviewers:` block must exist and contain at least one list item with a `name:` entry. (We intentionally do NOT require emails to respect privacy.)

Expected YAML snippet
---------------------
Example minimal structure accepted by the linter:

```yaml
SWD-001:
  active: true
  derived: false
  header: 'Short title'
  level: 1.0
  links: []
  normative: true
  ref: SWD-001
  reviewed: null
  reviewers:
    - name: 'Jane Doe'
  text: 'A short single-sentence requirement statement.'
```

Notes and guidance
------------------
- The linter intentionally enforces only structural checks. TSF-specific reasoning (confidence scoring, evidence linking, automated validation) is out-of-scope and should be performed with Trustable tooling (trudag) plus human SME review.
- Use the linter in CI to fail early on malformed or untraceable requirements.
- If you prefer a gentler onboarding, the linter can be adjusted to treat missing reviewers or empty refs as warnings rather than failures; this file documents the current (strict) behaviour.

Contributing
------------
- The script is intentionally small and dependency-free. Contributions to the linter should keep that constraint where possible.
- When you update the linter, add a short note here explaining the rationale and run the linter against existing `reqs/` files to avoid regressions.

Contact
-------
For questions about TSF workflow integration or the linter rules, link to `docs/tsf/TSF-requirement-template.md` and the Trustable docs in `docs/tsf/`.

---
Generated/updated by tooling to help onboarding and CI for TSF requirements.
