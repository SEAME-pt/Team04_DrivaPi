# TSF Training Slides — Speaker notes

Slide 1 — Title
- Trustable Software Framework (TSF): fundamentals and practical application for automotive software

Slide 2 — Learning goals
- Understand TSF principles and how they apply to requirements and evidence
- Basic ISO 26262 and ASPICE awareness
- How to write traceable, testable requirements

Slide 3 — Why TSF
- TSF helps make claims (requirements) explicit and links them to evidence
- Enables assessors to evaluate confidence in software artifacts

Slide 4 — TSF model (graph)
- Statements, links, artifacts
- Evidence and confidence scoring

Slide 5 — Requirements and repo layout
- `reqs/` categories: urd/, srd/, swd/, lltc/
- Template fields: `ref`, `header`, `text`, `reviewers`, `reviewed`, `links`

Slide 6 — Linting and authoring workflow
- Use `scripts/new_req.py` and `scripts/reqs_lint.py`
- PR-based review and reviewer stamping

Slide 7 — Traceability matrix and CI
- We generate a CSV and report via `scripts/traceability_check.py`
- CI uploads artifacts and optionally S3 retention

Slide 8 — V&V and ASIL mapping
- What additional evidence ASIL levels require
- Examples: static analysis for ASIL B/C/D, formal methods for high-risk claims

Slide 9 — Hands-on lab overview
- Author a requirement, link it to design and a test, run linter, run traceability checker

Slide 10 — Assessment and next steps
- Quiz, lab result, sign-off on baseline

