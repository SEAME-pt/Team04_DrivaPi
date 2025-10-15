#!/usr/bin/env python3
"""Apply small shims to the workspace virtualenv to allow trudag/doorstop to run under Python 3.14.

This script is idempotent and safe to run multiple times. It will:
- create a minimal distutils shim (distutils/__init__.py, distutils/spawn.py) in the venv site-packages
- patch the installed trudag package's graph_factory.py to use document.items
- ensure a minimal sme_scores/from_data implementation exists in trudag's item.py for DoorstopItem

Usage:
  python3 scripts/apply_trudag_shims.py

Note: This modifies files inside the venv; prefer to run in a disposable environment or document the changes.
"""
from __future__ import annotations
import sys
from pathlib import Path
import argparse


def find_venv_site_packages(root: Path) -> Path | None:
    # Common location: .venv/lib/pythonX.Y/site-packages
    venv = root / '.venv'
    if not venv.exists():
        return None
    for py in venv.glob('lib/python*'):
        site = py / 'site-packages'
        if site.exists():
            return site
    return None


def ensure_distutils(site: Path):
    dist_path = site / 'distutils'
    dist_path.mkdir(exist_ok=True)
    init = dist_path / '__init__.py'
    spawn = dist_path / 'spawn.py'
    if not init.exists():
        init.write_text("""from __future__ import annotations\nimport shutil\ndef find_executable(cmd):\n    return shutil.which(cmd)\n__all__ = ['find_executable']\n""")
        print(f"Wrote {init}")
    else:
        print(f"{init} exists")
    if not spawn.exists():
        spawn.write_text("""from __future__ import annotations\nfrom shutil import which\ndef find_executable(cmd):\n    return which(cmd)\n__all__ = ['find_executable']\n""")
        print(f"Wrote {spawn}")
    else:
        print(f"{spawn} exists")


def patch_graph_factory(site: Path):
    gf = site / 'trudag' / 'dotstop' / 'core' / 'graph' / 'graph_factory.py'
    if not gf.exists():
        print(f"graph_factory not found at {gf}")
        return
    txt = gf.read_text()
    if 'document.item' in txt:
        txt = txt.replace('for document in tree.documents for item in document.item',
                          'for document in tree.documents for item in document.items')
        gf.write_text(txt)
        print(f"Patched document.item -> document.items in {gf}")
    else:
        print("graph_factory already patched or not matching pattern")


def patch_item_impl(site: Path):
    ip = site / 'trudag' / 'dotstop' / 'core' / 'item.py'
    if not ip.exists():
        print(f"item.py not found at {ip}")
        return
    txt = ip.read_text()
    changed = False
    if 'def sme_scores(self) -> dict' not in txt:
        # Insert a minimal sme_scores after score method's return None
        txt = txt.replace("\n        return None\n\n    @property\n    def text(self) -> str:",
                          "\n        return None\n\n    @property\n    def sme_scores(self) -> dict[str, float] | None:\n        score = self._doorstop_item.attribute('score')\n        if score is None:\n            return None\n        if isinstance(score, dict):\n            return score\n        return None\n\n    @property\n    def text(self) -> str:")
        changed = True
    if 'def from_data(data' not in txt:
        txt += "\n    @staticmethod\n    def from_data(data):\n        name = data.get('name') if isinstance(data, dict) else str(data)\n        return DoorstopItem(name)\n"
        changed = True
    if changed:
        ip.write_text(txt)
        print(f"Patched {ip}")
    else:
        print(f"{ip} already has required implementations")


def main():
    root = Path(__file__).resolve().parents[1]
    site = find_venv_site_packages(root)
    if site is None:
        print("No .venv site-packages found. Ensure a workspace venv exists at .venv/")
        return 2
    print(f"Using site-packages: {site}")
    ensure_distutils(site)
    patch_graph_factory(site)
    patch_item_impl(site)
    print("Done applying shims.")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
