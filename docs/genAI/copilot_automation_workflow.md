# Copilot Automation Workflow

This document describes recommended workflows and automations you can perform with GitHub Copilot (Copilot Pro and Copilot Chat) to speed up commits, pushes, Pull Request (PR) creation, issue/sub-issue creation, code review, and other developer tasks. It includes practical prompts, Command Line Interface (CLI) examples, and best practices.

> Note: This workflow assumes the team has Copilot Pro and Copilot Chat enabled, `gh` (GitHub CLI) installed and authenticated, and Git properly configured (SSH or HTTPS with credentials).

## Goals
- Use Copilot to accelerate routine tasks while keeping human reviewers in the loop.
 - Automate non-sensitive, repeatable actions (commit messages, populate existing PR/Issue templates, checklists).
- Improve traceability: ensure every PR and issue contains clear Acceptance Criteria (AC) and test steps.

## Prerequisites
- Git configured for your repo and authenticated (SSH or HTTPS).
- GitHub CLI (`gh`) installed and authenticated: `gh auth login`.
- Copilot Pro enabled and Copilot Chat available in your IDE or browser.
- Project templates in place: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/` .

## Conventions (recommended)
- Branch naming: `feat/<short-desc>`, `fix/<short-desc>`, `chore/<what>` or `spike/<topic>`.
- Commit messages: conventional commits (e.g., `feat: add energy display component`).
- PR title format: `type(scope): short summary` or `docs: genAI justification (Copilot Pro)`.
- Use PR and Issue templates to standardize metadata (AC, DoD, test steps, estimate).

## Automation capabilities with Copilot (high-level)
- Draft commit messages from diffs or editor context.
- Suggest code changes and completions inline; generate unit tests and docs.
- Populate existing PR templates and draft release notes summarizing changes.
- Suggest issue descriptions and child sub-issues from a parent task.
- Provide code review assistance (Copilot Chat `/review`, `/explain`).

## Example micro-workflows

### 1) Commit creation (local developer flow)
1. Create branch:

```bash
git checkout -b feat/energy-display
```

2. Make code changes in editor. Use Copilot to help implement or refactor code.
3. Ask Copilot Chat for a commit message:

Prompt (Copilot Chat):
"Given the following changes in the editor, write a concise conventional commit message. Include the main motivation and any backward incompatible changes."

4. Stage and commit using the suggested message:

```bash
git add -A
git commit -m "<copilot-suggested-commit-message>"
```

5. Push branch:

```bash
git push --set-upstream origin feat/energy-display
```

### 2) Create PR with Copilot-generated body
- Use Copilot Chat to generate a PR body based on the commit(s) and changed files. Example prompt:

"Create a PR body for this branch. Include summary, how to test, acceptance criteria, and risk notes. Produce the output following the sections defined in our repository PR template (`.github/PULL_REQUEST_TEMPLATE.md`)."

Use Copilot to generate text that fills the repository PR template. You have three common options to create the PR:

- Option A — Copy/paste: generate the populated template with Copilot and paste the result directly into the PR body field in the GitHub web UI.

- Option B — Temporary file + CLI: save Copilot's output to a temporary file that follows the template structure (for example `.github/pr_body_{branch}.md`) and pass it to `gh pr create`:

```bash
# example: save populated PR body and create PR
gh pr create --title "feat: energy display" --body-file .github/pr_body_feat_energy_display.md --base master --head feat/energy-display
```

- Option C — Copilot CLI Delegate (Most Automated): Use the delegation command to automate the creation process directly from your terminal. (Requires Copilot CLI):

```bash
copilot /delegate Create a new Pull Request for this branch. Use the repository template and summarize the changes.
```

### 3) Creating Issues and Sub-issues
- From a high-level task, ask Copilot to break it down into sub-issues.

Prompt (Copilot Chat):
"Break this task into 3 sub-issues with short descriptions and acceptance criteria: \n\n[Paste a short parent description]"

Copilot returns a list; use your repository issue templates to create parent and child issues. Ask Copilot to format each item following your issue template structure (for example `issue_template.md` or `sub_issue_template.md`), then either paste the resulting text into the GitHub UI or save to files and call `gh issue create --body-file`.

Example using CLI with a saved body file:

```bash
# create parent (body saved to .github/issue_parent_body.md)
gh issue create --title "Add GenAI Copilot automation workflow" --body-file .github/issue_parent_body.md

# create sub-issue and link to parent (body saved to .github/issue_sub_implement_pr_body.md)
gh issue create --title "Implement PR body generator" --body-file .github/issue_sub_implement_pr_body.md
```

Alternatively, use Copilot CLI Delegation (Recommended):

Ask Copilot CLI to directly generate and execute the required gh issue create commands, including titles, bodies, and linking (if supported by the prompt).

Example using Copilot CLI Delegation:

```bash
copilot /delegate Break this task into 3 sub-issues with titles, descriptions, and acceptance criteria, and generate the 'gh issue create' commands for each.
```

The CLI will return the generated commands for review. After your confirmation, the Issues will be created and properly formatted according to the generated output.


### 4) Code review and automated checks
- Use Copilot Chat to pre-run a code review by asking:

`/review` (in Copilot Chat) or prompt: "Review the following change and list potential bugs, missing tests, and style issues. Provide suggested fixes."

- Combine with automated CI checks (lint, unit tests, static analyzers) in GitHub Actions to block merges until passing.

### 5) Release notes and changelog drafting
- Use Copilot to draft release notes from merged PRs or commit messages.
- Example prompt: "Summarize the following merged PRs into a short release note format, grouped by type: features, fixes, docs."

## 6) Drafting Daily Logs and Summaries & Assigning a Issue and PR
Focus: Automating the final assembly and formatting of the daily progress report using the existing `daily-log-template.md`. This saves time and ensures structural consistency.

- Gather Raw Notes: During or immediately after the daily sync, collect all unformatted progress notes. This input should be simple and structured by person/topic (e.g., "Bernardo: connected CAN bus. Melanie: finished HARA doc. Hugo: ThreadX problem persists.").

- Use Copilot Chat to Format: Pass the raw notes and the template structure to Copilot Chat.

```bash
Prompt (Copilot Chat): "Take the following raw notes: [Paste ALL Raw Notes]. Now, strictly format this information into the structure of our daily-log-template.md, ensuring all sections are filled and progress is correctly marked (✅ / 🔄)."
```

- Then, we have to create a sub-issue on the already existing issue called Daily-Log. It should be associated with a pull request, with the name format "docs/#XXX-daily-dd-mm-yyyy".

```bash
Prompt (Copilot Chat): "Create a sub-issue for the existing parent issue called Daily-Log #[NUMBER], and it should be linked in the Relationships tab. It should be associated with a pull request, which you must create too, with the name format "docs/daily-dd-mm-yyyy" and the existing "documentation" label, then format it according to our pull_request_template.md file and adjusted with the relevant information for today. Also strictly format the sub-issue description into the structure of our sub_issue_template.md file, adding the existing "documentation" label and also the "task" type. Tick the boxes that apply to this daily log and add the relevant information. To finalize, assign the project contributor [REVIEWER NAME] to this Pull Request as a reviewer, and put myself on the task assignees."
```


## Sample prompts (short)
- "Write a conventional commit message for these changes: [paste diff or summary]"
- "Generate a PR body following our repository PR template: fill the template sections (summary, how to test, AC, risk/rollback steps)."
- "Break this epic into 3 sub-issues with acceptance criteria: [paste epic]."
- "/explain: explain what this function does and where it may fail"
- "/test: propose unit tests for this module"
- "/review: give a code review for the following diff"


## Security and privacy notes
- Do not paste secrets, keys, or PII into prompts when using Copilot Chat.
- Validate any generated code and test suggestions — Copilot may hallucinate or produce insecure patterns.
- Keep CI results as the final gate; human reviewers must approve changes that affect safety-critical code.

## Best practices / Guidelines
- Use Copilot for drafting, not for final approval. Always review generated text and code.
- Store standard templates in `.github/` so Copilot can reference repository conventions.
- Use short, focused prompts for predictable outputs. Iterate prompts if results are off.
- Add PR checklist items that require humans to verify critical things (security, safety, compliance).

## Example day-to-day flow (summary)
1. Create branch.
2. Implement code with Copilot assistance.
3. Ask Copilot for commit message.
4. Commit & push.
5. Ask Copilot to populate the existing PR template (or generate text that matches its sections) and save to `.github/pr_body_*.md` or paste directly into the PR body.
6. Use `gh pr create --body-file` or the web UI to open the PR.
7. Create child sub-issues if needed.
8. Use Copilot Chat `/review` to pre-review.
9. Run CI and request reviewers.

---
