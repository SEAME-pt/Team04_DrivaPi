#!/usr/bin/env python3
"""
Hardened LLTC coverage change validator.

This script wraps the dotstop LLTC coverage change validator with additional
defensive checks to meet ISO 26262 and ISO 21434 expectations.

Key policy for this repository:
- Project scope: ASIL A + QM
- CI gate: >= 90% line coverage per suite (dc-motor, servo-motor, speed-sensor)
- Coverage regressions vs the version-controlled baseline require an explicit approval
    by modifying the baseline file, rather than lowering the global threshold.

IMPORTANT:
- Baseline is version-controlled in tests/verification/coverage/
- Generated coverage XML evidence is produced under artifacts/verification/coverage/

Usage:
        python3 validate_lltc_coverage.py \
                --base-dir artifacts/verification/coverage \
                --suites dc-motor servo-motor speed-sensor \
                --baseline tests/verification/coverage/baseline.json \
                --min-line-rate 90.0
"""

import argparse
import json
import os
import sys
from typing import List, Tuple


def load_json(path: str) -> dict:
    """Load a JSON file safely (fail-closed)."""
    if not path:
        print("::error::No JSON path provided.")
        sys.exit(1)
    if not os.path.exists(path):
        print(f"::error::Required JSON file not found: {path}")
        sys.exit(1)
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception as e:
        print(f"::error::Failed to parse JSON file {path}: {e}")
        sys.exit(1)
    return data


def validate_baseline_structure(baseline: dict, suites: List[str]) -> None:
    """Validate baseline JSON structure and rate ranges (0..1 inclusive)."""
    if not isinstance(baseline, dict):
        print("::error::Baseline JSON must be an object.")
        sys.exit(1)
    suites_data = baseline.get("suites")
    if not isinstance(suites_data, dict):
        print("::error::Baseline JSON missing required 'suites' section.")
        sys.exit(1)

    for suite in suites:
        entry = suites_data.get(suite)
        if not isinstance(entry, dict):
            print(f"::error::Baseline JSON missing entry for suite '{suite}'.")
            sys.exit(1)

        line_key = "line-rate" if "line-rate" in entry else "line_rate"
        branch_key = "branch-rate" if "branch-rate" in entry else "branch_rate"

        for key, val in [("line", entry.get(line_key)), ("branch", entry.get(branch_key))]:
            if val is None:
                print(f"::error::Baseline JSON missing {key} rate for suite '{suite}'.")
                sys.exit(1)
            if not isinstance(val, (int, float)):
                print(
                    f"::error::Baseline {key} rate for suite '{suite}' must be numeric (got {type(val)})."
                )
                sys.exit(1)
            if val < 0.0 or val > 1.0:
                print(
                    f"::error::Baseline {key} rate for suite '{suite}' must be between 0 and 1 (got {val})."
                )
                sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Validate per-suite coverage changes versus a baseline file."
    )
    parser.add_argument(
        "--base-dir",
        default="artifacts/verification/coverage",
        help="Directory containing generated coverage XML files (evidence output).",
    )
    parser.add_argument(
        "--suites",
        nargs="+",
        default=["dc-motor", "servo-motor", "speed-sensor"],
        help="List of suite names to validate.",
    )
    parser.add_argument(
        "--min-line-rate",
        type=float,
        default=90.0,
        help="Minimum acceptable line rate percentage (0–100).",
    )
    parser.add_argument(
        "--baseline",
        default=None,
        help="Path to baseline.json (version-controlled). If not provided, defaults to "
        "tests/verification/coverage/baseline.json.",
    )
    args = parser.parse_args()

    # Fail closed if the dotstop validator cannot be imported.
    try:
        sys.path.insert(0, "dotstop")
        from dotstop_extensions.validators import lltc_coverage_change_validator  # type: ignore
    except Exception as exc:
        print("::error::Critical safety validator 'dotstop_extensions.validators' not available.")
        print(f"Import error: {exc}")
        sys.exit(1)

    base_dir = args.base_dir
    baseline_path = args.baseline or os.path.join("tests", "verification", "coverage", "baseline.json")

    baseline_json = load_json(baseline_path)
    validate_baseline_structure(baseline_json, args.suites)

    inputs: List[Tuple[str, str]] = [(suite, os.path.join(base_dir, f"{suite}.xml")) for suite in args.suites]
    overall_ok = True
    summary: List[Tuple[str, float, List[str]]] = []

    for suite, xml_path in inputs:
        if not os.path.exists(xml_path):
            summary.append((suite, 0.0, [f"Coverage file not found: {xml_path}"]))
            overall_ok = False
            continue

        cfg = {
            "path": xml_path,
            "suite": suite,
            "baseline_path": baseline_path,
            "min_line_rate": args.min_line_rate,
            "require_review_on_change": True,
            "enforce_individual": True,
        }

        try:
            score, issues = lltc_coverage_change_validator(cfg)
        except Exception as e:
            summary.append((suite, 0.0, [f"Validator error: {e}"]))
            overall_ok = False
            continue

        summary.append((suite, score, [str(issue) for issue in issues]))
        if issues:
            overall_ok = False

    summary_file = "LLTC Coverage Validation Summary.txt"
    try:
        with open(summary_file, "w", encoding="utf-8") as f:
            for s_name, s_score, s_issues in summary:
                f.write(f"- {s_name}: score={s_score:.2f} issues={s_issues}\n")
    except Exception as e:
        print(f"::warning::Failed to write summary file: {e}")

    print("LLTC Coverage Validation Summary:")
    for s_name, s_score, s_issues in summary:
        print(f"  - {s_name}: score={s_score:.2f} issues={s_issues}")

    if not overall_ok:
        print("::error::Blocking due to coverage change requiring approval, parse errors or missing files.")
        sys.exit(1)

    print("Coverage change validation passed for all suites.")


if __name__ == "__main__":
    main()
