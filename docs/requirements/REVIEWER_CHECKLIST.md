# Reviewer Checklist — DrivaPi Requirements

This checklist describes the review steps for requirement items managed with Doorstop/trudag.

1. Validate formatting and basic schema

```bash
python3 scripts/reqs_lint.py
```

2. Run the trustable linter (if available)

```bash
trudag --door manage lint
```

3. Human review points
- Confirm the `text` field is clear and testable.
- Confirm the `ASIL` level is correct (A, B, C, D or QM).
- Confirm `Verification Method` is appropriate (Unit Test, Integration Test, Review, Formal Analysis, Test).
- Confirm links are correct (parent and test links).

4. Approve item with trudag (this should set `reviewed` to the commit SHA)

```bash
trudag manage set-item SWD001
git add reqs
git commit -m "REQS: Approve SWD001 (reviewed)"
```

5. Baseline

Create an annotated tag for baselines when a set of requirements is approved:

```bash
git tag -a BASELINE-SWD-V1.0 -m "SWD baseline v1.0 - approved"
git push origin BASELINE-SWD-V1.0
```

Notes:
- If `trudag --door manage lint` raises errors due to tool versions, use `scripts/reqs_lint.py` to verify schema until tools are updated.
