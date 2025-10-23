# TSF Hands-on Lab and Assessment

**Objective:** Completing this lab certifies you as an official **TSF Reviewer** for the DrivaPi's project.

**Format:** Work in pairs. Decide who will be the "Author" and who will be the "Reviewer".

---

## Prerequisites

Before you begin, ensure both pair members have:
1.  Cloned the `Team04_DrivaPi` repository.
2.  Activated the virtual environment: `source .venv/bin/activate`.
3.  Installed and working TSF tools (`trudag --version`).
4.  Change to working branch  `git checkout docs/17-tsf-fundamentals-and-automotive-standards-training`.

see [start.md](start.md) for setup instructions.

---

## The Scenario

The DrivaPi team needs to monitor the battery voltage to prevent unexpected power failures. Your task is to add the high-level requirements for this new feature.

**Feature:** Battery Voltage Monitoring.
**User Requirement (URD):** The user must be alerted when the battery is low.
**System Requirement (SRD):** The system must continuously read the ADC (Analog-to-Digital Converter) voltage sensor.

---

## Lab Tasks

### Task 1: The Author Creates the Requirements (15 min)

The **Author** performs these steps. The Reviewer observes.

1.  **Create the Branch:**
    ```bash
    git checkout -b feat/URD-002-battery-monitor
    ```

2.  **Activate Environment:**
    ```bash
    source .venv/bin/activate
    ```

3.  **Create the URD (Expectation):**
    ```bash
    trudag manage create-item URD 002 reqs/urd
    ```

4.  **Edit the URD:** Open `reqs/urd/URD-002.md`. **Use `id:` not `ref:`**.
    * **id:** `URD-002`
    * **header:** "Low Battery Alert for User"
    * **text:** "The system SHALL visually alert the user on the dashboard when the battery voltage drops below 10.5V."
    * **ASIL:** `A`
    * **reviewers:** Add the name and email of your partner (the Reviewer).
    * **reviewed:** `''`

5.  **Create the SRD (Assertion):**
    ```bash
    trudag manage create-item SRD 002 reqs/srd
    ```

6.  **Edit the SRD:** Open `reqs/srd/SRD-002.md`. Use `id:`.
    * **id:** `SRD-002`
    * **header:** "Continuous Battery Voltage Monitoring"
    * **text:** "The system SHALL read the ADC voltage sensor (pin ADC1_IN1) at a frequency of 1Hz and report the value in millivolts."
    * **ASIL:** `A`
    * **links:** `- URD-002`
    * **reviewers:** Add the name and email of your partner (the Reviewer).
    * **reviewed:** `''`

7.  **Link the Requirements (Traceability):**
    ```bash
    trudag manage create-link SRD-002 URD-002
    ```

### Task 2: The Author Validates and Submits the PR (10 min)

1.  **Validate Locally & Update Index (CRITICAL):**
    ```bash
    trudag manage lint
    ```
    *(Fix any errors. Ensure `id:` is used.)*

2.  **Commit Changes:**
    ```bash
    git add reqs/urd/URD-002.md reqs/srd/SRD-002.md .dotstop.dot
    git commit -m "feat(reqs): Add URD-002 and SRD-002 for battery monitoring"
    ```

3.  **Push and Pull Request:**
    ```bash
    git push -u origin feat/URD-002-battery-monitor
    ```
    Go to GitHub, create a **Pull Request (PR)** to the **18-requirements-definition-and-documentation** branch, and assign it to the **Reviewer**.

### Task 3: The (CI/CD) Reviewer Validates (5 min)

Both members observe the PR on GitHub.
1.  Wait for the "Requirements Checks (TSF Official)" check to complete.
2.  Verify the comment shows "✅ PASSED" for `trudag lint`, `trudag score`, and `trudag publish`.

### Task 4: The (Human) Reviewer Approves (10 min)

Now, the **Reviewer** takes control.

1.  **Get the Branch:**
    ```bash
    git fetch origin
    git checkout feat/URD-002-battery-monitor
    ```

2.  **Activate Environment:**
    ```bash
    source .venv/bin/activate
    ```

3.  **Critical Review:** Check the files `URD-002.md` and `SRD-002.md`.
    * Text clear, testable, unambiguous?
    * ASIL `A` appropriate?
    * Link correct (SRD -> URD)?
    * `id:` field used?

4.  **Approve - Step 1: Update Tool State:** Run `set-item` for both requirements to clear the "Unreviewed" status internally.
    ```bash
    trudag manage set-item URD-002
    trudag manage set-item SRD-002
    # Since we just created the link, consider marking it reviewed too:
    # trudag manage set-link SRD-002 URD-002
    # OR use set-item with --links if applicable:
    # trudag manage set-item URD-002 --links
    # trudag manage set-item SRD-002 --links
    ```
5.  **Approve - Step 2: Manually Edit Files:** Open *both* `reqs/urd/URD-002.md` and `reqs/srd/SRD-002.md`. Manually change the `reviewed:` field in each.
    ```yaml
    reviewed: "YYYY-MM-DD - Approved by [Your Name] <[Your Email]>"
    ```

6.  **Final Validation:**
    ```bash
    trudag manage lint
    ```
    *(Ensure no "Unreviewed" or "Suspect" warnings appear for URD-002/SRD-002)*

7.  **Commit Both Approval Changes:** Add the manually edited `.md` files AND any changes `set-item` made to `.dotstop.dot`.
    ```bash
    git add reqs/urd/URD-002.md reqs/srd/SRD-002.md .dotstop.dot # Add all changed files
    git commit -m "review(reqs): Approve URD-002 and SRD-002"
    ```

8.  **Push the Approval:**
    ```bash
    git push
    ```

### Task 5: Merge and Verify (5 min)

1.  **Merge:** On GitHub, the **Reviewer** formally approves the PR and clicks **"Merge Pull Request"**.
2.  **Final Verification (Both):**
    ```bash
    git checkout main
    git pull origin main
    trudag publish --output-dir artifacts/trustable-report
    ```
    Open `artifacts/trustable-report/dashboard.md` and verify the new requirements appear correctly.

---

## Completion
Congratulations! You have successfully created, reviewed, and approved new requirements using the TSF framework. You are now certified as an official **TSF Reviewer** for the DrivaPi's project.
