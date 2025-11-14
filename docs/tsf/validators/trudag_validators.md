# The Trudag Validator Implementation Guide

**A comprehensive deep-dive for developers implementing validators in Trudag/Trustable**

Based on Trudag 2025.9.16

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Understanding Trudag's Validator System](#understanding-trudags-validator-system)
3. [The Validator Signature](#the-validator-signature)
4. [The Validator Predicate: How Trudag Discovers Validators](#the-validator-predicate-how-trudag-discovers-validators)
5. [Two Ways to Add Validators](#two-ways-to-add-validators)
6. [Python Type System & Validators](#python-type-system--validators)
7. [Virtual Environments and Package Isolation](#virtual-environments-and-package-isolation)
8. [Further Reading](#further-reading)

---

## Executive Summary

### What You Need to Know Immediately

Trudag validators are **just Python functions** that:
1. Accept configuration data (`dict[str, yaml]`)
2. Read evidence files (test results, coverage reports, etc.)
3. Return a score (0.0–1.0) and any errors
4. Are discovered via Python's **entry point system**

The **signature must be exact**:
```python
def your_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    return (score, errors)
```

If the signature doesn't match exactly, Trudag's discovery system **silently ignores your validator**.

### Why This Guide Exists

The official Trudag documentation provides the **what** (how to write validators) but lacks the **why** and **how deeply** (why certain signatures work, how discovery actually works, why pipx matters). This guide fills that gap.

---

## Understanding Trudag's Validator System

### Historical Context

Trudag is part of the **Trustable** framework for safety-critical software documentation. The original design principle: **"We don't provide validators — use your own."**

Why? Because:
- Test frameworks vary widely (JUnit, pytest, custom scripts)
- Coverage tools produce different XML schemas (Cobertura, coverage.py, LLVM)
- Static analysis tools output different formats (Cppcheck, Clang-Tidy, SonarQube)
- Different projects have different compliance needs

So instead of building validators for every tool, Trudag provides an **extensible plugin system** where you write validators for YOUR tools.

### The Validator Lifecycle

```
1. USER DEFINES REQUIREMENT
   ↓
   evidence:
     type: my_validator
     configuration:
       threshold: 80

2. TRUDAG STARTS
   ↓
   Loads requirement file
   Finds evidence.type: "my_validator"

3. TRUDAG DISCOVERS VALIDATORS
   ↓
   Searches:
   - Local .dotstop_extensions/validators.py
   - Entry points in installed packages
   Finds: my_validator function

4. TRUDAG VALIDATES FUNCTION
   ↓
   Checks:
   - Is callable? ✓
   - Signature matches? ✓
   - Type hints correct? ✓

5. TRUDAG CALLS VALIDATOR
   ↓
   my_validator({threshold: 80})

6. VALIDATOR EXECUTES
   ↓
   Reads evidence files
   Computes metric
   Returns (score, errors)

7. TRUDAG SCORES REQUIREMENT
   ↓
   REQ-001 = 0.87 ⚠️
```

---

## The Validator Signature

### Official Signature

```python
def validator_name(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    pass
```

Where `yaml` is defined as:
```python
from typing import TypeAlias

yaml: TypeAlias = (
    str | int | float | bool |
    list["yaml"] |
    dict[str, "yaml"]
)
```

### Breaking Down the Signature

#### **Input: `configuration: dict[str, yaml]`**

This is a dictionary that comes from your YAML/Markdown requirement:

```yaml
evidence:
  type: my_validator
  configuration:
    key1: "string value"
    key2: 42
    key3: 3.14
    key4: true
    key5:
      - nested
      - list
      - of
      - values
    key6:
      nested: dict
      with: values
```

All of this becomes:
```python
configuration = {
    'key1': 'string value',
    'key2': 42,
    'key3': 3.14,
    'key4': True,
    'key5': ['nested', 'list', 'of', 'values'],
    'key6': {'nested': 'dict', 'with': 'values'}
}
```

#### **Output: `tuple[float, list[Exception | Warning]]`**

A tuple with exactly two elements:

1. **`float` (the score):** A number between 0.0 and 1.0
   - `1.0` = Requirement fully met
   - `0.8` = Requirement 80% met
   - `0.0` = Requirement not met

2. **`list[Exception | Warning]`:** Any errors encountered
   - Can be empty `[]` if validation succeeded
   - Can contain multiple errors
   - Each error is an `Exception` or `Warning` object

**Example returns:**
```python
# Perfect pass
return (1.0, [])

# 85% pass
return (0.85, [])

# Failed with error
return (0.0, [ValueError("Coverage file not found")])

# Multiple errors
return (0.5, [
    FileNotFoundError("Missing: results.xml"),
    ValueError("Invalid XML format")
])
```

### Why This Specific Signature?

Trudag uses Python's **`inspect.signature()`** to validate functions. When you define:

```python
def my_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
```

Python creates a **signature object** that Trudag checks against. If anything differs, the check fails:

```python
# ❌ WRONG: Different parameter name
def my_validator(config: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    # Fails! Parameter named "config", not "configuration"

# ❌ WRONG: Missing return type
def my_validator(configuration: dict[str, yaml]):
    # Fails! No return type annotation

# ❌ WRONG: Different return type
def my_validator(configuration: dict[str, yaml]) -> tuple[int, list[Exception]]:
    # Fails! Returns int instead of float

# ✅ CORRECT: Exact match
def my_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
```

### The Critical Signature Matching Issue

There's a **runtime quirk** in how Python handles type annotations. Due to how the `yaml` TypeAlias is defined and used, the function's **runtime signature** might not exactly match Trudag's signature, even if the code looks identical.

**Solution:** Explicitly assign Trudag's signature to your function (see section "[The Validator Predicate](#the-validator-predicate-how-trudag-discovers-validators)").

---

## The Validator Predicate: How Trudag Discovers Validators

### Trudag's Discovery Code

When Trudag loads validators, it uses a **predicate function** to test if something is a valid validator:

```python
# From trudag/dotstop/core/validator.py (simplified)
@staticmethod
def is_validator_function(anything: Any) -> bool:
    return (
        callable(anything)  # Must be callable (a function)
        and
        inspect.signature(anything) == Validator._SIGNATURE
        # Signature must EXACTLY match
    )
```

This is called on every object loaded from:
1. Local `.dotstop_extensions/validators.py`
2. Entry points in installed packages
3. Dynamically loaded modules

### What "Signature Match" Means

When Trudag checks `inspect.signature(func) == Validator._SIGNATURE`, it's comparing **signature objects**:

```python
import inspect
from trudag.dotstop.core.validator import Validator

# Your function
def my_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    pass

# What Trudag checks
sig = inspect.signature(my_validator)
match = sig == Validator._SIGNATURE
# match should be True, but might be False due to type alias resolution
```

**The Problem:**

Due to how `yaml` TypeAlias works and how Python resolves type hints, the runtime signature might NOT match exactly. The parameter and return types look identical in code, but Python's type system sees them as different at runtime.

**The Solution: Explicit Assignment**

Add this code after all your validator definitions:

```python
# Force signature matching
try:
    from trudag.dotstop.core.validator import Validator

    for _validator_func in [
        my_validator_1,
        my_validator_2,
        my_validator_3,
    ]:
        _validator_func.__signature__ = Validator._SIGNATURE
except Exception:
    pass  # Trudag might not be installed during development
```

This **explicitly sets** your function's `__signature__` attribute to match Trudag's exactly.

### Why the Exception Handling?

The `try/except` is important because:
- During development, Trudag might not be installed yet
- The code should be distribution-safe (won't crash if Trudag isn't available)
- Validators should work with or without Trudag installed

### Verification: Testing Discovery

To verify Trudag can find your validators:

```bash
# List all discovered validators
python -c "
from trudag.dotstop.core.validator import Validator
v = Validator()
print('Discovered validators:')
for name, func in v._validator_functions.items():
    print(f'  ✓ {name}: {func}')
"
```

Expected output:
```
Discovered validators:
  ✓ my_validator_1: <function my_validator_1 at 0x...>
  ✓ my_validator_2: <function my_validator_2 at 0x...>
```

If your validators don't appear, the signature doesn't match.

---

## Two Ways to Add Validators

Trudag supports two distinct patterns for adding validators. Choose based on your use case.

### Pattern 1: Local Extensions (Development)

**Use case:** Quick testing, personal scripts, single-project validators

**How it works:**
1. Create `.dotstop_extensions/validators.py` in your working directory
2. Define your validator functions there
3. Run `trudag score` from that directory

**Structure:**
```
project-root/
├── .dotstop_extensions/
│   └── validators.py          # Your validators live here
├── reqs/                       # Your requirements
└── artifacts/                  # Your evidence files
```

**File: `.dotstop_extensions/validators.py`**
```python
from typing import TypeAlias

yaml: TypeAlias = (
    str | int | float | bool |
    list["yaml"] |
    dict[str, "yaml"]
)

def my_custom_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    """My validator logic"""
    return (1.0, [])

# Signature matching (CRITICAL)
try:
    from trudag.dotstop.core.validator import Validator
    my_custom_validator.__signature__ = Validator._SIGNATURE
except Exception:
    pass
```

**Pros:**
- Simplest to set up
- No packaging required
- Works immediately

**Cons:**
- Only available in that directory
- Not reusable across projects
- Not testable independently

### Pattern 2: Local Package with Entry Points (Team/Project)

**Use case:** Shared validators within a team or project, reproducible builds

**How it works:**
1. Create a Python package with validators
2. Register validators as entry points
3. Install in the environment
4. Trudag discovers via entry points

**Structure:**
```
my-validators/
├── pyproject.toml             # Package metadata + entry points
├── validators/                # Package directory
│   ├── __init__.py
│   └── core.py
└── README.md
```

**File: `pyproject.toml`**
```toml
[build-system]
requires = ["setuptools>=61.2", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-validators"
version = "0.1.0"
description = "Custom validators"
requires-python = ">=3.9"
dependencies = []

[tool.setuptools.packages.find]
where = ["."]

# CRITICAL: Entry points registration
[project.entry-points."trustable.validator.plugins"]
my_validator = "validators.core:my_validator"
```

**File: `validators/core.py`**
```python
from typing import TypeAlias

yaml: TypeAlias = (
    str | int | float | bool |
    list["yaml"] |
    dict[str, "yaml"]
)

def my_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    """My validator logic"""
    return (1.0, [])

# Signature matching
try:
    from trudag.dotstop.core.validator import Validator
    my_validator.__signature__ = Validator._SIGNATURE
except Exception:
    pass
```

**Installation:**
```bash
pip install -e /path/to/my-validators
```

**Pros:**
- Reusable across projects
- Version controlled
- Can be shared with team
- Professional packaging

**Cons:**
- Requires packaging knowledge
- Need to reinstall after code changes (unless using `-e`)

---

## Python Type System & Validators

### Understanding `dict[str, yaml]`

This is a **generic type hint** that says:
- `dict` = dictionary data structure
- `[str, yaml]` = keys are strings, values are `yaml` type

The `yaml` TypeAlias allows recursive nesting:

```python
yaml: TypeAlias = (
    str |                    # Plain string
    int |                    # Integer
    float |                  # Float
    bool |                   # Boolean
    list["yaml"] |           # List of yaml values (recursive)
    dict[str, "yaml"]        # Dict with string keys and yaml values (recursive)
)
```

### Why Exact Signature Matching Matters

Python's type system works at **runtime** AND **development time**:

**Development time** (what you see in your editor):
```python
def my_validator(configuration: dict[str, yaml]) -> tuple[float, list[Exception | Warning]]:
    # IDE shows correct signature
```

**Runtime** (what Python actually sees):
```python
import inspect
sig = inspect.signature(my_validator)
# sig is a Signature object with resolved type annotations
# The yaml alias might resolve differently than expected!
```

This mismatch causes Trudag's check to fail. Solution: force runtime alignment via `__signature__` assignment.

---

## Virtual Environments and Package Isolation

### Why Pipx and Virtual Environments Matter

**Pipx** isolates applications in separate virtual environments. This is **good** for safety but **requires special handling** for package updates.

### The Pipx Installation Pattern for Trudag

When Trudag is installed via pipx (as it typically is):

```bash
pipx install trustable  # Installs Trudag in /root/.local/pipx/venvs/trustable
```

It lives in an **isolated environment**. To install packages INTO that environment:

```bash
# WRONG: Won't work
pip install my-validators  # Installs in your system Python

# CORRECT: Install into Trudag's venv
pipx runpip trustable install -e /path/to/my-validators
```

### Why Editable Install (`-e`) Is Critical

When developing validators, use editable install:

```bash
pipx runpip trustable install -e /path/to/my-validators
```

This creates a **link** to your source code instead of copying files. When you edit `validators.py`, the changes are **immediately visible** to Trudag.

### The Reinstall Pattern When Updates Don't Appear

If you've edited your validators but Trudag doesn't see the changes:

```bash
# Step 1: Uninstall
pipx runpip trustable uninstall -y my-validators

# Step 2: Reinstall
pipx runpip trustable install -e /path/to/my-validators

# Step 3: Verify
trudag validators  # Should show updated validators
```

### Checking What's Installed

```bash
# List packages in Trudag's venv
pipx runpip trustable list

# Expected output:
# trustable          2025.9.16
# my-validators      0.1.0 (/path/to/my-validators)
```

---

## Further Reading

- [Official Trudag Documentation](https://codethinklabs.gitlab.io/trustable/)
- [Python Entry Points](https://packaging.python.org/specifications/entry-points/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)
- [Pipx Documentation](https://pipx.pypa.io/)
