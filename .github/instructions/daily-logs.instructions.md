# Daily Log Instructions

When asked to create or update daily logs:

1. **Identify the requesting user first**: Before anything else, determine who is asking — by GitHub username, name mentioned in the prompt, or context. Map them to their assigned weekday using the GitHub username mapping below. This determines which day's log to create.
2. **Daily logs are never written on the same day**: The log date is always the author's assigned weekday in the past — never today. Logs can be created the next day or several days later, but never on the day itself. Always use `date -d "last [weekday]"` to find the most recent occurrence of the author's assigned day.
3. **Location**: Store logs in `docs/standups/YYYY-MM-DD.md`
4. **Format**: Use ISO date format (YYYY-MM-DD) for filenames
5. **Day Counter**: Track day number in header (check previous logs to increment)
6. **Team Members**: Afonso, Bernardo, Gaspar, Hugo, Melanie, Miguel

7. **Date Detection & Assignment**:
   - The team uses a **6-week rotating schedule** where Afonso covers for one person each week
   - **Week 1 Start Date**: February 23, 2026 (Monday)
   - Determine current week: `((weeks_since_feb_23_2026) % 6) + 1`
   - **Rotation Schedule**:
     - **Week 1**: Mon-Gaspar, Tue-Hugo, Wed-Melanie, Thu-Bernardo, Fri-Miguel (**Afonso off**)
     - **Week 2**: Mon-**Afonso**, Tue-Hugo, Wed-Melanie, Thu-Bernardo, Fri-Miguel (Gaspar off)
     - **Week 3**: Mon-Gaspar, Tue-**Afonso**, Wed-Melanie, Thu-Bernardo, Fri-Miguel (Hugo off)
     - **Week 4**: Mon-Gaspar, Tue-Hugo, Wed-**Afonso**, Thu-Bernardo, Fri-Miguel (Melanie off)
     - **Week 5**: Mon-Gaspar, Tue-Hugo, Wed-Melanie, Thu-**Afonso**, Fri-Miguel (Bernardo off)
     - **Week 6**: Mon-Gaspar, Tue-Hugo, Wed-Melanie, Thu-Bernardo, Fri-**Afonso** (Miguel off)
   - GitHub username mapping:
     - `AfonsoMota-132` → Afonso (rotates, off Week 1)
     - `Zahhask45` → Gaspar (Monday, off Week 2)
     - `hugofslopes` → Hugo (Tuesday, off Week 3)
     - `melaniereis` → Melanie (Wednesday, off Week 4)
     - `berestv` → Bernardo (Thursday, off Week 5)
     - `Biltes` → Miguel (Friday, off Week 6)
   - **Date Determination Logic** (if no date specified in prompt):
     1. Identify the requesting user (name or GitHub username)
     2. Map them to their assigned weekday using the GitHub username mapping above
     3. Check the rotation schedule to confirm they are on duty this week (Afonso rotates)
     4. Use `date -d "last [weekday]" +%Y-%m-%d` to get the date of their most recent assigned day
     5. Use that date for the new daily log
     - If user explicitly specifies a date in the request, use that date regardless of rotation
   - Note: Any team member can create logs for another day if explicitly requested (e.g., covering for sick team member)
   - **Check Previous Log**: Always check and read the daily log from the day before the target date to:
     - Get correct day counter (increment by 1)
     - Reference ongoing work or blockers
     - Maintain continuity in navigation footer

8. **Required Sections**:
   - Header with Day #, Date (Weekday, Month DD, YYYY), Team
   - "What We Did Today" - 2-3 sentence overview
   - "Team Progress" - Per person with ✅ Done and 🔄 In progress items
   - "Hardware" - Physical work with optional images
   - "Software" - Progress with ✅/🔄 status indicators
   - "Challenges" - Format: Problem, Who, Impact (High/Medium/Low), Solution
   - "Decisions" - Important technical choices made
   - "Standards & Research" - Relevant standards/research work
   - Navigation footer with Previous/Next links

9. **Team Roles**:
   - Afonso: Qt Development
   - Bernardo: Hardware Integration & Testing
   - Gaspar: OS & Development Environment
   - Hugo: Hardware & Fabrication
   - Melanie: GUI & Team Coordination
   - Miguel: GitHub Project & Agile/Scrum

10. **Status Indicators**:
   - ✅ Completed items
   - 🔄 In progress items

11. **Images**: Use `![Description](../photos/filename.jpeg)` or HTML `<img>` tags

12. **Reference template** at `docs/standups/daily-log-template.md` for exact format
13. **Check Git Activity**: Before creating the log, review:
    - Commits from that day using `git log --since="YYYY-MM-DD 00:00" --until="YYYY-MM-DD 23:59" --oneline --all`
    - Pull requests from that day (merged, opened, or closed)
    - Use this information to accurately populate Team Progress and Software sections

---

## ⚠️ Critical Priority: User Input First

**ALWAYS prioritize information provided by the user** (raw notes, prompt, direct input) as the source of truth. Use git logs to verify and add technical details, NOT to override user-provided information.

### Workflow:
1. **Accept user input as given**: If raw_notes.txt says Gaspar did X on Monday, that's the primary source
2. **Use git logs to verify & enhance**: Cross-check with git logs to add commit details, technical depth, and accuracy
3. **Never override user input with git logs**: If git shows different work on a different date, ASK FOR CLARIFICATION instead of changing the user's stated facts
4. **Ask clarifying questions**: When user input conflicts with git logs, ask which is correct rather than assuming

### Example:
- ❌ WRONG: User says "Brake work today" → I find brake commits on a different date → I move it to that date
- ✅ CORRECT: User says "Brake work today" → I find brake commits elsewhere → I ask "Did you mean the brake commits from March 24, or is there different brake work from today?"

---

## Git Log Usage Guidelines

13. **Check Git Activity**: Use git logs to SUPPORT and VERIFY user input, NOT to replace it:
    - `git log --since="YYYY-MM-DD 00:00" --until="YYYY-MM-DD 23:59" --oneline --all` to find commits matching the date
    - Verify commit authors to confirm who did the work
    - Extract detailed commit messages to add technical depth to team progress
    - Cross-reference multiple branches (`--all`) for complete work visibility

### When Using Git Logs:
- Use them to ADD DETAILS to user-provided work (e.g., commit hashes, detailed change descriptions)
- Use them to CONFIRM the user's stated facts (e.g., verify the person really did make commits that day)
- Use them to FILL GAPS in user input (e.g., if user didn't mention specific work, add found commits)
- **NEVER use them to CONTRADICT user input** without asking first

---

## ⚠️ Common Mistakes to Avoid

1. **Don't override user input with git logs**: If the user says work happened on a date, trust that. Use git logs to verify and add details, but don't change the user's stated facts.

2. **Don't invent work without user confirmation**: If git logs show work you didn't see in user input, ask before adding it. Don't assume the user forgot to mention it.

3. **Ask clarifying questions**: When user input conflicts with git logs (e.g., "brake was today not yesterday"), use that feedback to understand the correct facts. Next time, ask first instead of assuming.

4. **Verify commit authors carefully**: Use `git log --author="username"` or check commit details to match people to their work. Cross-reference GitHub usernames with real names.

5. **Document what the user told you**: The daily log should reflect what the user provided in raw notes/prompts, enhanced with git commit details.

6. **Check commit messages for TODO items**: Some commits include "TODO" comments. These indicate incomplete work and should be marked as 🔄 In Progress, not ✅ Completed.

7. **Use date context from user input as primary**: If user provides a date (either directly or via raw notes), that's the correct date for the log. Don't "correct" it based on git logs without asking.

