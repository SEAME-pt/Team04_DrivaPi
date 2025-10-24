# 🧭 PiRacer Warm-Up Project — Product Backlog

Each backlog includes a short **User Story**, **Acceptance Criteria** and a **Testing Checklist**.

---

## 🧩 Epic 1 — Getting Familiarized with PiRacer Robot and Hardware

Epic Description

As a client, I need a fully assembled and operational PiRacer robot so that I can use it for autonomous vehicle development and demonstration purposes.

Sub-Issues (User Stories) included in this Epic

    PB-1 (Assembly and Basic Test)

    PB-2 (Raspberry Pi 5 Initial Setup)

    PB-3 (Develop Qt app)

Epic Acceptance Criteria

    PiRacer robot fully assembled with all components (Referencing PB-1 Criteria).

    Raspberry Pi 5 successfully configured and operational (Referencing PB-2 Criteria).

    All sensors and motors tested and responding correctly (Referencing PB-1 Criteria).

    Display interface functional and accessible (Referencing PB-3 Criteria).

    Documentation of hardware setup completed (Part of Epic DoD).

Definition of Done (DoD)

    All hardware components installed and tested

    System boots successfully

    Hardware configuration documented

    Team members trained on hardware handling
---

| ID | User Story | Acceptance Criteria | Testing Checklist |
|----|-----------|----------------|-----------|
| **PB-1** | Initial configuration of the Raspberry Pi 5 including OS installation, network setup, and basic system configuration. Focus on installing necessary toolchains for Rust/C++ development. | 1- Motors respond to forward/reverse commands <br>2- Speed control works across full range (0-100%) <br>3- Motor direction is consistent and correct <br>4- Servo motors respond to software commands <br>5- Steering response is smooth and predictable | 1- Forward motion test at various speeds <br>2- Reverse motion test at various speeds <br>3- Gradual acceleration and deceleration tested <br>4- Left turn command executes correctly <br>5- Right turn command executes correctly 6- Center/straight position verified |
| **PB-2** | As a developer, I want to boot the Raspberry Pi 5 with a Linux environment that supports Qt, so I can develop GUI applications. | 1- Raspberry Pi 5 boots successfully <br>2- Network connectivity established <br>3- All system updates applied <br>4- Development environment (Rust/C++) ready | 1- Boot test successful <br>2- Network ping test passed <br>3- Basic Rust/C++ script execution tested |
| **PB-3** | Develop a basic Qt-based GUI application that runs on the PiRacer display, showing system status and providing control options. This confirms the display and Qt environment functionality. | 1- GUI application launches on PiRacer display <br>2- All UI elements render correctly <br>3- Application is stable and doesn't crash | 1- Application startup verified <br>2- All buttons and controls functional <br>3- Touch/mouse input works properly <br>4- Application can be closed gracefully

#

## 💻 Epic 2 — Git and GitHub Mastery

Epic Description

As a project stakeholder, I need robust version control and collaboration practices so that code quality is maintained, changes are tracked, and the team works efficiently without conflicts.

Sub-Issues (User Stories) included in this Epic

    PB-4 (GitHub Repository Setup and Configuration)

    PB-5 (Branching Strategy Definition and Documentation)

    PB-6 (Pull Request Workflow and Code Review Process)

Epic Acceptance Criteria

    All team members proficient with basic Git operations.

    GitHub repository properly configured (Referencing PB-4 Criteria).

    Branching strategy defined and followed (Referencing PB-5 Criteria).

    Code review process established (Referencing PB-6 Criteria).

Definition of Done (DoD)

    Repository structure established.

    First successful pull request merged.

    Team demonstrates version control proficiency.

---

| ID | User Story | Acceptance Criteria | Testing Checklist |
|----|-----------|----------------|-----------|
| **PB-4** | Create and configure the main GitHub repository with appropriate settings, protections, and structure, so that code is protected, organized, and accessible to the team. | - Repository created and accessible to all team members <br>2- Branch protections prevent direct pushes to main <br>3- Repository structure clear and organized <br>4- README provides project overview <br>5- Templates facilitate consistent issues and PRs | 1- Repository fully configured <br>2- All team members have access <br>3- Initial commit with project structure pushed <br>4- Documentation complete |
| **PB-5** | Define and document a clear branching strategy so that the team can work on features independently and integrate code smoothly. | 1- Branching strategy documented clearly <br>2- Naming conventions defined <br>3- Workflow diagram created <br>4- All team members understand strategy <br>5- Documentation available in repository | 1- Documentation complete and reviewed <br>2- Team training completed <br>3- First feature branch created following strategy
| **PB-6** | Define and implement a structured PR and code review process so that code quality is maintained and knowledge is shared across the team. | 1- PR workflow clearly documented <br>2- All team members understand review process <br>3- PR template enforces required information <br>4- Code review standards defined <br>5- First PRs successfully reviewed and merged | 1- PR created following template <br>2- Review conducted with feedback <br>3- Revisions made based on feedback <br>4- Approval granted <br>5- PR merged successfully |

#

## 🧱 Epic 3 — Implementing Scrum and Agile Methodologies

Epic Description

As a project stakeholder, I need the development team to follow structured Agile practices so that I have visibility into progress, predictable delivery, and continuous improvement.

Sub-Issues (User Stories) included in this Epic

    PB-7 (Team Organization and Role Assignment - formerly #12)

    PB-8 (Sprint Planning and Schedule Setup - formerly #13)

    PB-9 (Scrum Board Creation and Maintenance - formerly #14)

    PB-10 (Daily Stand-up Implementation - formerly #15)

Epic Acceptance Criteria

    Team organized with defined roles (Referencing PB-7 Criteria).

    Sprint cycles established and running (Referencing PB-8 Criteria).

    Scrum board actively maintained (Referencing PB-9 Criteria).

    Scrum ceremonies implemented and attended (Referencing PB-10 Criteria).

    Team demonstrates understanding of Agile principles.

Definition of Done (DoD)

    Scrum framework fully implemented.

    All team members trained on Agile practices.

    First sprint completed successfully.

    Retrospective conducted with actionable improvements.

---

| ID | User Story | Acceptance Criteria | Testing Checklist |
|----|-------------|--------------------|-----------|
| **PB-7** | As a project stakeholder, I want clearly defined team roles and responsibilities so that accountability is clear and work flows efficiently. | 1- All roles clearly assigned <br>2- Team members understand their responsibilities <br>3- Communication channels active and tested <br>4- Team agreement on working practices | 1- Roles documented in project <br>2- Communication tools set up <br>3- First team meeting conducted |
| **PB-8** | Define sprint duration, schedule ceremonies, and conduct first sprint planning session, so that the team delivers value incrementally and predictably. | 1- Sprint schedule documented and shared <br>2- First sprint backlog defined with estimates <br>3- Sprint goal clearly articulated <br>4- Team commits to sprint deliverables | 1- Sprint schedule published <br>2- Sprint backlog populated in GitHub <br>3- Sprint goal documented <br>4- Team alignment achieved |
| **PB-9** | Set up a Scrum board using GitHub Projects with proper columns and automation, so that a visual Scrum board reflects real-time progress and everyone can identify blockers quickly. | 1- Scrum board visible and accessible to all team members <br>2- All sprint items represented on board <br>3- Board columns clearly defined <br>4- Automation working correctly <br>5- Team members updating board daily | 1- Board created and configured <br>2- All sprint items added <br>3- Team trained on usage <br>4- Board usage guidelines documented | 
| **PB-10** | Establish daily stand-up routine with clear format and time-boxing, and implement other ceremonies, so that we stay synchronized, identify blockers early, and maintain momentum. | 1- Daily stand-ups scheduled and occurring regularly <br>2- All team members participate <br>3- Meetings stay within 15-minute time-box <br>4- Blockers identified and tracked <br>5- Stand-up and Retrospective notes documented | 1- Stand-up routine established <br>2- First sprint ceremonies completed <br>3- Team feedback collected and adjustments implemented

#

## 🧠 Epic 4 — Trustable Software Framework (TSF) Implementation

Epic Description

As a project stakeholder, I need the team to implement Trustable Software Framework practices so that the software meets automotive industry safety and reliability standards through proper requirements management, traceability, and verification.

Sub-Issues (User Stories) included in this Epic

    PB-11 (TSF Fundamentals and Automotive Standards Training)

    PB-12 (Requirements Definition and Documentation)

    PB-13 (Traceability Matrix Creation and Maintenance)

Epic Acceptance Criteria

    Requirements defined and documented (Referencing PB-12 Criteria).

    Traceability matrix established (Referencing PB-13 Criteria).

    Software architecture documented (This will be fully addressed in Epic 5).

    Documentation meets automotive standards (Formalized in Epic 7).

Definition of Done (DoD)

    TSF processes established and followed.

    Deliverables meet quality standards.

    Team demonstrates TSF competency (Referencing PB-11).
---


| ID | User Story | Acceptance Criteria | Testing Checklist |
|----|-------------|--------------------|----------|
| **PB-11** | Provide comprehensive research on TSF concepts, automotive standards (ISO 26262, ASPICE), and their practical application, so that the team can develop software that meets industry safety and reliability requirements. | 1- Team understands basic automotive standards <br>2- Members can explain traceability importance <br>3- Team recognizes safety-critical development differences <br>4- Quick reference guide available | 1- Assessment confirms understanding <br>2- Reference materials published in docs/tsf/ <br>3- Team ready to apply TSF principles |
| **PB-12** | Define, document, and maintain software requirements following TSF principles with proper structure and traceability IDs, so that the development team knows exactly what to build and we can verify completeness. | 1- Requirements follow consistent format <br>2- Requirements are clear, testable, and traceable <br>3- Hierarchical relationship established (user → system → software) <br>4- Requirements reviewed and approved <br>5- Baseline version controlled | 1- Requirements document complete <br>2- Team review completed <br>3- Baseline version approved |
| **PB-13** | Create and maintain a comprehensive traceability matrix tracking all artifacts through the development lifecycle, so that they can ensure complete coverage and compliance for L0 requirements. | 1- Links established to design, code, and tests <br>2- Bidirectional traceability functional <br>3- Coverage gaps identified (if any) <br>4- Matrix is maintainable and accessible 5. Tool/format approved by team | 1- Matrix created with all current items (L0/L1) <br>2- Matrix review process established <br>3- Documentation on matrix usage complete | 


#
<br>
<br>

# 🧭 Prioritized Product Backlog (Epics 1-4)

The priorities below are assigned based on TSF best practices: Foundation (Must), Governance (Must/Should), and Core TSF Practices (Must).

## Epic 1: Hardware and Initial Setup

| ID | User Story Focus | L0 link | Priority (MoSCoW)
|----|------------------|---------|------------------|
|**PB-1** | Assemblage & Basic Actuator Control | L0-1 | **Must** |
|**PB-2** | RPi 5 Initial Setup & Toolchain Config | L0-2 | **Must** |
|**PB-3** | Develop Basic Qt GUI Application | L0-3 | **Must** |

## Epic 2: Git and GitHub Mastery

 ID | User Story Focus | L0 link | Priority (MoSCoW)
|----|------------------|---------|------------------|
|**PB-4** | GitHub Repository Setup and Configuration | L0-4 | **Must** |
|**PB-5** | Branching Strategy Definition and Documentation | L0-5 | **Must** |
|**PB-6** | Pull Request Workflow and Code Review Process | L0-6 | **Must** |


## Epic 3: Implementing Scrum and Agile Methodologies

 ID | User Story Focus | L0 link | Priority (MoSCoW)
|----|------------------|---------|------------------|
|**PB-7** | Team Organization and Role Assignment | L0-7 | **Must** |
|**PB-8** | Sprint Planning and Schedule Setup | L0-8 | **Must** |
|**PB-9** | Scrum Board Creation and Maintenance | L0-9 | **Should** |
|**PB-10** | Daily Stand-up Implementation and Retrospectives | L0-10 | **Should** |

## Epic 4: Trustable Software Framework (TSF) Integration

 ID | User Story Focus | L0 link | Priority (MoSCoW)
|----|------------------|---------|------------------|
|**PB-11** | TSF Fundamentals and Automotive Standards Training | L0-11 | **Must** |
|**PB-12** | Requirements Definition and Documentation | L0-12 | **Must** |
|**PB-13** | Traceability Matrix Creation and Maintenance | L0-13 | **Must** |

#

## ✅ Summary Table — Product Backlog Overview

| Epic | # Stories | Priority Breakdown (M/S/C) |
|-------|------------|-----------------------------|
| **Hardware and Initial Setup** | 3 | 3M |
| **Git and GitHub Mastery** | 3 | 3M |
| **Implementing Scrum and Agile Methodologies** | 4 | 2M, 2S |
| **TSF Core Integration** | 3 | 3M |

---

<br>
<br>

📅 *Last Updated:* October 2025  
👥 *Maintainers:* 
