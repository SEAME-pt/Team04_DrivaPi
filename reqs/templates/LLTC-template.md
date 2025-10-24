---
id: LLTC-template
header: "short requirement title here"
text: |
  "detailed requirement statement here"

# TSF Type: Premise (A Claim, but not a Request)

ASIL: "ASIL level here"
Verification Method: "Verification method here"

# Links: Connects to the SWD it provides evidence for
parents:
  - id: SWD-<PARENT_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''    # Manually fill on PR approval

active: true
derived: false
normative: true
level: 4.0
test_type: <TEST_TYPE>
test_procedure:
  setup:
    - <SETUP_STEPS>
  test_steps:
    - step: 1
      action: <STEP_ACTION>
      expected: <EXPECTED_RESULT>
  postconditions:
    - <POSTCONDITIONS>
---
<STATEMENT>
