# TSF Requirements Management (DrivaPi Team04)

This document describes the recommended workflow for using trudag and Doorstop to manage requirements in DrivaPi, aligned with Eclipse TSF and ISO 26262 expectations.

## Hierarchy (V-model)

Create the reqs directory and V-model folders (URD → SRD → SWD → LLTC):

```bash
mkdir -p reqs
doorstop create URD ./reqs/urd --prefix URD
doorstop create SRD ./reqs/srd --parent URD --prefix SRD
doorstop create SWD ./reqs/swd --parent SRD --prefix SWD
doorstop create LLTC ./reqs/lltc --parent SWD --prefix LLTC
```

## Creating items (trudag)

Prefer `trudag manage create-item` to create new items so the tool can track provenance and scoring:

```bash
trudag manage create-item SRD 001 ./reqs/srd/
trudag manage create-item SWD 001 ./reqs/swd/
trudag manage create-item LLTC 001 ./reqs/lltc/
```

## Linking items (traceability)

Create backward and forward links. Example using Doorstop link:

```bash
doorstop link SWD001 SRD001    # SWD -> parent SRD
doorstop link LLTC001 SWD001   # LLTC -> SWD (test verifies SWD)
```

## YAML model (required fields)

Each requirement YAML item should include at minimum:

- `text`: requirement statement (string, markdown)
- `links`: list of related item ids (parent, children, tests)
- `ASIL`: string (A|B|C|D|QM)
- `Verification Method`: string (Unit Test|Integration Test|Review|Formal Analysis)
- `reviewed`: null or Git SHA set by trudag after approval

Example:

```yaml
text: |
  The software shall read the CAN message ID 0x100 and update the internal vehicle speed variable within 50 ms.
links:
  - SRD001
ASIL: B
Verification Method: Unit Test
reviewed: null
```

## Lint and governance

Before approval, run the trudag linter to detect suspect links and unreviewed items:

```bash
trudag manage lint
```

After human review, approve an item (this should set `reviewed` to the commit SHA):

```bash
trudag manage set-item SWD001
git add reqs
git commit -m "REQS: Approve SWD001 (reviewed)"
```

## Baseline (Git)

When the set of requirements is approved and `reviewed` is set, create an annotated tag:

```bash
git tag -a BASELINE-SWD-V1.0 -m "SWD baseline v1.0 - approved"
git push origin BASELINE-SWD-V1.0
```

## Exporting artifacts (optional)

Use trudag artifact export to create an archive of the graph for audit:

```python
from pathlib import Path
from trudag.dotstop.core.artifact import Artifact

# Example (pseudo):
# Artifact.export_to(graph, 'DrivaPi', Path('drivapi.trustable'))
```

## Examples included

This repo includes sample items under `reqs/urd`, `reqs/srd`, `reqs/swd`, and `reqs/lltc` to get started.
