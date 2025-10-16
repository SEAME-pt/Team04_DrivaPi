Traceability checker changes

- 2025-10-16: Added `--by-category` option to `scripts/traceability_check.py` which emits per-category CSV matrices under `artifacts/` and appends a per-category summary to `artifacts/traceability-report.md`.
- Verified by running `python3 scripts/traceability_check.py reqs --by-category` locally; outputs written to `artifacts/`.
