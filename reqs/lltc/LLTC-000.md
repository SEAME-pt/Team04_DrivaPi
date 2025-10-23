---
id: LLTC-000
header: "test requirement for LLTC template"
text: |
  "This is a test requirement for LLTC template."

# TSF Type: Premise (A Claim, but not a Request)

ASIL: "ASIL undefined"
Verification Method: "Verification method undefined"

# Links: Connects to the SWD it provides evidence for
parents:
  - id: SWD-000

reviewers:
  - name: "test reviewer"
    email: "test_reviewer@example.com"
reviewed: '"2025-10-23 - Approved by test reviewer <test_reviewer@example.com>"'  # Manually fill on PR approval

active: true
derived: false
normative: true
level: 4.0
test_type: test_type undefined
test_procedure:
  setup:
    -  setup_steps undefined
  test_steps:
    - step: 1
      action: step_action undefined
      expected: expected_result undefined
  postconditions:
    - postconditions undefined
---
This shall be a test requirement for LLTC template.
