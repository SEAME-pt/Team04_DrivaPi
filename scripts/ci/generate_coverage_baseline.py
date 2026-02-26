#!/usr/bin/env python3
"""Generate a version-controlled coverage baseline (baseline.json).

Policy:
- Project scope: ASIL A + QM
- Baseline is committed under tests/verification/coverage/baseline.json
- Evidence XML is generated under artifacts/verification/coverage/*.xml
"""

import argparse
import json
import os
import xml.etree.ElementTree as ET
from datetime import datetime, timezone


def read_rates(path: str):
    tree = ET.parse(path)
    root = tree.getroot()
    lr = root.attrib.get("line-rate") or root.attrib.get("lineRate")
    br = root.attrib.get("branch-rate") or root.attrib.get("branchRate")
    if lr is None:
        raise ValueError(f"Missing line-rate in XML: {path}")
    line_rate = float(lr)
    branch_rate = float(br) if br is not None else None
    branch_available = br is not None
    return line_rate, branch_rate, branch_available


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate coverage baseline JSON from Cobertura XML files.")
    parser.add_argument("--evidence-dir", default="artifacts/verification/coverage",
                        help="Directory containing generated per-suite XML coverage evidence.")
    parser.add_argument("--suites", nargs="+", default=["dc-motor", "servo-motor", "speed-sensor"])
    parser.add_argument("--sha", default=None)
    parser.add_argument("--out", default=None,
                        help="Output baseline.json path (defaults to tests/verification/coverage/baseline.json).")
    args = parser.parse_args()

    sha = args.sha or os.environ.get("GITHUB_SHA") or "unknown"
    out_path = args.out or os.path.join("tests", "verification", "coverage", "baseline.json")
    os.makedirs(os.path.dirname(out_path), exist_ok=True)

    data = {
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "commit_sha": sha,
        "suites": {},
    }

    missing = []
    for suite in args.suites:
        xml_path = os.path.join(args.evidence_dir, f"{suite}.xml")
        if not os.path.exists(xml_path):
            missing.append(xml_path)
            continue
        lr, br, br_avail = read_rates(xml_path)
        data["suites"][suite] = {
            "line-rate": lr,
            "branch-rate": br,
            "branch-rate-available": br_avail,
        }

    if missing:
        print("::error::Missing coverage XML files:\n  - " + "\n  - ".join(missing))
        return 1

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")

    print(f"Baseline written: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
