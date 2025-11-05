---
id: LLTC-996
header: Code Coverage Verification
text: |
  "Unit test coverage for motor speed driver meets project threshold."

# TSF Type: A Premise
verification_method: Coverage analysis
parents:
- id: SWD-998
reviewers:
- name: Test Engineer
  email: test@team.com
reviewed: ''  # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)
references:
- type: file
  path: artifacts/verification/coverage/coverage-SWD-998.xml
  description: Coverage report
active: true
derived: false
normative: true
level: 4.0
---
Verifies that unit test coverage for the motor speed driver meets the defined project threshold of 80%.
