# 📋 GitHub Project: Board Usage Guidelines

This document defines the structure of our Scrum/Kanban Board and the rules for moving cards, ensuring that project status is always transparent and accurate for the team and stakeholders.

## 1. Board Structure

Our Project Board (GitHub Project) consists of 6 columns, representing the workflow of our Issues (User Stories / Tasks) from conception to completion.

| Column | Definition | Entry Criteria | Purpose |
|--------|------------|----------------|---------|
|**Backlog** | High-level items (Epics) ready to be broken down, and low-priority User Stories for future Sprints | Only Epics or low-priority User Stories | Maintain the comprehensive list of work to be done |
|**Ready** | Items (Sub-Issues) that are prepared to be picked up by a developer | The Issue must have: 1- A clear description <br>2- Fulfilled the Definition of Ready (DoR) <br>3- Be assigned to a team member | The source of work for the current Sprint |
|**In Progress** | Items that are being actively worked on by a team member | The developer has started the work (code, research, or documentation) and assigned themselves to the Issue | Monitor active work and prevent developer overload (WIP) |
|**Blockers** | Development is blocked. The item needs immediate attention to identify and resolve the impediment | The Issue cannot move forward due to external dependencies, unresolved technical problems, or missing decisions | Visibly and urgently flag critical impediments for the team |
|**In Review** | The work item (code, documentation) is finished and awaiting review (Code Review / Testing) | The associated Pull Request (PR) has been created, and all local tests have passed | Ensure code quality through formal review |
|**Done** | The item is entirely completed | The PR has been approved and merged into the main branch, and the Issue can be closed | Measure team progress and throughput |

#

## 2. Card Movement Rules

The movement of Issues must be strictly followed to guarantee the integrity of project data:

    Backlog → Ready: Only during the Sprint Planning meeting.

    Ready → In Progress: Only the assigned team member can move the card.

    In Progress → Blockers: Any team member can move a card here if they encounter a critical obstacle. The Scrum Master must intervene immediately.

    Blockers → In Progress / Ready: After the impediment has been removed.

    In Progress → In Review: Happens when the Pull Request (PR) is created. The PR link must be added to the Issue description.

    In Review → Done: Only the final reviewer or the Scrum Master may move the card to Done after the PR has been merged into the main branch and the Issue is closed on GitHub.

#

## 3. Mandatory Usage Conventions

<br>

| Rule | Definition | TSF Justification |
|--------|------------|----------------|
|**Assignment** | Every Issue in the Ready column or later must be assigned to at least one team member | Ensures Accountability and clear Work-in-Progress (WIP) |
|**Labels and Epics** | All Sub-Issues must have the Label of their main Epic | Allows for Easy Readability and tracking of progress against high-level goals |
|**Iteration (Sprint)** | All active Issues must be linked to the current Iteration (2 weeks) | Essential for calculating Team Velocity and predictability |
|**PR Description** | A link to the Issue must be included in the description of every Pull Request | Provides Bidirectional Traceability between code and requirement, an TSF requirement.