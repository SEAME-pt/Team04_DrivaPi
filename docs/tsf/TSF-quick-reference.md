TSF Quick Reference

A short cheat-sheet for the team. Use this for day-to-day work with requirements and traceability.

Terminology

- URD: User Requirements Document (high-level user needs)
- SRD: System Requirements Document (system-level requirements)
- SWD: Software Requirements Document (software-level requirements)
- LLTC: Low-Level Technical Components / testable lower-level requirements
- ASIL: Automotive Safety Integrity Level (A, B, C, D) — D is highest

Minimal requirement YAML fields (example)

```yaml
SWD-001:
  header: "Short title"
  text: |
    Full description...
  level: 1.0
  active: true
  derived: false
  normative: true
  links: []
  ref: "SWD-001"
  reviewers:
    - name: "Reviewer Name"
  reviewed: ""  # filled by trudag upon approval
```

See [TSF requirement template](TSF-requirement-template.md) for a field-by-field explanation, examples and validation tips.

TSF Quick Reference — one page

Purpose
-------
Quick cheat-sheet for authors and reviewers working with `reqs/` and the Trustable workflow.

Core concepts
-------------
- File layout: `reqs/<category>/<ID>.yml` (categories: `urd/`, `srd/`, `swd/`, `lltc/`)
- ID: stable top-level mapping key and filename stem (e.g. `SWD-001`)
- Minimal required fields: `header`, `text`, `ref`, `reviewers` (with `name`), `reviewed` (null until approved)

Minimal YAML example
--------------------
```yaml
SWD-001:
  header: "Short title"
  text: |
    One-sentence clear, unambiguous requirement.
  level: 1.0
  active: true
  derived: false
  normative: true
  links: []
  ref: SWD-001
  reviewers:
    - name: "Jane Doe"
  reviewed: null
```

Quick rules
-----------
- `ref:` value must equal the file ID and be parsable by tooling.
- `reviewers:` must include at least one `name:` entry (email optional).
- Avoid markdown fences (```) in YAML files.

Traceability & approvals
------------------------
- Use `links:` to reference related requirement IDs (upstream/downstream).
- Example approval flow:
  1. Author updates YAML and adds reviewer name.
  2. Reviewer runs validation, reviews the artifact, and records the approval.
  3. Record approval by setting `reviewed:` to the approving commit SHA (automated with trudag or manually).

Useful commands
---------------
- Lint YAMLs: `python3 scripts/reqs_lint.py reqs --verbose`
- trudag migrate (Doorstop backend): `trudag --door manage migrate`
- trudag set review: `trudag --door manage set-item <path-to-yml>`

References
----------
- Full template and field explanations: `docs/tsf/TSF-requirement-template.md`
- Training and TSF methodology: `docs/tsf/TSF-training.md`

Notes
-----
This cheat-sheet is intentionally concise. For full TSF compliance and confidence scoring, follow the training pack and use trudag to produce a Trustable Report.
