#!/usr/bin/env python3
"""Baseline requirements helper

Usage:
  scripts/baseline_reqs.py [--apply] [--tag v1.0.0-baseline] [reqs_dir]

By default runs in dry-run mode and prints which files would be stamped. With
`--apply` it will set `reviewed:` to the current HEAD SHA for unstamped files,
commit them and optionally create a tag.

This is a convenience helper and should be reviewed before use. It does not
attempt to run trudag; use trudag manually if you have Doorstop configured.
"""
import sys
from pathlib import Path
import argparse
import re
import subprocess


def find_req_files(reqs_dir: Path):
    return sorted([p for p in reqs_dir.rglob('*.yml') if 'templates' not in p.parts and p.name != '.doorstop.yml'])


def read_reviewed(path: Path):
    text = path.read_text(encoding='utf-8')
    m = re.search(r'^\s*reviewed\s*:\s*["\']?([A-Za-z0-9_\-]*)["\']?\s*$', text, flags=re.MULTILINE)
    if m:
        return m.group(1)
    return None


def set_reviewed(path: Path, sha: str):
    text = path.read_text(encoding='utf-8')
    if re.search(r'^\s*reviewed\s*:', text, flags=re.MULTILINE):
        new_text = re.sub(r'(^\s*reviewed\s*:\s*)(["\']?[A-Za-z0-9_\-]*["\']?)', rf"\1'{sha}'", text, flags=re.MULTILINE)
    else:
        # naive append to end
        new_text = text + f"\nreviewed: '{sha}'\n"
    path.write_text(new_text, encoding='utf-8')


def git_head_sha():
    r = subprocess.run(['git', 'rev-parse', 'HEAD'], capture_output=True, text=True)
    if r.returncode != 0:
        raise RuntimeError('git rev-parse failed')
    return r.stdout.strip()


def git_commit(files, message):
    subprocess.check_call(['git', 'add'] + files)
    subprocess.check_call(['git', 'commit', '-m', message])


def git_tag(tag):
    subprocess.check_call(['git', 'tag', '-a', tag, '-m', f'Baseline {tag}'])
    subprocess.check_call(['git', 'push', 'origin', tag])


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument('reqs_dir', nargs='?', default='reqs')
    parser.add_argument('--apply', action='store_true', help='Apply changes: write reviewed and commit')
    parser.add_argument('--tag', help='Create a baseline tag after applying (e.g., v1.0.0-baseline)')
    args = parser.parse_args(argv[1:])

    reqs_dir = Path(args.reqs_dir)
    if not reqs_dir.exists():
        print('reqs dir not found:', reqs_dir)
        return 2

    files = find_req_files(reqs_dir)
    head = None
    if args.apply:
        head = git_head_sha()

    to_stamp = []
    for f in files:
        rev = read_reviewed(f)
        if not rev or rev.strip() == "''" or rev.strip() == 'null':
            to_stamp.append(f)

    if not to_stamp:
        print('No unstamped requirement files found.')
        return 0

    print(f'Found {len(to_stamp)} unstamped files:')
    for f in to_stamp:
        print(' -', f)

    if not args.apply:
        print('\nDry-run complete. Re-run with --apply to stamp these files with HEAD SHA.')
        return 0

    # apply changes
    for f in to_stamp:
        set_reviewed(f, head)

    git_commit([str(p) for p in to_stamp], f'baseline: stamp {len(to_stamp)} requirements as reviewed {head[:7]}')
    print('Committed reviewed stamps.')

    if args.tag:
        git_tag(args.tag)
        print('Tagged baseline:', args.tag)

    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
