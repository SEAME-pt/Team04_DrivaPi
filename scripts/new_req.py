#!/usr/bin/env python3
"""Create a new requirement file from a template.

Usage: python3 scripts/new_req.py <category> <ID>
Example: python3 scripts/new_req.py swd SWD-002
"""
import sys
from pathlib import Path

TEMPLATES_DIR = Path(__file__).resolve().parents[1] / 'reqs' / 'templates'
REQS_DIR = Path(__file__).resolve().parents[1] / 'reqs'


def main(argv):
    if len(argv) != 3:
        print('Usage: new_req.py <category> <ID>')
        return 2
    category = argv[1]
    rid = argv[2]
    tpl_map = {
        'urd': 'URD-template.yml',
        'srd': 'SRD-template.yml',
        'swd': 'SWD-template.yml',
        'lltc': 'LLTC-template.yml',
    }
    tpl = tpl_map.get(category.lower())
    if not tpl:
        print('Unknown category. Use one of:', ', '.join(tpl_map.keys()))
        return 2
    src = TEMPLATES_DIR / tpl
    if not src.exists():
        print('Template not found:', src)
        return 2
    dst_dir = REQS_DIR / category.lower()
    dst_dir.mkdir(parents=True, exist_ok=True)
    dst = dst_dir / f'{rid}.yml'
    if dst.exists():
        print('File already exists:', dst)
        return 2
    text = src.read_text(encoding='utf-8')
    # extract the template's top-level ID (first non-empty line like 'SWD-000:')
    import re
    tpl_lines = [l.rstrip('\n') for l in text.splitlines() if l.strip()]
    tpl_id = None
    if tpl_lines:
        m = re.match(r'^([A-Za-z0-9_\-]+):', tpl_lines[0])
        if m:
            tpl_id = m.group(1)
    if tpl_id:
        text = text.replace(tpl_id, rid)
        # replace ref: <tpl_id> occurrences more precisely
        text = re.sub(r'(ref:\s*["\']?)' + re.escape(tpl_id) + r'(["\']?)', r"\1" + rid + r"\2", text)
    else:
        # fallback: naive replace of common placeholder
        text = text.replace('000', rid.split('-')[-1])
    dst.write_text(text, encoding='utf-8')
    print('Created', dst)
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
