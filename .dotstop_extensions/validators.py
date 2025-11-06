# .dotstop_extensions/validators.py
"""
Local validators for dotstop/trudag.

Each validator takes a configuration dict (the `evidence` block) and returns:
    (score: float in 0.0..1.0, errors: list[Exception])

The functions provided here are:
 - junit_pass_rate_validator
 - cppcheck_error_validator
 - coverage_threshold_validator
"""

from __future__ import annotations
from typing import Any, TypeAlias
import xml.etree.ElementTree as ET
import os
import re

# Define the yaml type alias as expected by trudag
# This is the recursive type definition for YAML data
yaml: TypeAlias = str | int | float | bool | list["yaml"] | dict[str, "yaml"]

# Result type for validator functions
Result: TypeAlias = tuple[float, list[Exception]]


def _read_file_text(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def _resolve_path(cfg: dict[str, Any]) -> tuple[str | None, list[Exception]]:
    """
    Resolve a path for validator configuration. Looks at:
      - cfg['references'][0]['path']
      - cfg['path']
    Returns (path_or_None, [exceptions])
    """
    errs: list[Exception] = []
    if not cfg:
        return None, errs
    refs = cfg.get("references") or []
    if refs and isinstance(refs, list) and len(refs) > 0 and refs[0].get("path"):
        return refs[0]["path"], errs
    path = cfg.get("path")
    if path:
        return path, errs
    errs.append(ValueError("No path provided in validator configuration (references or path)."))
    return None, errs


def junit_pass_rate_validator(configuration: dict[str, yaml]) -> Result:
    """
    Expect a JUnit XML file. Configuration examples:
      evidence:
        type: "junit_pass_rate_validator"
        references:
          - type: file
            path: artifacts/verification/tests/LLTC-998-junit.xml
        configuration:
          min_pass_rate: 100

    Returns score in 0..1 (1.0 if pass_rate >= min_pass_rate), plus exceptions.
    """
    cfg = configuration or {}
    # some users embed config under cfg['configuration']
    cfg = cfg.get("configuration", cfg) if isinstance(cfg.get("configuration", None), dict) else cfg

    path, errs = _resolve_path(cfg)
    if errs:
        return 0.0, errs
    if not os.path.exists(path):
        return 0.0, [FileNotFoundError(path)]

    try:
        tree = ET.parse(path)
        root = tree.getroot()
        # standard attributes on root: tests, failures, errors, skipped
        def iattr(node, name):
            val = node.attrib.get(name)
            if val is None:
                # try element children (some junit outputs differ)
                child = node.find(name)
                return int(child.text) if child is not None and child.text and child.text.isdigit() else 0
            try:
                return int(val)
            except Exception:
                return int(float(val)) if val and "." in val else 0

        tests = iattr(root, "tests") or int(root.findtext("tests") or 0)
        failures = iattr(root, "failures") or int(root.findtext("failures") or 0)
        errors = iattr(root, "errors") or int(root.findtext("errors") or 0)
        skipped = iattr(root, "skipped") or int(root.findtext("skipped") or 0)

        passed = max(0, tests - failures - errors - skipped)
        pass_rate = 100.0 * (passed / tests) if tests > 0 else 0.0

        min_pass = cfg.get("min_pass_rate") or cfg.get("min_pass") or cfg.get("min_pass_rate", 100)
        try:
            min_pass = float(min_pass)
        except Exception:
            min_pass = 100.0

        if min_pass <= 0:
            score = 1.0 if pass_rate > 0 else 0.0
        else:
            score = 1.0 if pass_rate >= min_pass else (pass_rate / min_pass)

        return float(min(score, 1.0)), []
    except Exception as e:
        return 0.0, [e]


def cppcheck_error_validator(configuration: dict[str, yaml]) -> Result:
    """
    Expect a cppcheck XML (or plain XML) file where <error ...> tags indicate issues.
    Configuration example:
      evidence:
        type: "cppcheck_error_validator"
        references:
         - type: file
           path: artifacts/verification/static-analysis/cppcheck-SWD-998.xml
        configuration:
          fail_on_severity: ["error"]

    For now the validator treats any <error ...> entries as errors and returns 1.0 if zero errors.
    """
    cfg = configuration or {}
    cfg = cfg.get("configuration", cfg) if isinstance(cfg.get("configuration", None), dict) else cfg

    path, errs = _resolve_path(cfg)
    if errs:
        return 0.0, errs
    if not os.path.exists(path):
        return 0.0, [FileNotFoundError(path)]

    try:
        text = _read_file_text(path)
        # count "<error " occurrences (simple but works for cppcheck xml)
        errors = text.count("<error ")
        # If the configuration provides an allowed number or severity rule, support basic forms
        allowed = 0
        # if user provided some fail_on_severity list, we treat errors as fatal (allowed=0)
        score = 1.0 if errors <= allowed else 0.0
        return float(score), []
    except Exception as e:
        return 0.0, [e]


def coverage_threshold_validator(configuration: dict[str, yaml]) -> Result:
    """
    Expect a coverage XML file containing line-rate="0.87" or similar.
    Configuration example:
      evidence:
        type: "coverage_threshold_validator"
        references:
         - type: file
           path: artifacts/verification/coverage/coverage-SWD-998.xml
        configuration:
          min_line_rate: 80

    Returns 1.0 if coverage >= min_line_rate, otherwise fractional score.
    """
    cfg = configuration or {}
    cfg = cfg.get("configuration", cfg) if isinstance(cfg.get("configuration", None), dict) else cfg

    path, errs = _resolve_path(cfg)
    if errs:
        return 0.0, errs
    if not os.path.exists(path):
        return 0.0, [FileNotFoundError(path)]

    try:
        text = _read_file_text(path)
        m = re.search(r'line-rate="([0-9]*\.?[0-9]+)"', text)
        if not m:
            # try coverage percent like <coverage percent="87.0" />
            m2 = re.search(r'percent="([0-9]*\.?[0-9]+)"', text)
            if m2:
                coverage = float(m2.group(1))
            else:
                return 0.0, [ValueError("Couldn't find line-rate or percent in coverage file.")]
        else:
            coverage = float(m.group(1)) * 100.0

        min_cov = float(cfg.get("min_line_rate", cfg.get("min_line", 80)))
        if min_cov <= 0:
            score = 1.0
        else:
            score = 1.0 if coverage >= min_cov else (coverage / min_cov)

        return float(min(score, 1.0)), []
    except Exception as e:
        return 0.0, [e]
