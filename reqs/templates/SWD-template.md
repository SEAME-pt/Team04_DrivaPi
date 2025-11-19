---
id: SWD-template
header: "Short requirement title here"
text: |
  "Detailed requirement statement here"

# TSF Type: Assertion (Both a Request and a Claim)

ASIL: "ASIL level here (QM/A/B/C/D)"
verification_method: "Verification method here"

# Links: Connects to parent Assertion
parents:
  - id: SRD-<PARENT_REF>
# Links: Connects to child Assertion
children:
  - id: LLTC-<CHILD_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''  # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# Evidence Linking (use 'references:', NOT deprecated 'artifact:')
references:
  - type: "file"
    path: <relative/path/to/artifact>  # Path from repo root
  # Common examples:
  # - type: "file"
  #   path: src/sensors/temperature.cpp  # Implementation
  # - type: "file"
  #   path: artifacts/verification/static-analysis/cppcheck-SWD-042.xml  # Analysis
  # - type: "url"
  #   path: https://github.com/SEAME-pt/Team04_DrivaPi/pull/XX  # PR review

active: true
derived: false
normative: true
level: 3.0  # 1.0=URD, 2.0=SRD, 3.0=SWD, 4.0=LLTC
---
<STATEMENT>
