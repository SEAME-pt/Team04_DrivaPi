---
id: HLTC-template
header: "Short requirement title here"
text: |
  "Description/Contextualization of statement here"

# TSF Type: Evidence/Premise (A Claim, but not a Request)

verification_method: "Verification method here"

# Links: Connects to the URD/SRD it provides evidence for
parents:
  - id: URD/SRD-<PARENT_REF>

reviewers:
  - name: "<REVIEWER_NAME>"
    email: "<REVIEWER_EMAIL>"
reviewed: ''  # Manually fill on PR approval (YYYY-MM-DD - Approved by Name <email>)

# Evidence Linking
references:
  - type: "file"
    path: <relative/path/to/artifact>  # Path from repo root
  # Common examples:
  # - type: "file"
  #   path: tests/unit/test_temperature.cpp  # Test implementation
  # - type: "file"
  #   path: TSF/verification/tests/LLTC-042-junit.xml  # Test results

# Optional: Automated Validation
evidence:
  type: <validator_name>
  references:
    - type: "file"
      path: <path/to/test/results>
  configuration:
    expected_tests: <NUMBER>

# or Optional manual SME Score
score:
  <SME_ID>: <0.0-1.0>  # SME confidence score
  # Example:
  # TestLead: 1.0

active: true
derived: false
normative: true
level: 2.0
---
<STATEMENT>
