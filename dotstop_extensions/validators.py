# dotstop_extensions/validators.py
# The three validators below read XML reports (JUnit, cppcheck, coverage)
# and return a tuple: (score, errors_list)
# - score: float between 0.0 and 1.0 (how well the check passed)
# - errors_list: list of Exception or Warning objects (or strings explaining failures)

from __future__ import annotations
# The above makes type annotations behave a bit more forgivingly (stored as strings).
# Not required for the code to work, but harmless and useful in bigger projects.

from typing import TypeAlias, Dict, List, Tuple
import xml.etree.ElementTree as ET  # standard XML parser
import os  # to check if files exist

# Define a readable alias type for YAML-like config values.
# This is only for humans/tools: Python will run fine without it.
yaml: TypeAlias = str | int | float | bool | list["yaml"] | dict[str, "yaml"]

# ----------------------
# Helper: find file path
# ----------------------
def _path_from_config(configuration: dict | None) -> str | None:
    """
    Given a configuration dict, try these places for a path:
     - configuration["references"][0]["path"]
     - configuration["path"]
    Return the path string or None if nothing found.

    We wrap this small logic to avoid repeating the same lines in each validator.
    """
    cfg = configuration or {}
    # 'references' is often a list of dicts like [{"type":"file","path":"..."}]
    refs = cfg.get("references") or []
    if refs:
        # If there is at least one reference, try to read its 'path' key.
        first = refs[0]
        if isinstance(first, dict):
            p = first.get("path")
            if p:
                return p
    # fallback: look for a direct 'path' key
    return cfg.get("path")


# -------------------------
# JUnit pass rate validator
# -------------------------
def junit_pass_rate_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    """
    Read a JUnit XML file and compute the pass rate.
    Returns (score, errors_list).
    - score = 1.0 if pass_rate >= min_pass_rate
    - otherwise score = pass_rate / min_pass_rate (a fraction between 0 and 1)
    If an error happens, returns (0.0, [Exception]).
    """
    try:
        cfg = configuration or {}  # make sure cfg is a dict even if None given
        path = _path_from_config(cfg)  # helper above extracts path
        # If no path was provided, return a failing score and an explanatory error.
        if not path:
            return (0.0, [ValueError("No path provided in validator configuration (references or path).")])
        # If the path points to a non-existing file, return a FileNotFoundError wrapped in a list.
        if not os.path.exists(path):
            return (0.0, [FileNotFoundError(path)])

        # Parse the XML file into a tree structure.
        tree = ET.parse(path)
        root = tree.getroot()

        # Many JUnit-style XML files expose counts either as attributes or as child elements.
        # Try to read the attribute first (fast), otherwise try to read a child element text,
        # otherwise use zero as default.
        tests = int(root.attrib.get("tests", root.findtext("./tests") or 0))
        failures = int(root.attrib.get("failures", root.findtext("./failures") or 0))
        errors = int(root.attrib.get("errors", root.findtext("./errors") or 0))
        skipped = int(root.attrib.get("skipped", root.findtext("./skipped") or 0))

        # Many generators wrap multiple <testsuite> inside a <testsuites> root.
        # If that's the case and the root had no 'tests' attribute, sum child suites.
        if root.tag.lower().endswith("testsuites") and tests == 0:
            total_tests = total_failures = total_errors = total_skipped = 0
            for ts in root.findall("testsuite"):
                total_tests += int(ts.attrib.get("tests", 0))
                total_failures += int(ts.attrib.get("failures", 0))
                total_errors += int(ts.attrib.get("errors", 0))
                total_skipped += int(ts.attrib.get("skipped", 0))
            # use totals if we found any
            if total_tests > 0:
                tests = total_tests
                failures = total_failures
                errors = total_errors
                skipped = total_skipped

        # passed: number of tests that passed (cannot be negative)
        passed = max(0, tests - failures - errors - skipped)

        # pass_rate in percent (0.0 .. 100.0). If no tests, define it as 0.0 to avoid division by zero.
        pass_rate = 100.0 * (passed / tests) if tests > 0 else 0.0

        # read required minimum pass percentage from config. Default is 100 (be strict by default).
        min_pass = cfg.get("min_pass_rate") or cfg.get("min_pass") or 100
        # ensure numeric (float)
        min_pass = float(min_pass)

        # if min_pass is invalid (<= 0) we consider it a bad config and return score 0
        if min_pass <= 0:
            score = 0.0
        else:
            # full score if pass_rate meets or exceeds required minimum, otherwise proportional
            score = 1.0 if pass_rate >= min_pass else (pass_rate / min_pass)

        # clamp score to [0.0, 1.0] and return no errors (empty list).
        return (min(max(score, 0.0), 1.0), [])

    except Exception as e:
        # Any unexpected error is returned as (0.0, [e]) so the caller can record the exception.
        return (0.0, [e])


# -----------------------------
# Cppcheck error count validator
# -----------------------------
def cppcheck_error_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    """
    Parse cppcheck XML and count <error> elements.
    Returns (1.0, []) if zero errors, else (0.0, []).
    If something goes wrong reading the file, returns (0.0, [Exception]).
    """
    try:
        cfg = configuration or {}
        path = _path_from_config(cfg)
        if not path:
            return (0.0, [ValueError("No cppcheck xml path provided")])
        if not os.path.exists(path):
            return (0.0, [FileNotFoundError(path)])

        tree = ET.parse(path)
        root = tree.getroot()

        # Many cppcheck outputs include a top-level <errors> element whose children are <error>.
        errors_element = root.find("errors")

        # determine which severities count as failures (accept single value or list)
        fail_severities = cfg.get("fail_on_severity", ["error"])
        if not isinstance(fail_severities, list):
            fail_severities = [fail_severities]

        # count only errors whose severity is in fail_severities
        if errors_element is not None:
            candidates = errors_element.findall("error")
        else:
            candidates = root.findall(".//error")

        error_count = 0
        for err in candidates:
            severity = err.attrib.get("severity")
            if severity in fail_severities:
                error_count += 1

        # allowed number of errors (here hard-coded to zero).
        allowed = 0
        score = 1.0 if error_count <= allowed else 0.0

        return (score, [])

    except Exception as e:
        return (0.0, [e])


# -----------------------------------------
# Coverage threshold validator (flexible)
# -----------------------------------------
def coverage_threshold_validator(configuration: Dict) -> Tuple[float, List[Exception]]:
    """
    Read different coverage XML formats and extract a line coverage percent,
    then compare against min_line_rate (default 80).
    Returns (score, []) on success or (0.0, [Exception]) on error.

    This function tries multiple places where coverage numbers commonly appear
    (root attributes, <metrics>, <coverage> elements).
    """
    try:
        cfg = configuration or {}
        path = _path_from_config(cfg)
        if not path:
            return (0.0, [ValueError("No coverage path provided")])
        if not os.path.exists(path):
            return (0.0, [FileNotFoundError(path)])

        tree = ET.parse(path)
        root = tree.getroot()

        coverage = None  # we'll store percentage here (e.g. 87.0)

        # helper: accept either "0.87" or "87" or "87%" and return 87.0
        def _to_percent(s: str) -> float | None:
            try:
                v = float(s)
            except Exception:
                return None
            # if value looks like a fraction 0.xx, scale to percent
            if 0.0 < v <= 1.0:
                return v * 100.0
            return v

        # 1) check common attributes on the root element:
        for attr in ("line-rate", "lineRate", "percent", "value"):
            val = root.attrib.get(attr)
            if val:
                coverage = _to_percent(val)
                if coverage is not None:
                    break

        # 2) some reports put the metric inside a <metrics> element
        if coverage is None:
            metrics = root.find(".//metrics")
            if metrics is not None:
                for attr in ("line-rate", "lineRate", "percent", "value"):
                    val = metrics.attrib.get(attr)
                    if val:
                        coverage = _to_percent(val)
                        if coverage is not None:
                            break

        # 3) some reports have <coverage value="87%" /> inside a <statistics> or <summary>
        if coverage is None:
            for cov_el in root.findall(".//coverage"):
                # value could be "87%" or "87"
                val = cov_el.attrib.get("value") or cov_el.attrib.get("percent")
                if val:
                    # remove trailing % sign if present, then convert
                    val_str = val.strip().rstrip("%")
                    coverage = _to_percent(val_str)
                    if coverage is not None:
                        break

        # If we still don't have a coverage number, return a helpful error
        if coverage is None:
            return (0.0, [ValueError(
                "Couldn't find coverage value in recognized attributes/elements "
                "(root, metrics, statistics/coverage) in coverage file"
            )])

        # Minimum coverage required (default 80)
        min_cov = float(cfg.get("min_line_rate", 80))
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
    "cppcheck_error_validator",
    "coverage_threshold_validator",
]


# ----------------------
# Trudag signature fix (optional)
# ----------------------
# This block tries to make the function signatures match what Trudag expects.
# If Trudag isn't available at install time, this block silently does nothing.
# You don't need to understand this to use the validators; it's for integration.
try:
    from trudag.dotstop.core.validator import Validator

    _validator_fns = [
        junit_pass_rate_validator,
        cppcheck_error_validator,
        coverage_threshold_validator,
    ]

    # Try to set the exact signature object Trudag expects on each function.
    # This helps tools that compare signatures with inspect.signature(...).
    for _fn in _validator_fns:
        try:
            _fn.__signature__ = Validator._SIGNATURE
        except Exception:
            # if this assignment fails, it's not fatal here; continue silently
            pass
except Exception:
    # If trudag is not installed in this environment, we simply ignore and proceed.
    pass
