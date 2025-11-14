---
id: URD-template
header: "Short requirement title here"
text: |
  "Detailed requirement statement here"

# TSF Type: Assertion (Both a Request and a Claim)
verification_method: "Verification method here"

# Links: Connects to child Assertion
children:
  - id: SRD-<CHILD_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''  # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# Evidence Linking (use 'references:', NOT deprecated 'artifact:')
references:
  - type: "file"
    path: <relative/path/to/artifact>  # Path from repo root
  # Add more references as needed
  # - type: "url"
  #   path: <https://github.com/SEAME-pt/Team04_DrivaPi/pull/XX>

active: true
derived: false
normative: true
level: 1.0  # 1.0=URD, 2.0=SRD, 3.0=SWD, 4.0=LLTC
---
<STATEMENT>
