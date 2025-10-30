# 📄 GenAI Pair Programming

## Summary and Research Context

The core objective of Goal 5: GenAI Pair Programming in the SEA:ME module is to integrate a Generative Artificial Inteligence (AI) assistant to boost productivity and implement best practices for code review.

Our initial research identified three main candidates: GitHub Copilot, Tabnine, and General-Purpose LLMs (Gemini/ChatGPT). The subsequent analysis, combined with the confirmation that the team has access to GitHub Copilot Pro, significantly streamlines the selection.
<br>
* **Selected Tool: GitHub Copilot Pro**
* **Development Environment: Software Defined Vehicle (SDV) Eclipse**

## Justification for the Choice: GitHub Copilot Pro

The choice of GitHub Copilot Pro is the most strategic and cost-effective, as it is the only tool that, at no additional cost to the team, meets and exceeds all Goal 5 objectives within the required development environment.
<br>
### 1. Comprehensive Coverage of Training Goals
| SEA:ME Objective | Copilot Pro Feature | Relevance to SDV & Eclipse |
|----|-----|----|
| Techniques for Effective Pair Programming | Unlimited Inline Suggestions | Enables fast, fluid writing of C/C++ code for ThreadX and Python scripts for CARLA, acting as the constant "coding partner" |
| Best Practices for AI Code Review | Copilot Chat with /explain, /test, /review | The Chat feature (exclusive to the Pro plan) is essential for review. We can ask the AI to explain complex code or generate unit tests, elevating human code review quality | 
| Strategic Integration into Workflow | `Copilot4Eclipse` Plugin and Integrated Chat | Integrating Chat and suggestions directly into Eclipse (via the robust `Copilot4Eclipse` plugin) ensures we do not have to leave our SDV/compilation environment, minimizing friction |
| Embracing AI-driven Tools | Access to Advanced Models (GPT-4, etc.) | Guarantees the team is working with industry-leading technology, preparing them for the future of automotive software engineering |

### 2. Competitive Advantage vs. Tabnine Free
Possessing Copilot Pro makes any free alternative irrelevant for a professional-level training project:
<br>
| Factor | GitHub Copilot Pro | Tabnine Free
|---|---|---|
| AI Quality | State-of-the-Art (GPT-4/Premium Models) | Basic (Small, limited models) |
| Generation Capability | Generation of Complete Functions/Solutions | Generation of Complete Functions/Solutions | Word/Line Autocomplete (minimal assistance) |
| Cost to the Team | €0 Additional. (Already licensed) | €0 Cost, but near €0 practical value for advanced Pair Programming |
---
Our team must utilize the most powerful tool available to simulate a real engineering environment. Copilot Pro fulfills this function, whereas Tabnine Free would only provide a limited and unrepresentative experience.
<br>
### Action Plan and Next Steps
For successful integration, we propose the following action plan:

1- **Eclipse Integrated Development Environment (IDE) Installation:** Install the **Ecplise IDE for Embedded C/C++ Developers**

2- **Plugin Installation:** Install the `Copilot4Eclipse` plugin from the Eclipse Marketplace. This plugin supports both **Completions** (inline suggestions) and **Copilot Chat**.

3- **Access Configuration:** Authenticate the plugin with each team member's GitHub credentials, ensuring the Copilot Pro access is active.

4- **Prompt Engineering Training:** Focus early Pair Programming sessions on learning how to use **Copilot Chat** effectively, emphasizing commands like `/explain`, `/test`, and `/review` applied to ThreadX and UProtocol code.
<br>

## Installation Guide: Eclipse IDE for Embedded C/C++ Developers

This guide details the process for setting up the Integrated Development Environment (IDE) for firmware (C/C++) development within the SDV (ThreadX) environment.

---

**Step 1: Download the Eclipse Installer**

1- Access the official Eclipse Foundation download website.

2- Download the Eclipse Installer appropriate for your operating system (Windows, macOS, or Linux).

**Step 2: Run and Select the IDE**

1- Execute the downloaded file to start the Eclipse Installer. (e.g. ./eclipse-inst)

2- The installer will present a list of available Eclipse IDE options. Select the specific option for our development needs:

    **Eclipse IDE for Embedded C/C++ Developers**

Note: It is crucial to select the Embedded version, not the generic C/C++ version.

**Step 3: Configuration and Installation**

1- Installation Folder: Define the directory where Eclipse will be installed

2- Java Development Kit (JDK)/ Java Virtual Machine (JVM): The installer will ensure that the compatible Java Runtime Environment (necessary for Eclipse) is ready.

3- Click Install and accept the License Agreement(s) when prompted.

4- Wait for the installation to complete. This process downloads all the necessary plugins and tools specific to embedded systems development.

**Step 4: Launch the IDE and Configure the Workspace**

1- Once the installation is complete, click Launch

2- Select Workspace: Eclipse will ask you to select the Workspace directory. This is the location where all project files will be stored.

* Create a new, dedicated folder for the SEA:ME project (e.g., `~/Eclipse-Workspaces/SEA:ME`).
* Optional: Check the box "Use this as the default and do not ask again".

3- Click Launch.

---

### Installation Guide: Copilot4Eclipse (Step-by-Step)
To get started immediately with your already powerful tool, follow these steps to integrate it into your SDV Eclipse IDE:

1- **Open Eclipse Marketplace:** In your Eclipse IDE, go to Help → Eclipse Marketplace...

2- **Search:** In the "Find" tab, search for "**Copilot4Eclipse**".

3- **Install:** Locate the official plugin (often titled "Copilot4Eclipse") and click the Install button.

4- **Complete Installation:** Follow the prompts, accept the terms, and click Finish.

5- **Restart IDE:** Restart your Eclipse IDE when prompted to finalize the installation.

6- **Authentication:** After restarting, a prompt will usually appear to sign in or authorize your GitHub account. Follow the device code steps:
* **Copy the Device Code** provided by Eclipse.
* **Open the Authorization Link** in your browser.
* **Paste the Code and Authorize** the plugin to use your GitHub account (which has the Copilot Pro subscription).

7- **Start Coding:** Once authorized, the inline completions will begin, and you can open the Copilot Chat Panel (often found in the toolbar or under the Window → Show View menu) to access the advanced Pro features.
