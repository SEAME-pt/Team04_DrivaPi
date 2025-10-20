# Official TSF tooling: trudag + doorstop

This ops guide documents the official, supported workflow for working with TSF requirements in this repository. The repository policy is to rely on official tooling (trudag, doorstop, and other Trustable-provided tools) rather than repository-local helper scripts. Legacy helpers that once existed in the repo are preserved in git history only; do not reintroduce them into main branches without team agreement.

## Why this policy
- Official tools are maintained, audited, and tested by the Trustable project.
- Using the official toolchain reduces maintenance burden and avoids divergence between projects.
- CI and release workflows are configured around the official tooling; local helpers may not be reproducible in CI.

## Recommended local setup (Python virtualenv)
1. Install Python 3.11+ (or the version used by CI).
2. Create a venv in the repo:

   python -m venv .venv
   source .venv/bin/activate
   python -m pip install --upgrade pip

3. Install the official tools:

   pip install trustable doorstop

4. Verify installation:

   trudag --help
   doorstop --help


## Docker option (reproducible environment)
CI runs tools inside a container. To reproduce locally using Docker, either run the same image used in CI (see `.github/workflows/reqs-checks.yml`) or use a small helper Dockerfile:

# Example (not checked into repo):
# FROM python:3.11-slim
# RUN pip install --no-cache-dir trustable doorstop
# WORKDIR /work
# ENTRYPOINT ["trudag"]

Run the container with a bind mount to the repository to operate on local files in a reproducible environment.

## Common actions
- Lint requirements (run locally or in CI):

  trudag manage lint

- Migrate or initialise doorstop-backed requirements:

  trudag manage migrate

- Export reports and traceability matrices (as CI does):

  trudag report export --output artifacts/traceability

Note: some `trudag` subcommands may require configuration or a `doorstop` backend config file. Consult `trudag --help` for subcommand options.


## CI and artifacts
- CI is configured to run the official tooling and publish `artifacts/traceability/` and other verification artifacts. See `.github/workflows/reqs-checks.yml` for details.
- For long-term retention, follow the repository's documented retention strategy (S3 or other storage) as described in `docs/tsf/TRACEABILITY_README.md`.

## If you need archived helpers
Legacy helper scripts were intentionally removed from the main branch to enforce official-only tooling. If you have a legitimate need to inspect or restore an archived helper, retrieve it from git history using:

  git log -- scripts/
  git show <commit>:path/to/script.py

Do not add archived scripts back into `main` or production branches without team approval. Prefer wrapping small, necessary conveniences as documented, minimal `.github/` workflows or as optional developer-only helpers under a `dev-tools/` path that is gated by a repo policy and reviewed.

## Troubleshooting
- If `trudag` subcommands fail in CI but work locally, check the Python version and pinned dependencies in CI and reproduce the same environment locally (see Docker option above).
- If a required artifact is missing from `artifacts/traceability/`, re-run the report export locally with the commands above and open an issue for CI review if it doesn't reproduce.

## Policy reminder
This repository maintains an official-only tooling policy for requirements and traceability. Training materials and README files have been updated to remove references to repository-local helper scripts.
