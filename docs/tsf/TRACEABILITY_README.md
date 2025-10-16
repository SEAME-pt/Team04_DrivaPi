Traceability checker
====================

This repository includes a simple, dependency-free traceability checker at `scripts/traceability_check.py`.

What it does
- Scans `reqs/` YAML files and extracts common link patterns (`links:`, `ref:`, `satisfied-by:`).
- Produces `artifacts/traceability-matrix.csv` with columns: `req_id,target_id,link_type,source_file`.

Quick run
```
python3 scripts/traceability_check.py reqs --output artifacts/traceability-matrix.csv
```

CI
-- Add a pipeline step that runs the checker and fails on `--fail-on-unlinked` if you want to prevent isolated requirements.
