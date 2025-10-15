# Requirements (doorstop) — cross-platform notes

This folder contains requirement document trees managed by [doorstop]. We created the following document roots:

- `URD` (User Requirements Document) — `reqs/urd`
- `SRD` (System Requirements Document) — `reqs/srd`
- `SWD` (Software Design) — `reqs/swd`
- `LLTC` (Low-level test cases) — `reqs/lltc`

Why Docker?
- On macOS you may have Python 3.14 as the system `python3` which removes some stdlib modules used by older doorstop releases. To ensure reproducible behavior across macOS, Linux and Windows, a Docker image with Python 3.13 is provided.

Quick start — Docker (recommended for cross-platform reproducibility)

Build the image (run from repository root):

```bash
cd reqs
docker build -t team04-doorstop:3.13 .
```

Makefile (convenience)
----------------------

There is a `Makefile` in this directory with convenience targets to build and run the image and to create the document roots.

Examples (from repository root):

```bash
# build image
make -C reqs build

# show doorstop help inside container
make -C reqs run

# create URD / SRD / SWD / LLTC using the container
make -C reqs create-urd
make -C reqs create-srd
make -C reqs create-swd
make -C reqs create-lltc

# run arbitrary doorstop commands via the container
make -C reqs doorstop args="create URD ./reqs/urd -f"
```

Run doorstop commands inside the container (mount the repo so doorstop edits files in-place). Example: show help

```bash
# from repository root
docker run --rm -it -v "$PWD":/workspace -w /workspace team04-doorstop:3.13 --help
```

Create a new document tree (example used when you don't want to install doorstop locally):

```bash
# create URD (example) — run from repository root
docker run --rm -it -v "$PWD":/workspace -w /workspace team04-doorstop:3.13 URD ./reqs/urd -f
```

Or using the entrypoint to call doorstop directly:

```bash
docker run --rm -it -v "$PWD":/workspace -w /workspace team04-doorstop:3.13 -- doorstop create URD ./reqs/urd -f
```

Local alternative (macOS / Linux)

If you prefer to install doorstop locally, use `pipx` and a compatible Python (3.13) to avoid stdlib differences:

```bash
# ensure pipx is installed
python3 -m pip install --user pipx
python3 -m pipx ensurepath

# install doorstop with a specific Python interpreter (macOS example /opt/homebrew/bin/python3.13)
pipx install --python /opt/homebrew/bin/python3.13 doorstop

# then run (from repo root)
doorstop create URD ./reqs/urd -f
```

Notes and troubleshooting
- If doorstop fails with `ModuleNotFoundError: No module named 'cgi'` or `ModuleNotFoundError: No module named 'pkg_resources'`, it's likely because it's installed under Python 3.14+. Use the Docker image above or reinstall with Python 3.13.
- The Docker image uses `python:3.13-slim` and installs `doorstop` via pip for consistent behavior.

[doorstop]: https://doorstop.readthedocs.io/
