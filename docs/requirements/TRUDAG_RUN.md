# Running trudag lint (venv and Docker)

This document explains how to run the `trudag` lint for the DrivaPi repository in two ways: using the workspace virtualenv, or using the included Docker container.

1) Using the workspace virtualenv

- Ensure you have a Python venv at `.venv` (the workspace setup tool may create it).
- Install dependencies into the venv (if not already):

```bash
# Activate your venv (example on macOS with zsh)
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install trustable doorstop pyyaml
```

- If you're on Python 3.14, Doorstop may import `distutils`. Run the included shim script to apply local compatibility shims:

```bash
python3 scripts/apply_trudag_shims.py
```

- Run the lint:

```bash
.venv/bin/trudag --door manage lint
```

2) Using Docker (recommended for reproducibility)

- Build and run the container (helper script):

```bash
./scripts/run_trudag_docker.sh
```

This builds a Python 3.11 image, installs Trustable/Doorstop from source, applies small compatibility patches, and runs `trudag --door manage lint` inside the container. The container approach avoids local environment issues.

Notes
- The repo contains `scripts/reqs_lint.py` — a lightweight, repo-local linter that verifies required fields and link consistency. It's used in CI workflows.
- The Dockerfile applies temporary patches to the installed Trustable package to work around small upstream API mismatches. Remove these patches when upstream fixes are released.
