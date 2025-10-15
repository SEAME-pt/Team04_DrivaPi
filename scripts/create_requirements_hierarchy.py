#!/usr/bin/env python3
"""
Interactive helper to create a requirements hierarchy using doorstop.

Creates URD -> SRD -> SWD -> LLTC items (one chain at a time), prompts the user
for required fields, writes those fields into the doorstop-created item YAML file,
and links child -> parent using `doorstop link`.

Usage:
  ./scripts/create_requirements_hierarchy.py        # interactive
  ./scripts/create_requirements_hierarchy.py --auto # create a test chain with example values

"""
import argparse
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path
try:
    import yaml
    HAS_PYYAML = True
except Exception:
    HAS_PYYAML = False


TEMPLATES = {
    'URD': 'reqs/urd/URD-template.yml',
    'SRD': 'reqs/srd/SRD-template.yml',
    'SWD': 'reqs/swd/SWD-template.yml',
    'LLTC': 'reqs/lltc/LLTC-template.yml',
}


def run(cmd):
    p = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return p.returncode, p.stdout


def find_created_file_from_output(output):
    # doorstop prints lines like: added item: SWD002 (@/reqs/swd/SWD002.yml)
    m = re.search(r"added item:\s*(\S+)\s*\(@([^\)]+)\)", output)
    if m:
        uid = m.group(1)
        path = m.group(2).lstrip('@')
        return uid, path
    return None, None


def normalize_path(path):
    path = path.lstrip('@')
    p = Path(path)
    if p.is_absolute():
        # try to make repo-relative by finding 'reqs' element
        try:
            idx = p.parts.index('reqs')
            p = Path(*p.parts[idx:])
        except ValueError:
            p = Path('/').joinpath(*p.parts).relative_to('/')
    return Path(os.path.normpath(str(p)))


def write_item_file(path: Path, fields: dict):
    # Build YAML text from fields dictionary; keep ordering similar to templates
    lines = []
    # Basic scalar fields
    for key in ('active', 'derived', 'header', 'level'):
        if key in fields:
            val = fields[key]
            # Normalize booleans to lowercase YAML booleans
            if isinstance(val, bool):
                val = 'true' if val else 'false'
            # Header may contain a colon (UID: title) which must be quoted in YAML
            if key == 'header':
                # escape any double-quotes inside the header
                safe = str(val).replace('"', '\\"')
                lines.append(f'header: "{safe}"')
            else:
                lines.append(f"{key}: {val}")
    # links (map entries with null)
    links = fields.get('links', [])
    lines.append('links:')
    if links:
        for l in links:
            lines.append(f"  - {l}: null")
    else:
        lines.append('  []')
    # other scalar fields
    for key in ('normative', 'ref', 'reviewed'):
        if key in fields:
            val = fields[key]
            # normalize booleans
            if isinstance(val, bool):
                val = 'true' if val else 'false'
            # ensure empty strings are explicit
            if val is None or (isinstance(val, str) and val == ''):
                val = "''"
            # quote string values containing colon or leading/trailing spaces
            if isinstance(val, str) and (':' in val or val.strip() != val):
                val = '"' + val.replace('"', '\\"') + '"'
            lines.append(f"{key}: {val}")
    # text
    text = fields.get('text', '')
    lines.append('text: |')
    for tline in text.splitlines() or ['']:
        lines.append('  ' + tline)
    # trailing fields
    for key in ('status', 'ASIL', 'Verification Method'):
        if key in fields:
            lines.append(f"{key}: {fields[key]}")

    content = '\n'.join(lines) + '\n'
    path.write_text(content)
    # Prefer PyYAML if available for robust YAML generation
    if HAS_PYYAML:
        # Build ordered mapping similar to templates
        out = {}
        for k in ('active', 'derived', 'header', 'level'):
            if k in fields:
                out[k] = fields[k]
        # links as list of single-key mappings
        links = fields.get('links', [])
        if links:
            out['links'] = [{l: None} for l in links]
        else:
            out['links'] = []
        for k in ('normative', 'ref', 'reviewed'):
            if k in fields:
                out[k] = fields[k]
        out['text'] = fields.get('text', '')
        for k in ('status', 'ASIL', 'Verification Method'):
            if k in fields:
                out[k] = fields[k]

        # Use safe_dump with default_flow_style=False for block style
        content = yaml.safe_dump(out, sort_keys=False, default_flow_style=False)
        path.write_text(content)
        return

    # Fallback: simple writer (kept for environments without PyYAML)
    lines = []
    # Basic scalar fields
    for key in ('active', 'derived', 'header', 'level'):
        if key in fields:
            val = fields[key]
            if isinstance(val, bool):
                val = 'true' if val else 'false'
            if key == 'header':
                safe = str(val).replace('"', '\\"')
                lines.append(f'header: "{safe}"')
            else:
                lines.append(f"{key}: {val}")
    # links
    links = fields.get('links', [])
    lines.append('links:')
    if links:
        for l in links:
            lines.append(f"  - {l}: null")
    else:
        lines.append('  []')
    # other scalar fields
    for key in ('normative', 'ref', 'reviewed'):
        if key in fields:
            val = fields[key]
            if isinstance(val, bool):
                val = 'true' if val else 'false'
            if val is None or (isinstance(val, str) and val == ''):
                val = "''"
            if isinstance(val, str) and (':' in val or val.strip() != val):
                val = '"' + val.replace('"', '\\"') + '"'
            lines.append(f"{key}: {val}")
    # text
    text = fields.get('text', '')
    lines.append('text: |')
    for tline in text.splitlines() or ['']:
        lines.append('  ' + tline)
    # trailing fields
    for key in ('status', 'ASIL', 'Verification Method'):
        if key in fields:
            lines.append(f"{key}: {fields[key]}")

    content = '\n'.join(lines) + '\n'
    path.write_text(content)


def prompt_field(prompt, default=None):
    if default is not None:
        resp = input(f"{prompt} [{default}]: ")
        return resp.strip() or default
    else:
        return input(f"{prompt}: ").strip()


def prompt_multiline(prompt, default=''):
    print(f"{prompt} (finish with a single line containing only 'END')")
    if default:
        print(f"(default text shown — press ENTER to keep)")
        print(default)
    lines = []
    while True:
        line = input()
        if line.strip() == 'END':
            break
        lines.append(line)
    if not lines and default:
        return default
    return '\n'.join(lines)


def create_item(prefix, fields):
    # run doorstop add
    rc, out = run(f'doorstop add {prefix}')
    if rc != 0:
        print('doorstop add failed:')
        print(out)
        sys.exit(rc)
    uid, path = find_created_file_from_output(out)
    if not uid or not path:
        # fallback: find newest file
        dirpath = Path('reqs') / prefix.lower()
        files = sorted(dirpath.glob(f'{prefix}*.yml'), key=lambda f: f.stat().st_mtime, reverse=True)
        if not files:
            print('Failed to locate created item file', file=sys.stderr)
            sys.exit(3)
        p = files[0]
        uid = p.stem
        path = str(p)

    p = normalize_path(path)
    p.parent.mkdir(parents=True, exist_ok=True)

    # ensure header contains UID
    hdr = fields.get('header', '')
    if not hdr.startswith(uid + ':'):
        fields['header'] = f"{uid}: {hdr}"

    write_item_file(p, fields)
    print(f'Created {p} (UID={uid})')
    return uid, p


def link(child_uid, parent_uid):
    rc, out = run(f'doorstop link {child_uid} {parent_uid}')
    if rc != 0:
        print('doorstop link failed:')
        print(out)
        return False
    print(f'Linked {child_uid} -> {parent_uid}')
    return True


def build_fields_interactive(level, defaults=None):
    defaults = defaults or {}
    print(f'--- Filling fields for {level} ---')
    header = prompt_field('Header', defaults.get('header', f'{level}: <short title>'))
    active = prompt_field('Active (y/n)', defaults.get('active', 'y')) in ('y', 'Y', 'yes')
    derived = prompt_field('Derived (y/n)', defaults.get('derived', 'n')) in ('y', 'Y', 'yes')
    level_num = prompt_field('Level (e.g. 1.0)', defaults.get('level', '1.0'))
    links = prompt_field('Links (comma-separated UIDs)', defaults.get('links', ''))
    # defaults may provide links as a list; accept both list and comma-separated string
    if isinstance(links, list):
        links_list = links
    else:
        links_list = [l.strip() for l in str(links).split(',') if l.strip()]
    normative = prompt_field('Normative (true/false)', defaults.get('normative', 'true'))
    ref = prompt_field('Reference', defaults.get('ref', "''"))
    reviewed = prompt_field('Reviewed', defaults.get('reviewed', "''"))
    text = prompt_multiline('Text', defaults.get('text', ''))
    status = prompt_field('Status', defaults.get('status', 'Draft'))
    asil = prompt_field('ASIL', defaults.get('ASIL', 'C'))
    verification = prompt_field('Verification Method', defaults.get('Verification Method', 'Unit Test'))

    fields = {
        'header': header,
        'active': active,
        'derived': derived,
        'level': level_num,
        'links': links_list,
        'normative': normative,
        'ref': ref,
        'reviewed': reviewed,
        'text': text,
        'status': status,
        'ASIL': asil,
        'Verification Method': verification,
    }
    return fields


def build_fields_from_defaults(level, defaults=None):
    defaults = defaults or {}
    header = defaults.get('header', f'{level}: <title>')
    active = defaults.get('active', True)
    derived = defaults.get('derived', False)
    level_num = defaults.get('level', '1.0')
    links = defaults.get('links', [])
    if isinstance(links, str):
        links = [l.strip() for l in links.split(',') if l.strip()]
    normative = defaults.get('normative', True)
    ref = defaults.get('ref', "''")
    reviewed = defaults.get('reviewed', "''")
    text = defaults.get('text', '')
    status = defaults.get('status', 'Draft')
    asil = defaults.get('ASIL', 'C')
    verification = defaults.get('Verification Method', 'Unit Test')

    return {
        'header': header,
        'active': active,
        'derived': derived,
        'level': level_num,
        'links': links,
        'normative': normative,
        'ref': ref,
        'reviewed': reviewed,
        'text': text,
        'status': status,
        'ASIL': asil,
        'Verification Method': verification,
    }


def cleanup_bad_generated_files():
    """Rename any previously generated *000.yml files to *.bad.yml to avoid doorstop validation errors.

    This is a conservative cleanup used in --auto mode when earlier runs produced malformed files.
    """
    base = Path('reqs')
    if not base.exists():
        return
    for doc in base.iterdir():
        if doc.is_dir():
            for f in doc.glob('*000.yml'):
                bad = f.with_suffix(f.suffix + '.bad')
                try:
                    f.rename(bad)
                    print(f'Renamed {f} -> {bad}')
                except Exception:
                    print(f'Failed to rename {f}, please remove or fix it manually.')


def move_bad_to_backups():
    base = Path('reqs')
    bak = base / 'backups'
    bak.mkdir(parents=True, exist_ok=True)
    for doc in base.iterdir():
        if doc.is_dir():
            for f in doc.glob('*.bad'):
                dest = bak / f.name
                try:
                    f.rename(dest)
                    print(f'Moved {f} -> {dest}')
                except Exception:
                    print(f'Failed to move {f} to backups; please move manually.')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--auto', action='store_true', help='run non-interactive with example values')
    args = ap.parse_args()

    if args.auto:
        # remove/rename any earlier malformed outputs created by previous runs
        cleanup_bad_generated_files()
        urd_defaults = {
            'header': 'Top-level wheel speed requirement',
            'text': 'The system SHALL provide wheel speed measurements with sufficient accuracy to support vehicle control and telemetry features.',
            'links': []
        }
        srd_defaults = {
            'header': 'Subsystem acquisition of speed',
            'text': 'The sensor acquisition subsystem SHALL aggregate Hall sensor readings and provide filtered speed values to the control software.',
            # leave links empty here; we'll create explicit doorstop links after items are created
            'links': []
        }
        swd_defaults = {
            'header': 'ThreadX sensor reading module',
            'text': 'The speed sensor driver module (ThreadX RTOS) SHALL compute wheel speed from the Hall sensor pulses and publish the result on the CAN bus within 10 ms.',
            'links': []
        }
        lltc_defaults = {
            'header': 'Unit test for Hall driver',
            'text': 'Unit test to verify that the Hall sensor driver computes speed correctly for a set of simulated pulse inputs.',
            'links': []
        }

        urd_uid, urd_path = create_item('URD', build_fields_from_defaults('URD', urd_defaults))
        srd_uid, srd_path = create_item('SRD', build_fields_from_defaults('SRD', srd_defaults))
        swd_uid, swd_path = create_item('SWD', build_fields_from_defaults('SWD', swd_defaults))
        lltc_uid, lltc_path = create_item('LLTC', build_fields_from_defaults('LLTC', lltc_defaults))

    # Link chain: SRD -> URD, SWD -> SRD, LLTC -> SWD
        link(srd_uid, urd_uid)
        link(swd_uid, srd_uid)
        link(lltc_uid, swd_uid)
    else:
        print('Interactive mode: you will be prompted for URD, SRD, SWD and LLTC fields.')
        urd_fields = build_fields_interactive('URD')
        urd_uid, urd_path = create_item('URD', urd_fields)

        srd_fields = build_fields_interactive('SRD')
        srd_uid, srd_path = create_item('SRD', srd_fields)

        swd_fields = build_fields_interactive('SWD')
        swd_uid, swd_path = create_item('SWD', swd_fields)

        lltc_fields = build_fields_interactive('LLTC')
        lltc_uid, lltc_path = create_item('LLTC', lltc_fields)

        # Link children to parents
        link(srd_uid, urd_uid)
        link(swd_uid, srd_uid)
        link(lltc_uid, swd_uid)


if __name__ == '__main__':
    main()
