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

The workflow file **must** be located inside the following directory structure in your repository:

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
# The workflow runs when a pull request is opened or updated on the 'master' branch.
on:
  pull_request:
    branches: [ master ]

# 3. Jobs to Execute
jobs:
  test_pull_request:
    # 3a. Runner Environment
    runs-on: ubuntu-latest
    
    # 3b. Steps in the Job
    steps:
      # Step 1: Checkout the code from the repository
      - uses: actions/checkout@v4
      
      # Step 2: Run the actual command (e.g., install dependencies, run tests)
      - run: <your-test-command-here>

```
---

### **Continuous Deployment (CD)** (Release Code Out) 🚀

**Continuous Deployment (CD)** is the practice where every code change that passes all stages of your production pipeline (including successful CI tests) is **automatically released** to your users. It fully automates the software delivery process.
The YAML (`.yml`) file is where you define the workflow structure.

## Choice: STM32 CI (Real Hardware) — brief note

The workflow builds the firmware with the ARM toolchain, flashes the binary to the STM32 via ST‑Link, then captures UART output to verify a runtime message (e.g., "ThreadX started").

Why this option (brief):
- Real hardware (chosen): exercises the actual MCU, peripherals and timing; gives real-world validation for the STM32U5 Discovery board.
- QEMU (not chosen): easier for hosted CI but QEMU does not support the STM32U5 Discovery kit (see https://www.qemu.org/docs/master/system/arm/stm32.html), so emulation would be incomplete or unavailable for this target.

Practical notes:
- GitHub-hosted runners cannot access local USB devices. To flash and test real hardware from CI you must run the workflow on a self-hosted runner with the ST‑Link and STM32 physically connected.
- Add appropriate udev rules or run the runner user with permissions to access the ST‑Link device (and ensure the device node, e.g., /dev/ttyACM0, is correct).
- Keep the actual workflow YAML in .github/workflows when ready, but avoid running flash steps on hosted runners.

STM32 + ThreadX firmware cannot run on QEMU because QEMU only simulates a generic Cortex-M CPU, not the STM32 memory map or its hardware peripherals, causing the HAL and ThreadX to HardFault during initialization.
