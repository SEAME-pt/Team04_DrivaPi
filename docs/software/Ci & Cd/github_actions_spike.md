## 📝 GitHub Actions Workflow Explained

This document outlines the basic concepts of **Continuous Integration (CI)** and **Continuous Deployment (CD)** using GitHub Actions.

---

### **What is a GitHub Action Workflow?**

It's one **automated workflow** that will react to an **event**, like, for example, a **pull request**!

* It logs each **step** and makes clear what the **result** of that step was.

---

### **Continuous Integration (CI)** (Merge Code In) 🔄

Continuous Integration is the practice of merging all developers' working copies to a shared mainline several times a day. In the context of GitHub Actions, this often means automatically running tests when code is submitted.

#### **Location of the Workflow File**

The workflow file **must** be located at:

> `.github/workflows/your-workflow-name.yml`

#### **Anatomy of a Basic CI Workflow (.yml)**

### ⚙️ How the CI Process Works

This sequence explains how a Continuous Integration (CI) workflow is triggered and used to ensure code quality before merging.

1.  **Create a Pull Request:** When you make changes in a feature branch and create a **Pull Request (PR)** targeting the designated base branch (e.g., `master` or `main`).
2.  **Workflow Triggers:** GitHub automatically runs the **CI workflow** (defined in your `.yml` file) in response to the new or updated PR event.
3.  **Check for Errors:** If any step in the workflow (like building the code or running tests via the `<your-test-command-here>` step) fails, the PR check will **fail**. This blocks the PR from being merged. 
4.  **Fixing the Code:** If the checks fail, you need to fix the error in your code. Simply make the fix and **commit again** to the same feature branch. GitHub automatically reviews that new commit and re-runs the CI workflow because the original PR is still open.

```yaml
# 1. Workflow Name
name: Continuous Integration STM

# 2. Trigger Event
# The workflow runs when a pull request is opened or updated on the 'main' branch.
on:
  pull_request:
    branches: [ main ]  # or: [ main, master ]

# 3. Jobs to Execute
jobs:
  test_pull_request:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: make test  # replace with your test command, e.g., `pytest -q`
```

---

## Choice: STM32 CI (Cross-compile only) — brief note

The workflow cross-compiles the firmware with the ARM toolchain on GitHub Actions, produces the .elf/.bin artifacts, and verifies the build succeeded and that ThreadX was linked into the image (by checking symbols or expected strings). We do not flash or run tests on real hardware from CI.

Why this option (brief):
- Cross-compile only (chosen): practical for CI — no physical hardware required; verifies compilation, linking and presence of ThreadX-related symbols/strings.
- Real hardware (rejected): impractical to connect physical STM32 to every pull request or hosted runner.
- QEMU (rejected): QEMU does not provide a faithful STM32U5 / Cortex‑M33 environment for this board; previous attempts on other Cortex‑M targets produced HardFaults during initialization.

---

### **Continuous Deployment (CD)** (Release Code Out) 🚀

**Continuous Deployment (CD)** is the practice where every code change that passes all stages of your production pipeline (including successful CI tests) is **automatically released** to the users. It fully automates the software delivery process.
The YAML (`.yml`) file is where the workflow structure is defined.