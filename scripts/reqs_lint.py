#!/usr/bin/env python3
"""Lightweight linter for reqs/*.yml files.

Performs simple checks without external dependencies:
 - ensures no markdown code fences (```) remain
 - verifies a top-level ID mapping exists
 - checks for presence of common keys: header, text, reviewers, reviewed, ref

Usage: python3 scripts/reqs_lint.py <reqs_dir> [--verbose]
"""
import sys
from pathlib import Path


def check_file(path: Path, verbose: bool = False):
    text = path.read_text(encoding="utf-8")
    issues = []

    if '```' in text:
        issues.append('contains markdown code fence (```)')

    # Find a top-level key like SWD-001:
    lines = [l.rstrip('\n') for l in text.splitlines() if l.strip()]
    if not lines:
        issues.append('file is empty')
        return issues

    first = lines[0]
    import re

    m = re.match(r'^([A-Za-z0-9_\-]+):\s*$', first)
    if not m:
        issues.append('first non-empty line is not a top-level ID mapping (e.g. "SWD-001:")')

    # simple presence checks for common keys
    required = ['header:', 'text:', 'reviewers:', 'reviewed:', 'ref:']
    for key in required:
        if key not in text:
            issues.append(f'missing expected key `{key}`')

    # If we could extract an ID from the first line, check it matches filename and ref
    filename_stem = path.stem  # e.g. SWD-001
    if m:
        top_id = m.group(1)
        if top_id != filename_stem:
            issues.append(f'top-level ID `{top_id}` does not match filename `{filename_stem}`')

    # check ref: value roughly matches the filename stem
    # look for a line like `ref: SWD-001` (allow quotes, spacing and indentation)
    ref_val = None
    for raw_ln in text.splitlines():
        rm = re.match(r'^\s*ref:\s*["\']?([A-Za-z0-9_\-]+)["\']?\s*$', raw_ln)
        if rm:
            ref_val = rm.group(1)
            break
    if ref_val is not None:
        if ref_val != filename_stem:
            issues.append(f'`ref:` value `{ref_val}` does not match filename `{filename_stem}`')
    else:
        # already will be reported as missing expected key, but add clarity
        if 'ref:' in text:
            issues.append('could not parse `ref:` value')

    # reviewers: require at least one reviewer with name and email (simple line-based check)
    if 'reviewers:' in text:
        # find the block starting at reviewers:
        idx = None
        for i, raw in enumerate(text.splitlines()):
            if raw.strip().startswith('reviewers:'):
                idx = i
                break
        if idx is None:
            issues.append('reviewers: declared but could not locate block')
        else:
            # scan following lines until next top-level (no indent) or EOF
            found_item = False
            found_name = False
            for following in text.splitlines()[idx + 1:]:
                if not following.strip():
                    continue
                # stop if line looks like a new top-level key (no indent)
                if following and not following.startswith((' ', '\t', '-')):
                    break
                if following.lstrip().startswith('-'):
                    found_item = True
                if 'name:' in following:
                    found_name = True
            if not found_item:
                issues.append('`reviewers:` present but no list items found (expect `- name:` entries)')
            if not found_name:
                issues.append('no `name:` found under `reviewers:` entries')

    if verbose:
        print(f"Checking {path} -> {len(issues)} issue(s)")

    return issues


def main(argv):
    if len(argv) < 2:
        print('Usage: reqs_lint.py <reqs_dir> [--verbose]')
        return 2

    reqs_dir = Path(argv[1])
    verbose = '--verbose' in argv or '-v' in argv

    if not reqs_dir.exists():
        print('Path not found:', reqs_dir)
        return 2

    # find YAML files but skip Doorstop config files (named .doorstop.yml)
    files = [p for p in reqs_dir.rglob('*.yml') if p.name != '.doorstop.yml'] + \
            [p for p in reqs_dir.rglob('*.yaml') if p.name != '.doorstop.yml']
    if not files:
        print('No YAML files found under', reqs_dir)
        return 0

    total_issues = 0
    checked_files = 0
    for p in sorted(files):
        checked_files += 1
        issues = check_file(p, verbose=verbose)
        if issues:
            total_issues += len(issues)
            print(f'-- {p}:')
            for it in issues:
                print('   -', it)

    if total_issues == 0:
        print('OK: no issues found')
        return 0
    else:
        print(f'Found {total_issues} issue(s) in {checked_files} file(s)')
        return 1


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
