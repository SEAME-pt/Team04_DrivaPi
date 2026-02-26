# dotstop_extensions/validators.py
from __future__ import annotations
from typing import TypeAlias, Dict, List, Tuple, Optional
import xml.etree.ElementTree as ET
import os
import json

yaml: TypeAlias = str | int | float | bool | list["yaml"] | dict[str, "yaml"]

# ----------------------
# Helper: find file path
# ----------------------
def _path_from_config(configuration: dict | None) -> str | None:
    cfg = configuration or {}
    refs = cfg.get("references") or []
    if refs:
        first = refs[0]
        if isinstance(first, dict):
            p = first.get("path")
            if p:
                return p
    return cfg.get("path")


# ----------------------
# Helper: read Cobertura
# ----------------------
def _read_cobertura_rates(path: str) -> Tuple[Optional[float], Optional[float]]:
    try:
        tree = ET.parse(path)
        root = tree.getroot()
        def _to_float(v: str | None) -> Optional[float]:
            if not v:
                return None
            try:
                return float(v)
            except Exception:
                return None
        line_rate = _to_float(root.attrib.get("line-rate") or root.attrib.get("lineRate"))
        branch_rate = _to_float(root.attrib.get("branch-rate") or root.attrib.get("branchRate"))
        if line_rate is None or branch_rate is None:
            metrics = root.find(".//metrics")
            if metrics is not None:
                if line_rate is None:
                    line_rate = _to_float(metrics.attrib.get("line-rate") or metrics.attrib.get("lineRate"))
                if branch_rate is None:
                    branch_rate = _to_float(metrics.attrib.get("branch-rate") or metrics.attrib.get("branchRate"))
        return (line_rate, branch_rate)
    except Exception:
        return (None, None)


# ----------------------
# Helper: load JSON file
# ----------------------
def _load_json(path: str) -> Optional[dict]:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return None


# ----------------------
# Helper: current commit
# ----------------------
def _get_current_sha() -> Optional[str]:
    sha = os.environ.get("GITHUB_SHA") or os.environ.get("TRUDAG_SHA")
    if sha:
        return sha
    try:
        import subprocess
        out = subprocess.check_output(["git", "rev-parse", "HEAD"], stderr=subprocess.DEVNULL)
        return out.decode().strip()
    except Exception:
        return None


# ------------------------------
# Helper: suite name from path
# ------------------------------
def _suite_name_from_path(path: str) -> str:
    fname = os.path.basename(path).lower()
    if fname == "coverage.xml":
        return "aggregate"
    return os.path.splitext(fname)[0]


# -------------------------
# JUnit pass rate validator
# -------------------------
def junit_pass_rate_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    try:
        cfg = configuration or {}
        path = _path_from_config(cfg)
        if not path:
            return (0.0, [ValueError("No path provided in validator configuration (references or path).")])
        if not os.path.exists(path):
            return (0.0, [FileNotFoundError(path)])

        tree = ET.parse(path)
        root = tree.getroot()

        tests = int(root.attrib.get("tests", root.findtext("./tests") or 0))
        failures = int(root.attrib.get("failures", root.findtext("./failures") or 0))
        errors = int(root.attrib.get("errors", root.findtext("./errors") or 0))
        skipped = int(root.attrib.get("skipped", root.findtext("./skipped") or 0))

        if root.tag.lower().endswith("testsuites") and tests == 0:
            total_tests = total_failures = total_errors = total_skipped = 0
            for ts in root.findall("testsuite"):
                total_tests += int(ts.attrib.get("tests", 0))
                total_failures += int(ts.attrib.get("failures", 0))
                total_errors += int(ts.attrib.get("errors", 0))
                total_skipped += int(ts.attrib.get("skipped", 0))
            if total_tests > 0:
                tests = total_tests
                failures = total_failures
                errors = total_errors
                skipped = total_skipped

        passed = max(0, tests - failures - errors - skipped)

        pass_rate = 100.0 * (passed / tests) if tests > 0 else 0.0

        min_pass = cfg.get("min_pass_rate") or cfg.get("min_pass") or 100
        min_pass = float(min_pass)

        hard_fail = bool(cfg.get("hard_fail", False))
        if hard_fail and (failures > 0 or errors > 0):
            return (0.0, [ValueError(f"Unit tests have failures or errors: failures={failures}, errors={errors}")])

        if min_pass <= 0:
            score = 0.0
        else:
            score = 1.0 if pass_rate >= min_pass else (pass_rate / min_pass)

        return (score, [])

    except Exception as e:
        return (0.0, [e])


# -----------------------------------------
# CodeQl validator
# -----------------------------------------
def codeql_sarif_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    try:
        cfg = configuration or {}
        path = _path_from_config(cfg)
        if not path:
            return (0.0, [ValueError("No path provided in validator configuration (references or path).")])
        if not os.path.exists(path):
            return (0.0, [FileNotFoundError(path)])

        with open(path, 'r', encoding='utf-8') as f:
            sarif_data = json.load(f)

        errors = 0
        warnings = 0
        notes = 0
        for run in sarif_data.get("runs", []):
            for result in run.get("results", []):
                lvl = (result.get("level") or "").lower()
                if lvl == "error":
                    errors += 1
                elif lvl == "warning":
                    warnings += 1
                elif lvl == "note":
                    notes += 1

        w_error = float(cfg.get("weight_error", 0.10))
        w_warning = float(cfg.get("weight_warning", 0.02))
        w_note = float(cfg.get("weight_note", 0.0))

        penalty = (errors * w_error) + (warnings * w_warning) + (notes * w_note)
        score = max(0.0, 1.0 - penalty)

        if bool(cfg.get("hard_fail_on_error", True)) and errors > 0:
            score = 0.0

        return (score, [])

    except Exception as e:
        return (0.0, [e])


# -----------------------------------------
# Coverage threshold validator (flexible)
# -----------------------------------------
def coverage_threshold_validator(configuration: Dict) -> Tuple[float, List[Exception]]:
    try:
        cfg = configuration or {}
        path = _path_from_config(cfg)
        if not path or not os.path.exists(path):
            return (0.0, [FileNotFoundError(path or "No Path")])

        line_rate, branch_rate = _read_cobertura_rates(path)
        if line_rate is None:
            return (0.0, [ValueError("Unable to parse line-rate from coverage XML")])

        min_cov = float(cfg.get("min_line_rate", 90))
        baseline_path = cfg.get("baseline") or cfg.get("baseline_path")
        suite_name = cfg.get("suite") or _suite_name_from_path(path)
        epsilon = float(cfg.get("delta_epsilon", 1e-6))

        if baseline_path and os.path.exists(baseline_path):
            baseline = _load_json(baseline_path) or {}
            suites = baseline.get("suites") or baseline
            prev = suites.get(suite_name)
            if prev and isinstance(prev, dict):
                prev_line = prev.get("line-rate") or prev.get("line_rate")
                prev_branch = prev.get("branch-rate") or prev.get("branch_rate")

                if prev_line is not None and prev_line > 1.0: prev_line /= 100.0
                if prev_branch is not None and prev_branch > 1.0: prev_branch /= 100.0

                if prev_line is None or prev_branch is None:
                    return (0.0, [ValueError("Baseline data missing/corrupted")])

                changed = abs(line_rate - prev_line) > epsilon
                if branch_rate is not None and prev_branch is not None:
                    if abs(branch_rate - prev_branch) > epsilon: changed = True

                if changed:
                    return (0.0, [ValueError("Coverage changed since baseline and requires an approval by modifying baseline file")])
        score = min(max((line_rate * 100.0) / min_cov, 0.0), 1.0)
        return (score, [])
    except Exception as e:
        return (0.0, [e])


# --------------------------------------------------------------
# LLTC Coverage Validator with change detection and approvals
# --------------------------------------------------------------
def lltc_coverage_change_validator(configuration: Dict) -> Tuple[float, List[Exception | Warning]]:
    try:
        cfg = configuration or {}
        path = _path_from_config(cfg)
        refs = cfg.get("references") or []
        paths = [path] if path else []
        for r in refs:
            if isinstance(r, dict) and r.get("path"): paths.append(r["path"])

        if not paths:
            return (0.0, [ValueError("No coverage paths provided")])

        baseline_path = cfg.get("baseline") or cfg.get("baseline_path")
        min_cov = float(cfg.get("min_line_rate", 90))
        epsilon = float(cfg.get("delta_epsilon", 1e-6))

        baseline = _load_json(baseline_path) if (baseline_path and os.path.exists(baseline_path)) else None
        baseline_suites = (baseline or {}).get("suites") or (baseline or {})

        errors: List[Exception | Warning] = []
        scores: List[float] = []
        for p in paths:
            if not os.path.exists(p):
                errors.append(FileNotFoundError(p))
                continue

            suite_name = cfg.get("suite") or _suite_name_from_path(p)
            lr, br = _read_cobertura_rates(p)
            if lr is None:
                errors.append(ValueError(f"Unable to parse line-rate: {p}"))
                continue

            s = min(max((lr * 100.0) / min_cov, 0.0), 1.0)

            if baseline_suites and suite_name in baseline_suites:
                prev = baseline_suites.get(suite_name)
                if not isinstance(prev, dict):
                    errors.append(ValueError(f"Invalid baseline entry for {suite_name}"))
                    scores.append(0.0); continue

                prev_line = prev.get("line-rate")
                if prev_line is None: prev_line = prev.get("line_rate")

                prev_branch = prev.get("branch-rate")
                if prev_branch is None: prev_branch = prev.get("branch_rate")

                if prev_line is not None and prev_line > 1.0: prev_line /= 100.0
                if prev_branch is not None and prev_branch > 1.0: prev_branch /= 100.0

                if prev_line is None or prev_branch is None:
                    return (0.0, [ValueError("Baseline data missing/corrupted")])

                changed = abs(lr - prev_line) > epsilon
                if br is not None and prev_branch is not None:
                    if abs(br - prev_branch) > epsilon: changed = True

                if changed:
                    errors.append(ValueError(f"Coverage changed for {suite_name} and requires an approval by modifying baseline file."))
                    s = 0.0

            scores.append(s)

        return (min(scores) if scores else 0.0, errors)
    except Exception as e:
        return (0.0, [e])


# ----------------------
# Public API of module
# ----------------------
__all__ = [
    "junit_pass_rate_validator",
    "codeql_sarif_validator",
    "coverage_threshold_validator",
    "lltc_coverage_change_validator",
]


# ----------------------
# Trudag signature fix
# ----------------------
try:
    from trudag.dotstop.core.validator import Validator

    _validator_fns = [
        junit_pass_rate_validator,
        codeql_sarif_validator,
        coverage_threshold_validator,
        lltc_coverage_change_validator,
    ]

    for _fn in _validator_fns:
        try:
            _fn.__signature__ = Validator._SIGNATURE
        except Exception:
            pass
except Exception:
    pass
