---
id: <REF>
header: "<HEADER>"
text: |
  <DESCRIPTION>

# TSF Type: Premise (A Claim, but not a Request)

ASIL: <ASIL>
Verification Method: <VERIFICATION_METHOD>

# Links: Connects to the SWD it provides evidence for
links:
  - <PARENT_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''  # Manually fill on PR approval

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
