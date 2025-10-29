# 📄 GenAI Pair Programming

## Summary and Research Context

The core objective of Goal 5: GenAI Pair Programming in the SEA:ME module is to integrate a Generative AI assistant to boost productivity and implement best practices for code review.

Our initial research identified three main candidates: GitHub Copilot, Tabnine, and General-Purpose LLMs (Gemini/ChatGPT). The subsequent analysis, combined with the confirmation that the team has access to GitHub Copilot Pro, significantly streamlines the selection.
<br>
* **Selected Tool: GitHub Copilot Pro**
* **Development Environment: SDV Eclipse**
<br>
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
<br>
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
<br>
1- **Plugin Installation:** Install the `Copilot4Eclipse` plugin from the Eclipse Marketplace. This plugin supports both **Completions** (inline suggestions) and **Copilot Chat**.
<br>
2- **Access Configuration:** Authenticate the plugin with each team member's GitHub credentials, ensuring the Copilot Pro access is active.
<br>
3- **Prompt Engineering Training:** Focus early Pair Programming sessions on learning how to use **Copilot Chat** effectively, emphasizing commands like `/explain`, `/test`, and `/review` applied to ThreadX and UProtocol code.
<br>
### Installation Guide: Copilot4Eclipse (Step-by-Step)
To get started immediately with your already powerful tool, follow these steps to integrate it into your SDV Eclipse IDE:
<br>
1- **Open Eclipse Marketplace:** In your Eclipse IDE, go to Help → Eclipse Marketplace...
<br>
2- **Search:** In the "Find" tab, search for "**Copilot4Eclipse**".
<br>
3- **Install:** Locate the official plugin (often titled "Copilot4Eclipse") and click the Install button.
<br>
4- **Complete Installation:** Follow the prompts, accept the terms, and click Finish.
<br>
5- **Restart IDE:** Restart your Eclipse IDE when prompted to finalize the installation.
<br>
6- **Authentication:** After restarting, a prompt will usually appear to sign in or authorize your GitHub account. Follow the device code steps:
* **Copy the Device Code** provided by Eclipse.
* **Open the Authorization Link** in your browser.
* **Paste the Code and Authorize** the plugin to use your GitHub account (which has the Copilot Pro subscription).

7- **Start Coding:** Once authorized, the inline completions will begin, and you can open the Copilot Chat Panel (often found in the toolbar or under the Window → Show View menu) to access the advanced Pro features.