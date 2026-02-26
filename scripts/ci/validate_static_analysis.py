#!/usr/bin/env python3
"""
Validate static analysis SARIF results (fail-closed).

ISO 26262 / ISO 21434 posture:
- If the validator plugin is missing or cannot be imported, FAIL the pipeline.
- If no SARIF file is found, FAIL.
"""

import argparse
import os
import sys


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate static analysis SARIF results.")
    parser.add_argument(
        "--base-dir",
        default="artifacts/verification/static-analysis",
        help="Static analysis directory",
    )
    parser.add_argument(
        "--sarif-candidates",
        nargs="+",
        default=[
            "results/cpp.sarif",
            os.path.join("artifacts/verification/static-analysis", "cpp.sarif"),
            os.path.join("artifacts/verification/static-analysis", "results/cpp.sarif"),
            os.path.join("artifacts/verification/static-analysis", "codeql.sarif"),
        ],
        help="SARIF file candidates (searched in order)",
    )
    args = parser.parse_args()

    try:
        sys.path.insert(0, "dotstop")
        from dotstop_extensions.validators import codeql_sarif_validator  # type: ignore
    except Exception as exc:
        print("::error::Critical validator 'dotstop_extensions.validators' not available.")
        print(f"Import error: {exc}")
        return 1

    sarif_path = None
    for p in args.sarif_candidates:
        if os.path.exists(p):
            sarif_path = p
            break

    if sarif_path is None:
        print("::error::No SARIF file found; cannot validate static analysis.")
        return 1

    score, errs = codeql_sarif_validator({"path": sarif_path, "hard_fail_on_error": True})
    print(f"Static Analysis SARIF: path={sarif_path} score={score} errs={errs}")

    if errs:
        print("::error::Blocking due to static analysis errors.")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
