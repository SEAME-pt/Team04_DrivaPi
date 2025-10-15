#!/usr/bin/env python3
"""Simple linter for requirement YAML files under reqs/.

Checks each YAML file for required fields: text, links, ASIL, Verification Method, reviewed.
Also verifies that links reference an existing item file (by filename without extension).

Usage: python3 scripts/reqs_lint.py
"""
from __future__ import annotations
import sys
from pathlib import Path

try:
    import yaml
except Exception:
    print("PyYAML is required. Install with: pip install pyyaml")
    sys.exit(2)

ROOT = Path(__file__).resolve().parents[1]
REQS = ROOT / "reqs"

required_fields = ["text", "links", "ASIL", "Verification Method", "reviewed"]

# Allowed enumerations
ASIL_ALLOWED = {"A", "B", "C", "D", "QM"}
VERIF_ALLOWED = {"Unit Test", "Integration Test", "Review", "Formal Analysis", "Test"}

def is_git_sha(s: str) -> bool:
    if not isinstance(s, str):
        return False
    # accept short (7) to full (40) hex shas
    return 7 <= len(s) <= 40 and all(c in "0123456789abcdefABCDEF" for c in s)

def load_yaml(path: Path):
    try:
        with path.open("r", encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    except Exception as e:
        return {"__load_error": str(e)}

def main():
    if not REQS.exists():
        print("No reqs/ directory found.")
        return 1

    files = list(REQS.rglob("*.yml")) + list(REQS.rglob("*.yaml"))
    # ignore doorstop metadata files and hidden files
    files = [f for f in files if f.name != '.doorstop.yml' and not f.name.startswith('.')]
    if not files:
        print("No YAML requirement files found under reqs/.")
        return 0

    ids = {p.stem for p in files}
    problems = []

    for p in sorted(files):
        data = load_yaml(p)
        if "__load_error" in data:
            problems.append((p, f"YAML load error: {data['__load_error']}"))
            continue
        missing = [f for f in required_fields if f not in data]
        if missing:
            problems.append((p, f"Missing fields: {', '.join(missing)}"))
        # links should be a list
        links = data.get("links", [])
        if links is None:
            problems.append((p, "links is null; expected a list"))
            continue
        if not isinstance(links, list):
            problems.append((p, f"links has wrong type: {type(links).__name__}; expected list"))
            continue
        # verify linked ids exist
        for link in links:
            if not isinstance(link, str):
                problems.append((p, f"link value not a string: {link!r}"))
                continue
            # allow some URL-like links; only check simple IDs
            if link in ids:
                continue
            # also accept fuzzy matches like SRD001 vs SRD001.yml not present
            if link + ".yml" in {f.name for f in files} or link + ".yaml" in {f.name for f in files}:
                continue
            problems.append((p, f"Broken link: {link}"))

        # ASIL validation
        asil = data.get("ASIL")
        if asil is None or not isinstance(asil, str) or asil not in ASIL_ALLOWED:
            problems.append((p, f"ASIL invalid or missing (expected one of {sorted(ASIL_ALLOWED)})"))

        # Verification Method validation
        vm = data.get("Verification Method")
        if vm is None or not isinstance(vm, str) or vm not in VERIF_ALLOWED:
            problems.append((p, f"Verification Method invalid or missing (expected one of {sorted(VERIF_ALLOWED)})"))

        # reviewed validation (allow null or git sha)
        reviewed = data.get("reviewed")
        if reviewed is not None and reviewed != "null" and not is_git_sha(str(reviewed)):
            problems.append((p, f"reviewed field not a git SHA or null: {reviewed!r}"))

        # optional reviewers list
        reviewers = data.get("reviewers")
        if reviewers is not None and not isinstance(reviewers, list):
            problems.append((p, "reviewers field present but not a list"))

    if not problems:
        print("OK: No issues found in reqs/ YAML files.")
        return 0

    print("Found issues in requirement files:")
    for p, msg in problems:
        print(f" - {p.relative_to(ROOT)}: {msg}")

    return 1

if __name__ == "__main__":
    raise SystemExit(main())
