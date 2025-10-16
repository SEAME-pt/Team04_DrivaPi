#!/usr/bin/env python3
"""Simple traceability checker.

Scans a requirements tree under `reqs/` for YAML files and extracts `links:` entries.
Produces a CSV matrix at `artifacts/traceability-matrix.csv` with columns: req_id,target_id,link_type,source_file

Usage: python3 scripts/traceability_check.py <reqs_dir> [--output artifacts/traceability-matrix.csv] [--fail-on-unlinked]

This script is intentionally dependency-free and performs tolerant YAML parsing using simple line-based heuristics.
"""
import sys
from pathlib import Path
import re
import csv


def parse_req_file(path: Path):
    """Return (req_id, links_list).

    links_list is a list of tuples (target_id, link_type) where link_type is the YAML key used (e.g. 'links').
    """
    text = path.read_text(encoding='utf-8')
    # find top-level ID (first non-empty line like SWD-001:)
    req_id = None
    for ln in text.splitlines():
        s = ln.strip()
        if not s:
            continue
        m = re.match(r'^([A-Za-z0-9_\-]+):\s*$', s)
        if m:
            req_id = m.group(1)
        break

    if not req_id:
        # fall back to filename stem
        req_id = path.stem

    links = []

    # naive scan for `links:` blocks or inline `links:` entries
    lines = text.splitlines()
    for i, ln in enumerate(lines):
        if re.match(r'^\s*links:\s*$', ln):
            # read following indented list items
            for following in lines[i+1:]:
                if not following.strip():
                    continue
                # stop at next top-level key (no indent)
                if following and not following.startswith((' ', '\t', '-')):
                    break
                # capture lines like `- SRD-001` or `- id: SRD-001` or `- ref: SRD-001`
                m2 = re.search(r'([A-Za-z0-9_\-]+)', following)
                if m2:
                    links.append((m2.group(1), 'links'))
        else:
            # inline single-line `links: [SRD-001, SRD-002]` or `links: SRD-001`
            m_inline = re.search(r'\blink[s]?\s*:\s*\[?\s*([A-Za-z0-9_\-,\s]+)\]?\s*$', ln)
            if m_inline:
                ids = re.split(r'[\s,]+', m_inline.group(1).strip())
                for iid in ids:
                    if iid:
                        iid_clean = iid.strip().strip('[],')
                        links.append((iid_clean, 'links'))

    # also look for `satisfied-by:` or `ref:` style relations (common patterns)
    for raw in lines:
        m_ref = re.match(r'^\s*(?:ref|satisfied-by|satisfies)\s*:\s*["\']?([A-Za-z0-9_\-]+)["\']?\s*$', raw)
        if m_ref:
            links.append((m_ref.group(1), raw.split(':', 1)[0].strip()))

    return req_id, links


def find_all_reqs(reqs_dir: Path, include_templates: bool = False):
    files = sorted([p for p in reqs_dir.rglob('*.yml') if p.name != '.doorstop.yml'] +
                   [p for p in reqs_dir.rglob('*.yaml') if p.name != '.doorstop.yml'])
    if not include_templates:
        files = [p for p in files if 'templates' not in p.parts]
    return files


def main(argv):
    if len(argv) < 2:
        print('Usage: traceability_check.py <reqs_dir> [--output path] [--fail-on-unlinked]')
        return 2

    reqs_dir = Path(argv[1])
    out_path = Path('artifacts/traceability-matrix.csv')
    report_md = Path('artifacts/traceability-report.md')
    fail_on_unlinked = False
    include_templates = False
    by_category = False
    if '--output' in argv:
        try:
            out_path = Path(argv[argv.index('--output') + 1])
        except IndexError:
            print('Provide a path after --output')
            return 2
    if '--fail-on-unlinked' in argv:
        fail_on_unlinked = True
    if '--include-templates' in argv:
        include_templates = True
    if '--by-category' in argv:
        by_category = True

    if not reqs_dir.exists():
        print('Path not found:', reqs_dir)
        return 2

    files = find_all_reqs(reqs_dir, include_templates=include_templates)
    if not files:
        print('No YAML files found under', reqs_dir)
        return 0

    records = []
    req_ids = set()
    links_found = 0
    # map category (top-level folder under reqs_dir) -> records list
    category_map = {}

    for f in files:
        rid, links = parse_req_file(f)
        req_ids.add(rid)
        if links:
            for target, ltype in links:
                rec = {'req_id': rid, 'target_id': target, 'link_type': ltype, 'source_file': str(f)}
                records.append(rec)
                # determine category by locating folder directly under reqs_dir
                try:
                    rel = f.relative_to(reqs_dir)
                    parts = rel.parts
                    category = parts[0] if parts else 'root'
                except Exception:
                    category = 'root'
                category_map.setdefault(category, []).append(rec)
                links_found += 1

    # Ensure artifact dir exists
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with out_path.open('w', newline='', encoding='utf-8') as csvf:
        writer = csv.DictWriter(csvf, fieldnames=['req_id', 'target_id', 'link_type', 'source_file'])
        writer.writeheader()
        for r in records:
            writer.writerow(r)

    # optionally write per-category matrices
    if by_category:
        for cat, recs in category_map.items():
            cat_path = out_path.parent / f'traceability-matrix-{cat}.csv'
            with cat_path.open('w', newline='', encoding='utf-8') as cf:
                w = csv.DictWriter(cf, fieldnames=['req_id', 'target_id', 'link_type', 'source_file'])
                w.writeheader()
                for r in recs:
                    w.writerow(r)
        print(f'per-category matrices written for {len(category_map)} categories')

    print(f'Found {len(files)} requirements files; {links_found} links extracted; matrix written to {out_path}')

    # generate a human-friendly markdown report
    target_ids = {r['target_id'] for r in records}
    source_ids = {r['req_id'] for r in records}
    all_req_ids = set()
    for f in files:
        # prefer top-level ID if available else filename stem
        rid, _ = parse_req_file(f)
        all_req_ids.add(rid)

    # broken links: targets that do not exist in all_req_ids
    broken = sorted([t for t in target_ids if t not in all_req_ids])

    # orphans: requirements that neither link to others nor are linked-to
    orphaned = sorted([r for r in sorted(all_req_ids) if r not in source_ids and r not in target_ids])

    with report_md.open('w', encoding='utf-8') as md:
        md.write('# Traceability report\n\n')
        md.write(f'- scanned files: {len(files)}\n')
        md.write(f'- links extracted: {links_found}\n')
        md.write('\n## Broken links\n\n')
        if not broken:
            md.write('No broken targets detected.\n')
        else:
            for b in broken:
                md.write(f'- {b}\n')
        md.write('\n## Orphaned requirements\n\n')
        if not orphaned:
            md.write('No orphaned requirements detected.\n')
        else:
            for o in orphaned:
                md.write(f'- {o}\n')

        if by_category:
            md.write('\n## Per-category summary\n\n')
            for cat in sorted(category_map.keys()):
                md.write(f'- {cat}: {len(category_map.get(cat, []))} links\n')

    print(f'markdown report written to {report_md}')

    if fail_on_unlinked and (broken or orphaned):
        print('Failing due to --fail-on-unlinked: found broken links or orphaned requirements')
        return 3

    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
