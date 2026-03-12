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
