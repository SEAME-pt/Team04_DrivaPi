# Pull Request Creation Instructions

When asked to create a pull request:

## 1. Branch Validation
- **ALWAYS check current branch first**: Run `git branch --show-current`
- **DO NOT create PR from `master`**: If on master, stop and ask the user to switch to a feature branch
- Valid branch: Any branch except `master`

## 2. Identify Requesting User
- Get the GitHub username of the requester from context
- Map to team member:
  - `AfonsoMota-132` → Afonso (Qt Development)
  - `berestv` → Bernardo (Hardware Integration & Testing)
  - `Zahhask45` → Gaspar (OS & Development Environment)
  - `hugofslopes` → Hugo (Hardware & Fabrication)
  - `melaniereis` → Melanie (GUI & Team Coordination)
  - `Biltes` → Miguel (GitHub Project & Agile/Scrum)

## 3. Assignee
- **ALWAYS assign the requesting user** as the assignee of the PR
- Use their GitHub username (e.g., `@berestv`, `@Zahhask45`, etc.)

## 4. Reviewers Selection

### Standard PRs (Non-Daily Log)
- **Requires 2 reviewers**
- **NEVER assign Copilot/AI as reviewer**
- Selection logic:
  1. **User specifies 2 reviewers**: Use both specified reviewers
  2. **User specifies 1 reviewer**: Use that reviewer + 1 random team member (excluding requester)
  3. **User specifies 0 reviewers**: Select 2 random team members (excluding requester)
- Team members pool (excluding requester):
  - `@AfonsoMota-132` (Afonso)
  - `@berestv` (Bernardo)
  - `@Zahhask45` (Gaspar)
  - `@hugofslopes` (Hugo)
  - `@melaniereis` (Melanie)
  - `@Biltes` (Miguel)

### Daily Log PRs (Special Case)
- **Requires 1 reviewer only**
- **Reviewer is the next person in the daily log rotation** (next weekday, accounting for rotation):
  - Check current week rotation to determine who is on duty
  - Week 1: Mon-Gaspar, Tue-Hugo, Wed-Melanie, Thu-Bernardo, Fri-Miguel (Afonso off)
  - Week 2: Mon-Afonso, Tue-Hugo, Wed-Melanie, Thu-Bernardo, Fri-Miguel (Gaspar off)
  - Week 3: Mon-Gaspar, Tue-Afonso, Wed-Melanie, Thu-Bernardo, Fri-Miguel (Hugo off)
  - Week 4: Mon-Gaspar, Tue-Hugo, Wed-Afonso, Thu-Bernardo, Fri-Miguel (Melanie off)
  - Week 5: Mon-Gaspar, Tue-Hugo, Wed-Melanie, Thu-Afonso, Fri-Miguel (Bernardo off)
  - Week 6: Mon-Gaspar, Tue-Hugo, Wed-Melanie, Thu-Bernardo, Fri-Afonso (Miguel off)
  - Reviewer is whoever is assigned to the next weekday in that week's rotation
- Detect daily log PR by:
  - Branch name contains `daily` or `standup`
  - Changes only in `docs/standups/` directory
  - PR title contains "daily log" or "standup"

## 5. PR Template Format
Follow the template at `.github/PULL_REQUEST_TEMPLATE.md`:

```markdown
# Pull Request

**Related issue(s):** <!-- e.g. closes #123 -->

## Type of change
- [ ] feat: A new feature
- [ ] fix: A bug fix
- [ ] docs: Documentation only changes
- [ ] style: Formatting, missing semicolons, etc (no code change)
- [ ] refactor: Code change that neither fixes a bug nor adds a feature
- [ ] perf: A code change that improves performance
- [ ] test: Adding or updating tests
- [ ] ci: CI configuration changes
- [ ] chore: Maintenance tasks
- [ ] spike: Investigation / research

## Summary
Provide a concise summary of what changed and why.

## How to test / Validation
Describe steps the reviewer can follow to validate the change.

## Checklist
- [ ] I have run the project tests locally and they pass
- [ ] CI checks are green for this branch (or I will fix any failures)
- [ ] I have added or updated tests where applicable
- [ ] I have updated documentation (if applicable)
- [ ] I have added/updated any migration notes (if database or protocol changes)
- [ ] I have requested appropriate reviewers and added labels if needed
- [ ] This PR contains no secrets or sensitive data

## Risks and backward compatibility
List any known risks, migration steps, or breaking changes. If none, write "None".

## Related / dependent PRs
List other PRs that must be merged alongside this one, or related PR links.

---
**Approval:** Requires a minimum of **2** approvals.
**Action:** The feature branch **MUST** be deleted upon successful merge.
```

## 6. Pre-PR Checks
Before creating the PR:
1. Check current branch: `git branch --show-current`
2. Check for uncommitted changes: `git status`
3. Verify branch is pushed to remote: `git push -u origin $(git branch --show-current)`
4. Get diff summary: `git diff master...HEAD --stat`

## 7. PR Creation Command
Use GitHub CLI (`gh`) to create the PR:

```bash
gh pr create \
  --title "Your PR Title" \
  --body "$(cat pr_body.txt)" \
  --assignee username \
  --reviewer reviewer1,reviewer2 \
  --base master
```

## 8. Critical Rules
- ✅ **DO**: Assign the requesting user
- ✅ **DO**: Use 2 reviewers for standard PRs
- ✅ **DO**: Use 1 reviewer for daily log PRs (next in rotation)
- ✅ **DO**: Follow the PR template structure
- ✅ **DO**: Select random reviewers from team members (excluding requester)
- ❌ **NEVER**: Create PR from `master` branch
- ❌ **NEVER**: Assign Copilot/AI as a reviewer
- ❌ **NEVER**: Assign the requester as their own reviewer
- ❌ **NEVER**: Skip the PR template format

## 9. Examples

### Example 1: Standard PR with no reviewers specified
- Requester: `@melaniereis` (Melanie)
- Assignee: `@melaniereis`
- Reviewers: 2 random from [`@berestv`, `@Zahhask45`, `@hugofslopes`, `@Biltes`]

### Example 2: Standard PR with 1 reviewer specified
- Requester: `@hugofslopes` (Hugo)
- User specifies: `@berestv`
- Assignee: `@hugofslopes`
- Reviewers: `@berestv` + 1 random from [`@Zahhask45`, `@melaniereis`, `@Biltes`]

### Example 3: Daily Log PR (Wednesday)
- Requester: `@melaniereis` (Melanie - Wednesday log)
- Assignee: `@melaniereis`
- Reviewer: `@berestv` (Bernardo - next in rotation after Wednesday)

### Example 4: User on master branch
- Current branch: `master`
- Action: **STOP** and respond: "Cannot create PR from master branch. Please switch to a feature branch first using `git checkout -b feature-branch-name`"
