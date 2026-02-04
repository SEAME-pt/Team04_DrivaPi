# dotstop_extensions/validators.py
from __future__ import annotations
from typing import TypeAlias, Dict, List, Tuple
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

        if min_pass <= 0:
            score = 0.0
        else:
            score = 1.0 if pass_rate >= min_pass else (pass_rate / min_pass)

        return (min(max(score, 0.0), 1.0), [])

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

        error_count = 0
        for run in sarif_data.get("runs", []):
            for result in run.get("results", []):
                if result.get("level") == "error":
                    error_count += 1

        score = 1.0 if error_count == 0 else 0.0

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
        if not path:
            return (0.0, [ValueError("No coverage path provided")])
        if not os.path.exists(path):
            return (0.0, [FileNotFoundError(path)])

        tree = ET.parse(path)
        root = tree.getroot()

        coverage = None
        def _to_percent(s: str) -> float | None:
            try:
                v = float(s)
            except Exception:
                return None
            if 0.0 < v <= 1.0:
                return v * 100.0
            return v

        for attr in ("line-rate", "lineRate", "percent", "value"):
            val = root.attrib.get(attr)
            if val:
                coverage = _to_percent(val)
                if coverage is not None:
                    break

        if coverage is None:
            metrics = root.find(".//metrics")
            if metrics is not None:
                for attr in ("line-rate", "lineRate", "percent", "value"):
                    val = metrics.attrib.get(attr)
                    if val:
                        coverage = _to_percent(val)
                        if coverage is not None:
                            break

        if coverage is None:
            for cov_el in root.findall(".//coverage"):
                val = cov_el.attrib.get("value") or cov_el.attrib.get("percent")
                if val:
                    val_str = val.strip().rstrip("%")
                    coverage = _to_percent(val_str)
                    if coverage is not None:
                        break

        if coverage is None:
            return (0.0, [ValueError(
                "Couldn't find coverage value in recognized attributes/elements "
                "(root, metrics, statistics/coverage) in coverage file"
            )])

        min_cov = float(cfg.get("min_line_rate", 90))
        if min_cov <= 0:
            return (0.0, [ValueError("Invalid min_line_rate in configuration")])

        score = 1.0 if coverage >= min_cov else (coverage / min_cov)
        return (min(max(score, 0.0), 1.0), [])

    except Exception as e:
        return (0.0, [e])


# ----------------------
# Public API of module
# ----------------------
__all__ = [
    "junit_pass_rate_validator",
    "codeql_sarif_validator",
    "coverage_threshold_validator",
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
    ]

    for _fn in _validator_fns:
        try:
            _fn.__signature__ = Validator._SIGNATURE
        except Exception:
            pass
except ImportError:
    # Optional dependency: if trudag is not installed, validators still work without signature patching.
    pass
