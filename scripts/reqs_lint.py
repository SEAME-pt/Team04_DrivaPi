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
import re


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
        print('Usage: reqs_lint.py <reqs_dir> [--verbose] [--ignore-templates]')
        return 2

    reqs_dir = Path(argv[1])
    verbose = '--verbose' in argv or '-v' in argv
    ignore_templates = '--ignore-templates' in argv
    check_links = '--check-links' in argv

    if not reqs_dir.exists():
        print('Path not found:', reqs_dir)
        return 2

    # find YAML files but skip Doorstop config files (named .doorstop.yml)
    files = [p for p in reqs_dir.rglob('*.yml') if p.name != '.doorstop.yml'] + \
            [p for p in reqs_dir.rglob('*.yaml') if p.name != '.doorstop.yml']
    if ignore_templates:
        files = [p for p in files if 'templates' not in p.parts]
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

    # optional link checking: gather IDs and verify links
    if check_links:
        # gather all defined IDs
        ids = set()
        id_re = re.compile(r'^([A-Za-z0-9_\-]+):\s*$')
        for p in files:
            for ln in p.read_text(encoding='utf-8').splitlines():
                m = id_re.match(ln.strip())
                if m:
                    ids.add(m.group(1))

        # scan files for links: entries
        broken = []
        link_re = re.compile(r'\blinks\s*:\s*\[?\s*([A-Za-z0-9_\-,\s]+)\]?')
        # match list items that are a single ID on the line (optionally quoted)
        # This avoids matching reviewer entries like '- name: "..."'
        list_item_re = re.compile(r'^\s*-\s*["\']?([A-Za-z0-9_\-]+)["\']?\s*$')
        for p in files:
            text = p.read_text(encoding='utf-8')
            # inline list
            for m in link_re.finditer(text):
                for iid in re.split(r'[\s,]+', m.group(1).strip()):
                    iid = iid.strip().strip('[],')
                    if iid and iid not in ids:
                        broken.append((p, iid))
            # block list
            lines = text.splitlines()
            for i, ln in enumerate(lines):
                if ln.strip().startswith('links:'):
                    for following in lines[i+1:]:
                        if not following.strip():
                            continue
                        if following and not following.startswith((' ', '\t', '-')):
                            break
                        m2 = list_item_re.match(following)
                        if m2:
                            iid = m2.group(1)
                            if iid not in ids:
                                broken.append((p, iid))

        if broken:
            print('\nBroken link(s) found:')
            for p, iid in broken:
                print(f' - {p}: references unknown ID `{iid}`')
            total_issues += len(broken)

    if total_issues == 0:
        print('OK: no issues found')
        return 0
    else:
        print(f'Found {total_issues} issue(s) in {checked_files} file(s)')
        return 1


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
