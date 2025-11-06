# .dotstop_extensions/__init__.py
"""
Dotstop extensions package for trudag validators.

This __init__.py file makes the .dotstop_extensions directory a Python package,
allowing trudag to discover and load the validator functions from validators.py.
"""

# Import validators so they're available at package level
from .validators import (
    junit_pass_rate_validator,
    cppcheck_error_validator,
    coverage_threshold_validator,
)

__all__ = [
    "junit_pass_rate_validator",
    "cppcheck_error_validator",
    "coverage_threshold_validator",
]
