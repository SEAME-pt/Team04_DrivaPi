---
id: SRD-template
header: "Short requirement title here"
text: |
  "Detailed requirement statement here"

# TSF Type: Assertion (Both a Request and a Claim)

ASIL: "ASIL level here (QM/A/B/C/D)"
verification_method: "Verification method here"

# Links: Connects to parent Expectation
parents:
  - id: URD-<PARENT_REF>
# Links: Connects to child Assertion
children:
  - id: SWD-<CHILD_REF>

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
  #   path: docs/design/architecture/system_overview.puml  # System design
  # - type: "file"
  #   path: docs/design/interfaces/can-bus-spec.md  # Interface specification
  # - type: "url"
  #   path: https://github.com/SEAME-pt/Team04_DrivaPi/pull/XX  # Design review PR

active: true
derived: false
normative: true
level: 2.0  # 1.0=URD, 2.0=SRD, 3.0=SWD, 4.0=LLTC
---
<STATEMENT>
