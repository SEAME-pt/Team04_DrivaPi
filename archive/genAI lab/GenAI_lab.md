# GenAI Full Automation Lab
**Goal:** Implement the complete Issue Delegation and Content Generation workflow, ensuring all team members are proficient with the Copilot CLI for automation and standardization.

**Estimated time:** 15-20 minutes

## Phase 1: Standardized Setup (5 minutes)

Participants must use the terminal for these steps to ensure a standardized starting point, regardless of their IDE.

| Tool | Command/Check | Description |
|------|------|------|
| Copilot CLI | npm install -g @github/copilot | Installs the Copilot CLI globally
| Copilot CLI | copilot | Launch the Copilot CLI
| Copilot CLI | /login | Authorization: Follow the browser prompts to link the CLI to your GitHub account
| GitHub CLI | gh auth login | Authorization: Log in to GitHub to allow gh commands (which Copilot uses)
| Verification | /help | Confirms that both the installation and authentication were successful
| Raw Data | (Manual) | Preparation: Each member should write down (or copy) 2-3 unique lines of "raw notes" about their individual progress today

## Phase 2: Execution of the Full Workflow (10–15 minutes)

This workflow simulates a real task assignment, with each team member responsible for their own branch creation and documentation submission.


| Objective | Tool | Command & Action |
|------|------|------|
| Sub-Issue Creation | Create the specific task for the Daily Log, linking it to the Parent Issue | Prompt: copilot /delegate Create a new GitHub sub-issue titled "Daily Test: Individual (your name) Log Submission" that is linked to the sub-Issue #83. Use the Sub-Issue Template and assign it to me. |
| Branch Association | Create a local branch linked to the new Sub-Issue ID | Prompt: copilot /delegate Create a Git branch for Issue #[Sub-Issue ID] using the prefix "docs/" |
| Fill the template using individual raw notes | Copilot Chat | Prompt: "Take the following raw notes: [Paste your Raw Notes]. Format this strictly into the structure of our daily-log-template.md, using checkmarks (✅/🔄)
| Save the file, then automate the commit/push | Manual / Copilot CLI | 1. Save output to a unique file (e.g., docs/lab/log-myname.md) <br> 2. Execute: Add all changes, create a conventional commit message with the scope 'doc', and push the branch to origin.
| Finalize the submission for review | Copilot CLI | Execute: Create a Pull Request to merge into master. Use the PR template

<br>

**Wrap-Up and Verification (5 minutes)**

**Verification:** Everyone confirms their respective Pull Request is live on GitHub. The PR body should automatically reference and close the individual "Daily Test" sub-issue.

**Conclusion:** This exercise demonstrated that the Copilot CLI allows us to unify our workflow and delegate the most complex, multi-step Git/GitHub operations in a single command, making the AI the new base layer of our development process.
