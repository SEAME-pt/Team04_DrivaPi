---
id: SRD-template
header: "short requirement title here"
text: |
  "detailed requirement statement here"

# TSF Type: Assertion (Both a Request and a Claim)

ASIL: "ASIL level here"
Verification Method: "Verification method here"

# Links: Connects to parent Expectation
parents:
  - id: URD-<PARENT_REF>
# Links: Connects to child Assertion
children:
  - id: SWD-<CHILD_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''    # Manually fill on PR approval

active: true
derived: false
normative: true
level: 2.0
---
<STATEMENT>
