---
active: true
derived: false
level: 1.2.1
links: []
normative: false
ref: ''
reviewed: fa2b4344d8d00a6c69c3077d54effb284062ff87878aa911e9ee7f0648c37f2f
---

**Guidance**

To satisfy this assertion, the components and tools used to construct and verify DrivaPi releases need to be identified and assessed, to identify available sources of evidence about these dependencies.

For components, we need to consider how their potential misbehaviours might impact our expectations for DrivaPi, identify sources of information (e.g., bug databases, published CVEs) that can be used to identify known risks or issues, and tests that can be used to identify these.

For the tools we use to construct and verify DrivaPi, we need to consider how their misbehaviour might lead to an unintended change in DrivaPi, or fail to detect misbehaviours during testing, or produce incorrect or incomplete data that we use when verifying a DrivaPi release.

Where impacts are identified, we need to consider both how serious they might be (severity) and whether they would be detected by another tool, test or manual check (detectability).

For impacts with a high severity and/or low detectability, additional analysis should be done to check whether existing tests are effective at detecting the misbehaviours or resulting impacts, and new tests or Expectations should be added to prevent or detect misbehaviours or impacts that are not currently addressed.

**Evidence**

- List of components used in construction of DrivaPi
- Record of component assessment:
    - Originating project and version
    - Date of assessments and identity of assessors
    - Role of component in DrivaPi
    - Sources of bug and risk data for the component
    - Potential misbehaviours and risks identified and assessed
- List of tools used in construction and verification
- Record of tool impact assessments:
    - Originating project and version of tool
    - Date of assessments and identity of assessors
    - Roles of tool in production of DrivaPi releases
    - Potential tool misbehaviours and impacts
    - Detectability and severity of impacts
- Record of tool qualification reviews
    - For high impact tools only (low detectability and/or high severity)
    - Link to impact assessment
    - Date of reviews and identity of reviewers
    - Analysis of impacts and misbehaviours
    - Existing tests or measures (e.g. manual reviews) to address these
    - Additional tests and/or Expectations required

**Confidence scoring**

CS-A_02 is based on the set of components and tools identified, how many of (and how often) these have been assessed for their risk and impact for DrivaPi, and the sources of risk and issue data identified.

**Checklist**

- Are there components that are not on the list?
- Are there assessments for all components?
- Has an assessment been done for the current version of the component?
- Have sources of bug and/or vulnerability data been identified?
- Have additional tests and/or Expectations been documented and linked to component assessment?
- Are component tests run when integrating new versions of components?
- Are there tools that are not on the list?
- Are there impact assessments for all tools?
- Have tools with high impact been qualified?
- Were assessments or reviews done for the current tool versions?
- Have additional tests and/or Expectations been documented and linked to tool assessments?
- Are tool tests run when integrating new versions of tools?
- Are tool and component tests included in release preparation?
